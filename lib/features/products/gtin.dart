// Barcodes (GTIN = Global Trade Item Number) – pure functions, no Flutter.
//
// Open Food Facts does not check barcodes, so a misread digit would just give
// "product not found". The app checks the last digit (check digit) first and
// tells the user to scan again instead.
//
// Rules: .notes/research/off-api.md, F14 and R11.

final _digitsOnly = RegExp(r'^\d+$');

/// Whether [code] consists of digits only (and is not empty).
bool isDigitsOnly(String code) => _digitsOnly.hasMatch(code);

/// The GS1 check digit for the digits in front of it.
///
/// From the right, the digits are multiplied by 3, 1, 3, 1, …;
/// check digit = (10 − sum mod 10) mod 10.
int computeCheckDigit(String digitsWithoutCheck) {
  var sum = 0;
  var weight = 3;
  for (var i = digitsWithoutCheck.length - 1; i >= 0; i--) {
    sum += int.parse(digitsWithoutCheck[i]) * weight;
    weight = weight == 3 ? 1 : 3;
  }
  return (10 - sum % 10) % 10;
}

/// Whether [code] is an EAN-8, UPC-A (12), EAN-13 or GTIN-14 with a correct
/// check digit.
bool isValidGtin(String code) {
  if (!isDigitsOnly(code)) return false;
  if (!const [8, 12, 13, 14].contains(code.length)) return false;
  final body = code.substring(0, code.length - 1);
  return computeCheckDigit(body) == int.parse(code[code.length - 1]);
}

/// Turns an 8-digit UPC-E code (short US code, number system 0 or 1) into
/// the full 12-digit UPC-A code. Returns `null` if [upcE] is not a valid
/// UPC-E code.
///
/// Example: `04252614` → `042100005264`.
String? expandUpcE(String upcE) {
  if (!RegExp(r'^[01]\d{7}$').hasMatch(upcE)) return null;
  final numberSystem = upcE[0];
  final d = upcE.substring(1, 7); // the six "compressed" digits
  final check = upcE[7];
  final last = d[5];
  // The last compressed digit says where the left-out zeros belong.
  final String body;
  switch (last) {
    case '0' || '1' || '2':
      body = '${d.substring(0, 2)}${last}0000${d.substring(2, 5)}';
    case '3':
      body = '${d.substring(0, 3)}00000${d.substring(3, 5)}';
    case '4':
      body = '${d.substring(0, 4)}00000${d[4]}';
    default:
      body = '${d.substring(0, 5)}0000$last';
  }
  final upcA = '$numberSystem$body$check';
  return isValidGtin(upcA) ? upcA : null;
}

/// Normalises a barcode exactly like Open Food Facts does
/// (`normalize_code_zeroes` in its server code):
/// strip leading zeros, pad to 13 digits, and shorten 13-digit codes that
/// start with `00000` to 8 digits.
///
/// - `036000291452` (UPC-A) → `0036000291452`
/// - `0000042376095` → `42376095`
///
/// The app uses the result as the key in its database, so the same product
/// is never stored twice under different spellings.
String normalizeLikeOff(String code) {
  if (!isDigitsOnly(code)) return code;
  var c = code.replaceFirst(RegExp(r'^0+'), '');
  if (c.length < 13) c = c.padLeft(13, '0');
  if (c.length == 13 && c.startsWith('00000')) c = c.substring(5);
  return c;
}

/// The code to look up for a scanned or typed [barcode], or `null` if it is
/// not a valid barcode.
///
/// 1. Only digits (surrounding spaces are ignored).
/// 2. Length 8, 12, 13 or 14 with a correct check digit.
/// 3. An 8-digit code that is not a valid EAN-8 but a valid UPC-E is expanded
///    to UPC-A.
/// 4. The result is normalised like Open Food Facts ([normalizeLikeOff]).
String? lookupCodeFor(String barcode) {
  final code = barcode.trim();
  if (isValidGtin(code)) return normalizeLikeOff(code);
  if (code.length == 8) {
    final upcA = expandUpcE(code);
    if (upcA != null) return normalizeLikeOff(upcA);
  }
  return null;
}

/// The code to look up for a barcode that comes from Open Food Facts itself
/// (a search hit, or a product stored from there): only normalised
/// ([normalizeLikeOff]), not checked, or `null` if it is not digits only.
///
/// The scanner rules of [lookupCodeFor] do not fit such codes: OFF also
/// lists products under codes with a wrong check digit, and an 8-digit code
/// there is the product's code, not a UPC-E to expand – the strict rules
/// would refuse the hit or ask for another product.
String? trustedLookupCode(String barcode) {
  final code = barcode.trim();
  return isDigitsOnly(code) ? normalizeLikeOff(code) : null;
}
