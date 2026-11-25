#!/usr/bin/env python3
"""Downloads the Open Food Facts products behind the "typical" values of a few
simple foods that the BLS does not have (Skyr Vanille, protein bars, ...).

Writes tool/simple_foods/off_products.tsv: every product that goes into a
median, with its values. build_simple_foods.py computes the medians from that
file, so building the list never needs the internet. See README.md here.

Python 3.9+, standard library only. 9 requests, at most 8 per minute
(Open Food Facts asks for at most 10 search requests per minute).

    python3 tool/simple_foods/off_averages.py [--cache DIR]

With --cache, every downloaded page is kept in DIR and read from there on the
next run (the search API often answers "503 temporarily unavailable"; a
second run then only asks for the missing pages).
"""

import json
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

USER_AGENT = 'FoodTracker/0.1 (https://github.com/mr-dzzs21/food-tracker)'

# The old search API still returns `nutriments` for a category + country
# query; search.openfoodfacts.org (the app's text search) no longer does.
SEARCH_URL = 'https://world.openfoodfacts.org/api/v2/search'
PAGE_SIZE = 100
SECONDS_BETWEEN_REQUESTS = 8  # 7.5 requests per minute

OUT = Path(__file__).resolve().parent / 'off_products.tsv'

# Which categories to download, and how many pages of 100 at most (sorted by
# popularity, so the first pages are the products people buy most).
CATEGORIES = {
    'en:skyrs': 2,
    'en:greek-style-yogurts': 1,
    'en:protein-bars': 1,
    'en:puddings': 1,
    'en:energy-drinks': 1,
    'en:chicken-nuggets': 1,
    'en:protein-powders': 1,
    'en:smoothies': 1,
}

FRUITS = (r'erdbeer|himbeer|heidelbeer|blaubeer|beere|kirsch|pfirsich|mango|'
          r'maracuja|passionsfrucht|aprikose|rhabarber|frucht|cranberr|'
          r'strawberr|raspberr|blueberr|cherry|peach|apricot|fruit')
SUGAR_FREE = r'zero|sugar ?free|zuckerfrei|ohne zucker|light|0 ?% zucker'

# One entry per simple food. `key` is the key in tool/simple_foods/foods.tsv
# (source "off:<key>"). A product counts when its name (German name, else the
# main name) matches `include` (if given), does not match `exclude`, and its
# values lie in the given ranges. The ranges only drop obvious mistakes and
# other kinds of product, they are wide on purpose.
AVERAGES = [
    {
        'key': 'skyr-vanille',
        'category': 'en:skyrs',
        'include': r'vanil',
        'exclude': FRUITS + r'|schoko|stracciat|drink|trink|protein|müsli|'
                   r'granola|kokos|karamell|caramel|keks|cookie|natur',
        'kcal': (50, 130),
    },
    {
        'key': 'skyr-frucht',
        'category': 'en:skyrs',
        'include': FRUITS,
        'exclude': r'vanil|schoko|stracciat|drink|trink|protein|müsli|'
                   r'granola|natur|eis\b|riegel',
        'kcal': (50, 130),
    },
    {
        'key': 'griechischer-joghurt',
        'category': 'en:greek-style-yogurts',
        'exclude': FRUITS + r'|honig|honey|vanil|schoko|nuss|walnut|protein|'
                   r'drink|müsli|granola',
        # The classic one with about 10 % fat (there are also 0.2 % and 2 %).
        'fat': (8, 12),
    },
    {
        'key': 'proteinriegel',
        'category': 'en:protein-bars',
        'kcal': (250, 480),
        'protein': (15, 50),
    },
    {
        'key': 'proteinpudding',
        'category': 'en:puddings',
        'include': r'protein|eiwei',
        'kcal': (40, 130),
        'protein': (7, 20),
    },
    {
        'key': 'energy-drink',
        'category': 'en:energy-drinks',
        'exclude': SUGAR_FREE + r'|pulver|powder|shot|kaffee|coffee',
        'kcal': (30, 70),
    },
    {
        'key': 'energy-drink-zero',
        'category': 'en:energy-drinks',
        'include': SUGAR_FREE,
        'exclude': r'pulver|powder|shot',
        'kcal': (0, 10),
    },
    {
        'key': 'chicken-nuggets',
        'category': 'en:chicken-nuggets',
        'exclude': r'vegan|vegetar|veggie|plant|soja',
        'kcal': (150, 350),
    },
    {
        'key': 'proteinpulver',
        'category': 'en:protein-powders',
        'include': r'whey',
        'exclude': r'vegan|riegel|bar\b|pudding|crisp|cream|keks|cookie|'
                   r'drink|trinkfertig',
        'kcal': (320, 430),
        'protein': (60, 95),
    },
    {
        'key': 'smoothie',
        'category': 'en:smoothies',
        'exclude': r'grün|green|spinat|protein|joghurt|yogurt|milch|milk|'
                   r'kokos|shot|pulver|powder',
        'kcal': (30, 90),
    },
]

# The 8 values the app uses (column names of off_products.tsv) and their
# Open Food Facts names. Fibre is optional, all others are required.
NUTRIENTS = [
    ('kcal', 'energy-kcal_100g'),
    ('fat', 'fat_100g'),
    ('saturated_fat', 'saturated-fat_100g'),
    ('carbs', 'carbohydrates_100g'),
    ('sugars', 'sugars_100g'),
    ('fibre', 'fiber_100g'),
    ('protein', 'proteins_100g'),
    ('salt', 'salt_100g'),
]

_last_request = 0.0


def get_json(url):
    """One polite GET request: spaced out, our User-Agent, a few more tries
    after a temporary error (Open Food Facts asks to wait a minute after
    429/503)."""
    global _last_request
    attempts = 6
    for attempt in range(1, attempts + 1):
        wait = SECONDS_BETWEEN_REQUESTS - (time.time() - _last_request)
        if wait > 0:
            time.sleep(wait)
        _last_request = time.time()
        request = urllib.request.Request(url, headers={
            'User-Agent': USER_AGENT, 'Accept': 'application/json'})
        try:
            with urllib.request.urlopen(request, timeout=60) as response:
                return json.loads(response.read().decode('utf-8'))
        except (urllib.error.HTTPError, urllib.error.URLError, ValueError) as error:
            if attempt == attempts:
                raise
            print(f'  {error} - waiting 90 s, then trying again', file=sys.stderr)
            time.sleep(90)


def download(category, pages, cache):
    products = []
    for page in range(1, pages + 1):
        cached = None
        if cache is not None:
            cached = cache / f'{category.replace(":", "_")}_{page}.json'
        if cached is not None and cached.exists():
            data = json.loads(cached.read_text(encoding='utf-8'))
            batch = data.get('products') or []
            products.extend(batch)
            print(f'  {category} page {page}: {len(batch)} (cached)')
            if page * PAGE_SIZE >= int(data.get('count') or 0):
                break
            continue
        url = SEARCH_URL + '?' + urllib.parse.urlencode({
            'categories_tags_en': category,
            'countries_tags_en': 'germany',
            'fields': 'code,product_name,product_name_de,brands,nutriments',
            'page_size': PAGE_SIZE,
            'page': page,
        })
        data = get_json(url)
        if cached is not None:
            cached.write_text(json.dumps(data), encoding='utf-8')
        batch = data.get('products') or []
        products.extend(batch)
        print(f'  {category} page {page}: {len(batch)} of {data.get("count")}')
        if page * PAGE_SIZE >= int(data.get('count') or 0):
            break
    return products


def number(nutriments, name):
    value = nutriments.get(name)
    if isinstance(value, str):
        try:
            value = float(value.replace(',', '.'))
        except ValueError:
            return None
    if isinstance(value, (int, float)):
        return float(value)
    return None


def values_of(product):
    """The 8 values, or None when a required one is missing or impossible."""
    nutriments = product.get('nutriments') or {}
    values = {column: number(nutriments, name) for column, name in NUTRIENTS}
    if any(values[c] is None for c, _ in NUTRIENTS if c != 'fibre'):
        return None
    if not 0 <= values['kcal'] <= 900:
        return None
    for column, _ in NUTRIENTS:
        if column != 'kcal' and values[column] is not None:
            if not 0 <= values[column] <= 100:
                return None
    if values['saturated_fat'] > values['fat'] + 0.05:
        return None
    if values['sugars'] > values['carbs'] + 0.05:
        return None
    return values


def name_of(product):
    for field in ('product_name_de', 'product_name'):
        name = (product.get(field) or '').strip()
        if name:
            return ' '.join(name.split())
    return ''


def matches(average, name, brands, values):
    text = f'{name} {brands}'.lower()
    include = average.get('include')
    if include and not re.search(include, text):
        return False
    exclude = average.get('exclude')
    if exclude and re.search(exclude, text):
        return False
    for column in ('kcal', 'fat', 'protein'):
        low_high = average.get(column)
        if low_high and not low_high[0] <= values[column] <= low_high[1]:
            return False
    return True


def main():
    cache = None
    if len(sys.argv) == 3 and sys.argv[1] == '--cache':
        cache = Path(sys.argv[2])
        cache.mkdir(parents=True, exist_ok=True)
    elif len(sys.argv) != 1:
        sys.exit('usage: off_averages.py [--cache DIR]')
    downloaded = {}
    for category, pages in CATEGORIES.items():
        downloaded[category] = download(category, pages, cache)

    lines = ['# Open Food Facts products (sold in Germany) behind the averages in '
             'assets/data/simple_foods_off.tsv. Data: Open Food Facts, ODbL. '
             'Generated by tool/simple_foods/off_averages.py - do not edit.',
             '\t'.join(['key', 'code', 'name', 'brands'] + [c for c, _ in NUTRIENTS])]
    for average in AVERAGES:
        seen = set()
        used = 0
        for product in downloaded[average['category']]:
            code = str(product.get('code') or '')
            name = name_of(product)
            values = values_of(product)
            if not code or not name or code in seen or values is None:
                continue
            brands = ' '.join(str(product.get('brands') or '').split())
            if not matches(average, name, brands, values):
                continue
            seen.add(code)
            used += 1
            cells = [average['key'], code, name.replace('\t', ' '),
                     brands.replace('\t', ' ')]
            cells += ['' if values[c] is None else f'{values[c]:g}'
                      for c, _ in NUTRIENTS]
            lines.append('\t'.join(cells))
        print(f'{average["key"]}: {used} products')
        if used < 5:
            sys.exit(f'Too few products for {average["key"]} - check the rules.')
    OUT.write_text('\n'.join(lines) + '\n', encoding='utf-8')
    print(f'Wrote {OUT}')


if __name__ == '__main__':
    main()
