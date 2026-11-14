import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/features/products/gtin.dart';

void main() {
  group('isValidGtin', () {
    test('accepts the codes from the brief', () {
      for (final code in [
        '3017624010701', // EAN-13
        '4001686301265',
        '5449000000996',
        '42376095', // EAN-8
        '036000291452', // UPC-A
      ]) {
        expect(isValidGtin(code), isTrue, reason: code);
      }
    });

    test('rejects a wrong check digit', () {
      expect(isValidGtin('3017624010702'), isFalse);
    });

    test('rejects letters, spaces and unsupported lengths', () {
      expect(isValidGtin('abc'), isFalse);
      expect(isValidGtin('4001 686301265'), isFalse);
      expect(isValidGtin(''), isFalse);
      expect(isValidGtin('1234567'), isFalse); // 7 digits
      expect(isValidGtin('123456789012345'), isFalse); // 15 digits
    });

    test('accepts a GTIN-14', () {
      // 1 + an EAN-13 body, check digit computed with the GS1 rule.
      expect(computeCheckDigit('1300176240107'), 8);
      expect(isValidGtin('13001762401078'), isTrue);
    });
  });

  test('computeCheckDigit follows the GS1 rule', () {
    expect(computeCheckDigit('301762401070'), 1);
    expect(computeCheckDigit('4237609'), 5);
  });

  group('expandUpcE', () {
    test('expands the brief example', () {
      expect(expandUpcE('04252614'), '042100005264');
    });

    test('covers every rule of the last digit', () {
      // Last compressed digit 0–2, 3, 4 and 5–9 put the zeros elsewhere.
      expect(expandUpcE('01234505'), '012000003455');
      expect(expandUpcE('01234531'), '012300000451');
      expect(expandUpcE('01234543'), '012340000053');
      expect(expandUpcE('01234558'), '012345000058');
    });

    test('returns null for anything that is not UPC-E', () {
      expect(expandUpcE('24252614'), isNull); // number system 2
      expect(expandUpcE('0425261'), isNull); // 7 digits
      expect(expandUpcE('04252615'), isNull); // wrong check digit
    });
  });

  group('normalizeLikeOff', () {
    test('pads to 13 digits and shortens 00000-codes to 8', () {
      expect(normalizeLikeOff('036000291452'), '0036000291452');
      expect(normalizeLikeOff('0000042376095'), '42376095');
      expect(normalizeLikeOff('42376095'), '42376095');
      expect(normalizeLikeOff('5449000000996'), '5449000000996');
    });

    test('leaves other text unchanged', () {
      expect(normalizeLikeOff('abc'), 'abc');
    });
  });

  group('lookupCodeFor', () {
    test('normalises valid codes', () {
      expect(lookupCodeFor('5449000000996'), '5449000000996');
      expect(lookupCodeFor(' 036000291452 '), '0036000291452');
      expect(lookupCodeFor('0000042376095'), '42376095');
    });

    test('an 8-digit UPC-E becomes the normalised UPC-A', () {
      expect(isValidGtin('04252614'), isFalse); // not a valid EAN-8
      expect(lookupCodeFor('04252614'), '0042100005264');
    });

    test('a valid EAN-8 stays EAN-8 (no UPC-E expansion)', () {
      expect(lookupCodeFor('42376095'), '42376095');
    });

    test('invalid codes give null', () {
      expect(lookupCodeFor('3017624010702'), isNull);
      expect(lookupCodeFor('abc'), isNull);
      expect(lookupCodeFor(''), isNull);
    });
  });
}
