# Basic foods from the BLS (`convert_bls.py`)

`convert_bls.py` turns the **Bundeslebensmittelschlüssel (BLS) 4.0** of the Max Rubner-Institut into the file
the app bundles: `assets/data/bls_4_0.tsv`. Source, licence (CC BY 4.0) and the list of changes are in
`assets/data/README.md` – keep that file up to date when the conversion changes.

## Run it again

You only need this for a new BLS version or a changed rule. The generated file is committed, so building the
app never needs Python.

1. Download `BLS_4_0_2025_DE.zip` from <https://www.blsdb.de/download> and unpack it **outside** the repository
   (it is about 14 MB). You need `BLS_4_0_Daten_2025_DE.xlsx`.
2. Python 3.9 or newer with the package `openpyxl` (reads Excel files), best in its own virtual environment:

   ```sh
   python3 -m venv ~/venvs/bls
   ~/venvs/bls/bin/pip install openpyxl
   ```

3. In the repository folder:

   ```sh
   ~/venvs/bls/bin/python3 tool/bls/convert_bls.py ~/Downloads/BLS_4_0_2025_DE/BLS_4_0_Daten_2025_DE.xlsx
   ```

   It prints the number of foods, drinks and not-rated foods per category. With the 2025 file: 7,140 foods,
   378 drinks, 243 without a traffic light.
4. Run `flutter test` (the tests read the real file) and look at `git diff assets/data/bls_4_0.tsv`.

The script stops with an error instead of guessing when the file looks different (unknown column, unknown text
in a number column, duplicate code).

## What the file contains

Tab-separated, UTF-8, a `#` comment line, then a header line:

| Column | Meaning |
|---|---|
| `code` | BLS code, e.g. `B782100`. The app stores it as `Foods.externalId`. |
| `name_de`, `name_en` | Names from the BLS (`Lebensmittelbezeichnung`, `Food name`) |
| `kcal` … `salt` | ENERCC, FAT, FASAT, CHO, SUGAR, FIBT, PROT625, NACL per 100 g. Empty = unknown. |
| `liquid` | `1` for drinks (see below) |
| `category` | Open Food Facts tag for foods without a traffic light, else empty (see below) |

Rounding: kcal whole numbers, grams 0.1 g, salt 0.01 g (half away from zero) – as precise as a food label or
better. BLS text values: `-` (missing) → empty; `TR` (traces), `<LOD`, `<LOQ` → 0.

## Rules

The first letter of a BLS code is the main food group. The BLS documentation (chapter 2.4) only says that; the
group names below come from the data itself.

| Letter | Group | Letter | Group |
|---|---|---|---|
| B | bread, rolls | N | drinks without alcohol (N1 water, N4/N5 coffee, N6 tea, N7 herbal/fruit tea) |
| C | cereals, rice, cereal drinks | P | alcoholic drinks |
| D | cakes, biscuits | Q | fats, oils |
| E | eggs, pasta | R | seasonings, spices (R2), additives (R4, R5), stock (R8), sauces |
| F | fruit, fruit juices | S | sugar, sweets |
| G | vegetables, vegetable juices | T | fish |
| H | pulses, nuts, seeds, plant drinks | U, V, W | meat, poultry/game/offal, sausages |
| K | potatoes, mushrooms | X, Y | dishes and recipes |
| M | milk and dairy | | |

**Drinks (`liquid`).** The app shows drinks per 100 ml and counts 1 ml as 1 g (the BLS values are per 100 g;
for most drinks the difference is a few percent).

- All foods of the main groups **N** and **P**, except powders (name contains "pulver" without "aus" or
  "zubereitet", e.g. "Instantkaffeepulver"; "Kaffee aus Instantpulver" is a drink).
- In the other groups, foods with a word in the **head** of the name (the part before the first comma, bracket
  or linking word *mit, in, im, aus, auf, ohne, für, nach, von*) that ends with *saft, nektar, drink, getränk,
  wasser, smoothie, shake, kefir, molke*, starts with *Trink*, is *Ayran*, or is plain or flavoured milk
  (*Milch, Vollmilch, H-Milch, Rohmilch, Ziegenmilch, Schafmilch, Buttermilch, Kokosmilch, Bananenmilch,
  Erdbeermilch*). German compounds end with the thing itself, so "Orangensaft" is a juice but "Saftschinken"
  is not; "Roter Mehrfruchtsaft" and "Sahnekefir" are drinks. Only the head counts, so "Birne in Fruchtsaft",
  "Thunfisch im eigenen Saft" and "Roggenbrot mit Buttermilch" stay food. Not drinks either: thick syrups
  (*…dicksaft*), powders, Dickmilch, condensed milk, yoghurt, soups, Buttermilch-Dressing.

**No traffic light (`category`).** The health rating skips these kinds of food, like it does for Open Food Facts
products (`notRatedCategories` in `lib/features/products/health_rating.dart`). The script writes the matching
Open Food Facts tag, so the same rule applies:

| Tag | BLS foods |
|---|---|
| `en:alcoholic-beverages` | group P with at least 0.5 g alcohol per 100 g or unknown alcohol (alcohol-free beer is rated) |
| `en:waters` | N1 (drinking, mineral and spring water) |
| `en:coffees` | N4, N5 (coffee, coffee substitutes, also with milk or sugar) |
| `en:teas`, `en:herbal-teas` | N6, N7 |
| `en:spices` | R2 (dried spices, ginger) |
| `en:salts`, `en:vinegars` | R1 foods whose first word contains *salz* / ends with *essig* |
| `en:food-additives` | R5 (food acids), R4 except prepared puddings (baking agents, yeast, gelatine, …), glutamate |
| `en:dried-products-to-be-rehydrated` | R8 (stock cubes/powder) and names with *Instantpulver, Trockenprodukt, Puddingpulver* (not "aus …"/"zubereitet") |
| `en:sugar-substitutes` | table sweeteners (*Tafelsüße*), sorbitol, xylitol, mannitol |
| `en:baby-foods` | purées for babies (*geeignet für Beikost*, X groups): the traffic light is made for adults' food |

Everything else is rated with the food thresholds, or the drink thresholds when `liquid` is 1. Known limits:
fresh herbs (e.g. "Basilikum roh") are rated like vegetables, because the BLS groups do not separate them
cleanly; sweetened coffee and tea drinks are not rated (Open Food Facts rates ready-to-drink coffee drinks).
