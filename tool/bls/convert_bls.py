"""Converts the Bundeslebensmittelschlüssel (BLS) 4.0 into the app's asset.

Reads `BLS_4_0_Daten_2025_DE.xlsx` (Max Rubner-Institut, CC BY 4.0) and writes
`assets/data/bls_4_0.tsv`: one line per food with the BLS code, the German and
English name, the eight nutrients the app uses (per 100 g) and two derived
columns (`liquid`, `category`). How to run it and why the rules are as they
are: tool/bls/README.md.

Usage:
    python3 tool/bls/convert_bls.py path/to/BLS_4_0_Daten_2025_DE.xlsx

Needs the package `openpyxl` (reads .xlsx files).
"""

import argparse
import collections
import re
import sys
from decimal import ROUND_HALF_UP, Decimal
from pathlib import Path

from openpyxl import load_workbook

REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_OUTPUT = REPO_ROOT / "assets" / "data" / "bls_4_0.tsv"

# BLS component code -> (column name in the asset, decimals kept).
# kcal as a whole number (the BLS has whole numbers anyway), grams with one
# decimal, salt with two: as precise as a food label (EU 1169/2011 guidance)
# or better, so sums of several portions stay right.
NUTRIENTS = [
    ("ENERCC", "kcal", 0),
    ("FAT", "fat", 1),
    ("FASAT", "saturated_fat", 1),
    ("CHO", "carbs", 1),  # available carbohydrate, as on EU labels
    ("SUGAR", "sugars", 1),
    ("FIBT", "fibre", 1),
    ("PROT625", "protein", 1),
    ("NACL", "salt", 2),
]
# Only read to decide whether a drink is alcoholic (not written out).
ALCOHOL = "ALC"

# Text values in the number columns (BLS documentation, chapter 4.3/4.4).
MISSING = {"-"}  # "Fehlender Wert": unknown, never 0
NEAR_ZERO = {"TR", "<LOD", "<LOQ", "<LOD or <LOQ"}  # traces / below the limit

# --- Drinks (column `liquid`) -------------------------------------------------
# The first letter of the BLS code is the main food group. N and P are the
# drinks (N: without alcohol, P: with alcohol). Their powders (instant coffee,
# coffee substitute) are not drinks.
DRINK_GROUPS = {"N", "P"}
# Drinks in other groups (juices are with the fruit, milk with the dairy
# products). Checked on the first word of the German name, because German
# compounds end with the thing itself ("Orangen|saft", "Hafer|drink"). Thick
# syrups ("Apfeldicksaft") stay food; "Dickmilch" is not in the milk list.
LIQUID_FIRST_WORD = re.compile(
    r"(saft|nektar|drink|getränk|wasser)$"
    r"|^trink"
    r"|^(h-)?(voll|mager)?milch$"
    r"|^(roh|ziegen|schaf|butter|kokos)milch$"
)
NOT_LIQUID_FIRST_WORD = re.compile(r"dicksaft$|pulver")

# --- No traffic light (column `category`) ------------------------------------
# The app's health rating skips some kinds of food (lib/features/products/
# health_rating.dart, `notRatedCategories`). BLS foods of those kinds get the
# matching Open Food Facts category tag, so the same rule applies to them.
ALCOHOL_FREE_MAX_GRAMS = 0.5  # "alkoholfrei" in Germany: below 0.5 % vol
SUBGROUP_CATEGORIES = {
    "N1": "en:waters",
    "N4": "en:coffees",
    "N5": "en:coffees",  # coffee substitutes, cappuccino powder
    "N6": "en:teas",
    "N7": "en:herbal-teas",  # herbal and fruit teas
    "R2": "en:spices",
    "R5": "en:food-additives",  # food acids (E 260, E 270, E 300, E 330)
    "R8": "en:dried-products-to-be-rehydrated",  # stock cubes and powders
}
SALT = re.compile(r"^[^ ,/]*salz")  # "Speisesalz", "Meersalz", "Kräutersalz"
VINEGAR = re.compile(r"^[^ ,/]*essig\b")  # "Apfelessig", "Balsamicoessig"
ADDITIVE = re.compile(r"glutamat")
# Instant powders and dried mixes are rated after preparing, not as powder.
TO_BE_REHYDRATED = re.compile(r"instantpulver|trockenprodukt|puddingpulver")
PREPARED = re.compile(r"\baus\b|zubereitet")
SUGAR_SUBSTITUTE = re.compile(r"tafelsüße|^(sorbit|xylit|mannit|erythrit)\b")


def clean_name(value):
    """One line of text: no tabs or line breaks, single spaces."""
    if not isinstance(value, str) or not value.strip():
        raise ValueError(f"missing name: {value!r}")
    return " ".join(value.split())


def read_number(value, where):
    """A number from the sheet, `None` (unknown), or 0 for traces."""
    if value is None:
        return None
    if isinstance(value, (int, float)):
        if value < 0:
            raise ValueError(f"{where}: negative value {value}")
        return value
    text = str(value).strip()
    if text in MISSING:
        return None
    if text in NEAR_ZERO:
        return 0
    raise ValueError(f"{where}: unknown text value {text!r}")


def format_number(value, decimals):
    """Rounded half away from zero, without trailing zeros: 7.1, 12, 0.05."""
    if value is None:
        return ""
    step = Decimal(1).scaleb(-decimals)  # 1, 0.1 or 0.01
    rounded = Decimal(str(value)).quantize(step, rounding=ROUND_HALF_UP)
    text = f"{rounded:f}"
    if "." in text:
        text = text.rstrip("0").rstrip(".")
    return "0" if text == "-0" else text


def first_word(name):
    """'Rohmilch/Vorzugsmilch, mind. 3,5 % Fett' -> 'rohmilch'."""
    return re.split(r"[ ,/(]", name.lower(), maxsplit=1)[0]


def is_liquid(code, name_de):
    """Groups N and P (not their powders), and juices, plant drinks and milk."""
    if code[0] in DRINK_GROUPS:
        name = name_de.lower()
        is_powder = "pulver" in name and not PREPARED.search(name)
        return not is_powder
    word = first_word(name_de)
    return bool(LIQUID_FIRST_WORD.search(word)) and not NOT_LIQUID_FIRST_WORD.search(word)


def category(code, name_de, alcohol):
    """The Open Food Facts tag of a kind of food without a traffic light."""
    name = name_de.lower()
    if code[0] == "P" and (alcohol is None or alcohol >= ALCOHOL_FREE_MAX_GRAMS):
        return "en:alcoholic-beverages"
    subgroup = SUBGROUP_CATEGORIES.get(code[:2])
    if subgroup:
        return subgroup
    if TO_BE_REHYDRATED.search(name) and not PREPARED.search(name):
        return "en:dried-products-to-be-rehydrated"
    if code[:2] == "R1":
        if SALT.search(name):
            return "en:salts"
        if VINEGAR.search(name):
            return "en:vinegars"
        if ADDITIVE.search(name):
            return "en:food-additives"
    if code[:2] == "R4" and not PREPARED.search(name):
        return "en:food-additives"  # baking agents, gelatine, yeast, …
    if SUGAR_SUBSTITUTE.search(name):
        return "en:sugar-substitutes"
    return ""


def column_index(header, code):
    """Index of the value column of a BLS component (not its source columns)."""
    for index, title in enumerate(header):
        if not isinstance(title, str):
            continue
        if title.split(" ")[0] == code and not title.endswith(("Datenherkunft", "Referenz")):
            return index
    raise ValueError(f"column for {code} not found")


def convert(source, output):
    sheet = load_workbook(source, read_only=True, data_only=True).worksheets[0]
    rows = sheet.iter_rows(values_only=True)
    header = next(rows)
    if header[:3] != ("BLS Code", "Lebensmittelbezeichnung", "Food name"):
        raise ValueError(f"unexpected first columns: {header[:3]}")
    nutrient_columns = [column_index(header, code) for code, _, _ in NUTRIENTS]
    alcohol_column = column_index(header, ALCOHOL)

    foods = []
    for row in rows:
        if row[0] is None:
            continue
        code = str(row[0]).strip()
        if not re.fullmatch(r"[A-Z][0-9A-Z]{6}", code):
            raise ValueError(f"unexpected BLS code {code!r}")
        name_de, name_en = clean_name(row[1]), clean_name(row[2])
        values = [
            format_number(read_number(row[index], f"{code} {key}"), decimals)
            for index, (_, key, decimals) in zip(nutrient_columns, NUTRIENTS)
        ]
        if values[0] == "":
            raise ValueError(f"{code}: no kcal")
        alcohol = read_number(row[alcohol_column], f"{code} {ALCOHOL}")
        foods.append(
            [
                code,
                name_de,
                name_en,
                *values,
                "1" if is_liquid(code, name_de) else "0",
                category(code, name_de, alcohol),
            ]
        )

    foods.sort(key=lambda food: food[0])
    codes = [food[0] for food in foods]
    if len(set(codes)) != len(codes):
        raise ValueError("duplicate BLS codes")

    lines = [
        "# Bundeslebensmittelschlüssel (BLS) 4.0, Max Rubner-Institut, CC BY 4.0 "
        "(see assets/data/README.md). Generated by tool/bls/convert_bls.py - do not edit.",
        "\t".join(
            ["code", "name_de", "name_en", *(key for _, key, _ in NUTRIENTS), "liquid", "category"]
        ),
        *("\t".join(food) for food in foods),
    ]
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text("\n".join(lines) + "\n", encoding="utf-8")

    liquid = [food for food in foods if food[-2] == "1"]
    categories = collections.Counter(food[-1] for food in foods if food[-1])
    print(f"{len(foods)} foods -> {output} ({output.stat().st_size / 1024:.0f} KB)")
    print(f"{len(liquid)} drinks ({sum(f[0][0] not in DRINK_GROUPS for f in liquid)} outside N/P)")
    for tag, count in sorted(categories.items()):
        print(f"  {tag}: {count}")


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("source", type=Path, help="BLS_4_0_Daten_2025_DE.xlsx")
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    args = parser.parse_args()
    try:
        convert(args.source, args.output)
    except ValueError as error:
        sys.exit(f"error: {error}")


if __name__ == "__main__":
    main()
