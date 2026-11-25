# Simple foods (`build_simple_foods.py`)

The search shows **simple foods** first: about 400 everyday foods with short names ("Skyr natur",
"Reis gekocht", "Döner Kebab"), the words people type for them and a typical portion. The app bundles
them in two files, one per licence:

| File | Values from | Licence |
|---|---|---|
| `assets/data/simple_foods_bls.tsv` | the BLS 4.0 (`assets/data/bls_4_0.tsv`) | CC BY 4.0, Max Rubner-Institut |
| `assets/data/simple_foods_off.tsv` | medians of Open Food Facts products sold in Germany | ODbL 1.0, Open Food Facts |

Both are generated – change the list here and build them again. Source, licences and changes are in
`assets/data/README.md`.

## The files in this folder

| File | What it is |
|---|---|
| `foods.tsv` | **The list. Edit this one** (by hand or in a spreadsheet, saved as tab-separated UTF-8). |
| `off_averages.py` | Downloads the Open Food Facts products for the few foods the BLS does not have and writes `off_products.tsv`. Needs the internet; run it rarely. |
| `off_products.tsv` | Every Open Food Facts product that goes into a median, with its values (generated, ODbL). It records which and how many products each average comes from. |
| `build_simple_foods.py` | Builds the two asset files from `foods.tsv`, the BLS file and `off_products.tsv`. No internet. |

## Change the list

1. Edit `foods.tsv`. Columns:

   | Column | Meaning |
   |---|---|
   | `key` | Stable id, lower case with `-` (`skyr-natur`). Never change it for an existing food: the app stores Open Food Facts averages under it. |
   | `name_de`, `name_en` | Short everyday name. No two foods with the same name. |
   | `synonyms_de`, `synonyms_en` | Other words people type, separated by `\|` (`Nudel\|Pasta\|Spaghetti`). Umlauts and upper/lower case do not matter; plural endings (-n, -e, -en, -er, -s) are ignored by the search. |
   | `source` | `bls:<code>` (a code from `assets/data/bls_4_0.tsv`; each code only once) or `off:<key>` (an entry in `AVERAGES` in `off_averages.py`). |
   | `portion_g`, `portion_de`, `portion_en` | A typical portion: grams (ml for drinks) and its name (`120`, `1 Banane`, `1 banana`). Shown as "1 Banane (120 g)". Empty = none. |
   | `liquid` | Empty = as the source says, `1` = drink (values per 100 ml), `0` = food. |

   The order of the lines matters: when several foods fit a search equally well, the one higher up
   comes first. Keep basic foods (bread, rice, milk) above dishes.

2. Pick BLS codes carefully: "Reis gekocht" must be a cooked rice, not raw rice. Search the BLS file,
   for example `grep -i "reis" assets/data/bls_4_0.tsv`.
3. Build:

   ```sh
   python3 tool/simple_foods/build_simple_foods.py
   ```

   It stops with a message when something is wrong (unknown BLS code, a code or name used twice,
   impossible values such as more saturated fat than fat).
4. Run `flutter test` (the tests read the real files: consistency, values equal to the BLS, search
   order for "skyr", "reis", "nudeln" …) and look at `git diff assets/data/`.

## A food the BLS does not have

Only when the BLS has nothing fitting (it has no "Skyr Vanille", no protein bar, no energy drink):

1. Add an entry to `AVERAGES` in `off_averages.py`: the Open Food Facts category (it must also be in
   `CATEGORIES` with the number of pages to download), words the product name must contain
   (`include`) or must not contain (`exclude`), and wide value ranges that drop other kinds of product.
2. Run it (Python 3.9+, no packages needed):

   ```sh
   python3 tool/simple_foods/off_averages.py --cache /tmp/off-pages
   ```

   It uses the old search API (`world.openfoodfacts.org/api/v2/search?categories_tags_en=…&
   countries_tags_en=germany&fields=…,nutriments`), because the new search service
   (`search.openfoodfacts.org`, used by the app) no longer returns nutrition values. It sends at most
   8 requests per minute with our User-Agent and waits 90 s after a "503 temporarily unavailable"
   (common – then simply run it again; with `--cache` the pages already downloaded are not asked for
   again). It keeps only products with all of kcal, fat, saturated fat, carbohydrates, sugars,
   protein and salt (fibre is optional) and plausible values, and stops when fewer than 5 are left.
3. Add the food to `foods.tsv` with `source` `off:<key>` and build as above.

The average is the **median** of each value (half of the products have more, half less), so a few
unusual products do not move it. Fibre is left empty when fewer than half of the products state it.
Rounding as in the BLS file: kcal whole numbers, grams 0.1 g, salt 0.01 g.
