# Bundled data

## `bls_4_0.tsv` – basic foods (Bundeslebensmittelschlüssel 4.0)

**Source:** Max Rubner-Institut (2025): Bundeslebensmittelschlüssel (BLS), Version 4.0 — Deutsche
Nährstoffdatenbank. Karlsruhe. DOI: [10.25826/Data20251217-134202-0](https://doi.org/10.25826/Data20251217-134202-0).
Publisher: Max Rubner-Institut, Bundesforschungsinstitut für Ernährung und Lebensmittel.
Website and download: <https://www.blsdb.de> (file `BLS_4_0_2025_DE.zip`).

**Licence:** [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/).
The download page says: „Die Nutzung ist unter der Lizenz CC BY 4.0 (Creative Commons Namensnennung 4.0
International) gestattet.“ and asks to name the Max Rubner-Institut as publisher. The app does this on every
product page of a basic food, under the basic-food search results and on the About page.

**Changes made for this app** (by `tool/bls/convert_bls.py`, see `tool/bls/README.md`):

- Only 8 of the 138 nutrients are kept: energy (kcal), fat, saturated fatty acids, available carbohydrate,
  sugars, total fibre, protein (N × 6.25) and salt – all per 100 g edible portion. Data source and reference
  columns are left out.
- Values are rounded (kcal whole numbers, grams to 0.1 g, salt to 0.01 g). Missing values ("-") stay empty;
  traces and values below the detection limit ("TR", "<LOD", "<LOQ") are written as 0.
- Two columns are added: `liquid` (1 = drink) and `category` (an Open Food Facts category tag for kinds of food
  that the app does not rate, e.g. `en:waters`). They are derived from the BLS food groups and names.
- Converted from Excel (`BLS_4_0_Daten_2025_DE.xlsx`) to a tab-separated text file, sorted by BLS code.

The values are averages for a kind of food; individual products can differ. The BLS data is not covered by the
app's MIT licence.

## `simple_foods_bls.tsv` and `simple_foods_off.tsv` – simple foods

The short list of everyday foods the search shows first ("Skyr natur", "Reis gekocht"), with search
words and a typical portion. Made by `tool/simple_foods/build_simple_foods.py` from the hand-written
list `tool/simple_foods/foods.tsv` (how to change it: `tool/simple_foods/README.md`). One file per
licence, so the licences do not mix:

### `simple_foods_bls.tsv` – values from the BLS

**Source and licence:** the same as `bls_4_0.tsv` above – Max Rubner-Institut (2025):
Bundeslebensmittelschlüssel (BLS), Version 4.0 — Deutsche Nährstoffdatenbank. Karlsruhe.
DOI: [10.25826/Data20251217-134202-0](https://doi.org/10.25826/Data20251217-134202-0).
[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

**Changes made for this app:** in addition to the changes listed for `bls_4_0.tsv`, each row takes the
8 values of one BLS food (column `bls_code`) unchanged and adds our own short names, search words and
a typical portion. Some foods are marked as drinks (`liquid`) where the BLS file does not (kefir).
The app names the BLS as the source under the search results and on the product page.

### `simple_foods_off.tsv` – typical values from Open Food Facts

For the few foods the BLS does not have (for example "Skyr Vanille", "Proteinriegel", "Energy Drink"),
the values are the **median** of Open Food Facts products of that kind sold in Germany. Which products
and how many went into each median: `tool/simple_foods/off_products.tsv` (column `off_products` here
gives the number).

**Source:** Open Food Facts, <https://world.openfoodfacts.org>. **Licence:** this file is a database
derived from the Open Food Facts database and is made available under the
[Open Database License (ODbL) 1.0](https://opendatacommons.org/licenses/odbl/1-0/); the individual
contents are under the [Database Contents License (DbCL) 1.0](https://opendatacommons.org/licenses/dbcl/1-0/).
The same applies to `tool/simple_foods/off_products.tsv`. The app names Open Food Facts on the product
page of such a food ("Durchschnitt aus N Produkten von Open Food Facts"), under the search results and
on the About page.

The names, search words and portions in both files are our own (MIT, like the app). All values are
averages for a kind of food; individual products can differ.
