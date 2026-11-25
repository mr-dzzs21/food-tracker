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
