@TestOn('js')
library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/ip_address_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:test/test.dart';

import '../sodium_js_mock.dart';

void main() {
  final mockSodium = MockLibSodiumJS();

  setUpAll(() {
    registerFallbackValue(Uint8List(0).toJS);
  });

  setUp(() {
    reset(mockSodium);
  });

  group('IpAddressJS', () {
    group('fromString', () {
      test('calls sodium_ip2bin and returns IpAddressJS with result bytes', () {
        final ipData = List.generate(16, (i) => i + 1);

        when(
          () => mockSodium.sodium_ip2bin(any()),
        ).thenReturn(Uint8List.fromList(ipData).toJS);

        final result = IpAddressJS.fromString(
          mockSodium.asLibSodiumJS,
          '192.168.0.1',
        );

        expect(result.bytes, ipData);
        verify(() => mockSodium.sodium_ip2bin('192.168.0.1'));
      });

      test('throws SodiumException when sodium_ip2bin throws JSError', () {
        when(() => mockSodium.sodium_ip2bin(any())).thenThrow(JSError());

        expect(
          () => IpAddressJS.fromString(mockSodium.asLibSodiumJS, 'invalid'),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('fromBytes', () {
      test('throws RangeError if bytes length is less than 16', () {
        expect(
          () => IpAddressJS.fromBytes(mockSodium.asLibSodiumJS, Uint8List(10)),
          throwsA(isA<RangeError>()),
        );
      });

      test('throws RangeError if bytes length is greater than 16', () {
        expect(
          () => IpAddressJS.fromBytes(mockSodium.asLibSodiumJS, Uint8List(17)),
          throwsA(isA<RangeError>()),
        );
      });

      test('returns IpAddressJS with correct bytes for 16-byte input', () {
        final bytes = Uint8List.fromList(List.generate(16, (i) => i + 10));

        final result = IpAddressJS.fromBytes(mockSodium.asLibSodiumJS, bytes);

        expect(result.bytes, bytes);
      });
    });

    group('bytes', () {
      test('returns rawBytes as Dart Uint8List', () {
        final ipData = List.generate(16, (i) => i + 5);
        final sut = IpAddressJS.fromJsBytes(
          mockSodium.asLibSodiumJS,
          Uint8List.fromList(ipData).toJS,
        );

        expect(sut.bytes, ipData);
      });
    });

    group('addressString', () {
      test('calls sodium_bin2ip with rawBytes and returns string', () {
        const ipString = '192.168.0.1';
        final jsBytes = Uint8List(16).toJS;

        when(() => mockSodium.sodium_bin2ip(any())).thenReturn(ipString);

        final sut = IpAddressJS.fromJsBytes(mockSodium.asLibSodiumJS, jsBytes);

        expect(sut.addressString, ipString);
        verify(() => mockSodium.sodium_bin2ip(jsBytes));
      });

      test('throws SodiumException when sodium_bin2ip throws JSError', () {
        when(() => mockSodium.sodium_bin2ip(any())).thenThrow(JSError());

        final sut = IpAddressJS.fromJsBytes(
          mockSodium.asLibSodiumJS,
          Uint8List(16).toJS,
        );

        expect(() => sut.addressString, throwsA(isA<SodiumException>()));
      });
    });

    group('address', () {
      test('returns addressString as String on JS platform', () {
        const ipString = '::1';

        when(() => mockSodium.sodium_bin2ip(any())).thenReturn(ipString);

        final sut = IpAddressJS.fromJsBytes(
          mockSodium.asLibSodiumJS,
          Uint8List(16).toJS,
        );

        expect(sut.address, ipString);
      });
    });

    group('equality', () {
      test('equal instances for same bytes', () {
        final bytes = Uint8List.fromList(List.generate(16, (i) => i));

        expect(
          IpAddressJS.fromJsBytes(mockSodium.asLibSodiumJS, bytes.toJS),
          IpAddressJS.fromJsBytes(mockSodium.asLibSodiumJS, bytes.toJS),
        );
      });

      test('not equal for different bytes', () {
        expect(
          IpAddressJS.fromJsBytes(
            mockSodium.asLibSodiumJS,
            Uint8List.fromList(List.generate(16, (i) => i)).toJS,
          ),
          isNot(
            IpAddressJS.fromJsBytes(
              mockSodium.asLibSodiumJS,
              Uint8List.fromList(List.generate(16, (i) => i + 1)).toJS,
            ),
          ),
        );
      });
    });

    group('toString', () {
      test('returns addressString', () {
        const ipString = '::1';

        when(() => mockSodium.sodium_bin2ip(any())).thenReturn(ipString);

        final sut = IpAddressJS.fromJsBytes(
          mockSodium.asLibSodiumJS,
          Uint8List(16).toJS,
        );

        expect(sut.toString(), ipString);
      });
    });
  });
}
