// ignore_for_file: unnecessary_lambdas to catch member access errors

@TestOn('dart-vm')
library;

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/ip_address_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.wrapper.dart';
import 'package:sodium/src/ffi/bindings/sodium_pointer.dart';
import 'package:test/test.dart';

import '../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);
    mockAllocArray(mockSodium);
    when(() => mockSodium.sodium_memzero(any(), any())).thenAnswer((_) {});
  });

  group('IpAddressFFI', () {
    group('constructor (from InternetAddress)', () {
      test('delegates to parse for IPv4 address', () {
        when(() => mockSodium.sodium_ip2bin(any(), any(), any())).thenReturn(0);

        IpAddressFFI(mockSodium, InternetAddress('192.168.1.1'));

        verify(() => mockSodium.sodium_ip2bin(any(), any(), any()));
      });

      test('uses raw address bytes for IPv6 address', () {
        final addr = InternetAddress('::1');

        final result = IpAddressFFI(mockSodium, addr);

        expect(result.bytes, addr.rawAddress);
      });
    });

    group('parse', () {
      test('calls sodium_ip2bin with correct pointer arguments', () {
        when(() => mockSodium.sodium_ip2bin(any(), any(), any())).thenReturn(0);

        IpAddressFFI.parse(mockSodium, '192.168.0.1');

        verify(
          () => mockSodium.sodium_ip2bin(
            any(that: isNot(nullptr)),
            any(that: hasRawData(utf8.encode('192.168.0.1'))),
            11,
          ),
        );
      });

      test('returns IpAddressFFI with bytes written by sodium_ip2bin', () {
        final ipData = List.generate(16, (i) => i + 1);

        when(() => mockSodium.sodium_ip2bin(any(), any(), any())).thenAnswer((
          i,
        ) {
          fillPointer(
            i.positionalArguments[0] as Pointer<UnsignedChar>,
            ipData,
          );
          return 0;
        });

        final result = IpAddressFFI.parse(mockSodium, '192.168.0.1');

        expect(result.rawBytes.asListView<Uint8List>(), ipData);
      });

      test('throws SodiumException when sodium_ip2bin returns non-zero', () {
        when(
          () => mockSodium.sodium_ip2bin(any(), any(), any()),
        ).thenReturn(-1);

        expect(
          () => IpAddressFFI.parse(mockSodium, 'invalid'),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('fromRawBytes', () {
      test('throws RangeError if bytes length is less than 16', () {
        expect(
          () => IpAddressFFI.fromRawBytes(mockSodium, Uint8List(10)),
          throwsA(isA<RangeError>()),
        );
      });

      test('throws RangeError if bytes length is greater than 16', () {
        expect(
          () => IpAddressFFI.fromRawBytes(mockSodium, Uint8List(17)),
          throwsA(isA<RangeError>()),
        );
      });

      test('returns IpAddressFFI with correct bytes for 16-byte input', () {
        final bytes = Uint8List.fromList(List.generate(16, (i) => i + 10));

        final result = IpAddressFFI.fromRawBytes(mockSodium, bytes);

        expect(result.rawBytes.asListView<Uint8List>(), bytes);
      });
    });

    group('bytes', () {
      test('returns copy of raw pointer data as Uint8List', () {
        final ipData = List.generate(16, (i) => i + 5);
        final ptr = SodiumPointer<UnsignedChar>.alloc(mockSodium, count: 16);
        fillPointer(ptr.ptr, ipData);

        final sut = IpAddressFFI.fromPointer(mockSodium, ptr);
        final bytes = sut.bytes;
        fillPointer(ptr.ptr, Uint8List(16));

        expect(bytes, ipData);
      });
    });

    group('addressString', () {
      test('calls sodium_bin2ip with correct arguments', () {
        when(
          () => mockSodium.sodium_bin2ip(any(), any(), any()),
        ).thenReturn(SodiumPointer<Char>.alloc(mockSodium, count: 2).ptr);

        final ptr = SodiumPointer<UnsignedChar>.alloc(mockSodium, count: 16);
        final sut = IpAddressFFI.fromPointer(mockSodium, ptr);

        expect(() => sut.addressString, returnsNormally);

        verify(
          () => mockSodium.sodium_bin2ip(
            any(that: isNot(nullptr)),
            46,
            any(that: same(ptr.ptr)),
          ),
        );
      });

      test('returns string from sodium_bin2ip', () {
        const ipString = '192.168.0.1';

        when(() => mockSodium.sodium_bin2ip(any(), any(), any())).thenAnswer((
          i,
        ) {
          final strPtr = i.positionalArguments[0] as Pointer<Char>;
          fillPointer(strPtr, utf8.encode(ipString));
          return strPtr;
        });

        final ptr = SodiumPointer<UnsignedChar>.alloc(mockSodium, count: 16);
        final sut = IpAddressFFI.fromPointer(mockSodium, ptr);

        expect(sut.addressString, ipString);
      });

      test('throws SodiumException when sodium_bin2ip returns nullptr', () {
        when(
          () => mockSodium.sodium_bin2ip(any(), any(), any()),
        ).thenReturn(nullptr);

        final ptr = SodiumPointer<UnsignedChar>.alloc(mockSodium, count: 16);
        final sut = IpAddressFFI.fromPointer(mockSodium, ptr);

        expect(() => sut.addressString, throwsA(isA<SodiumException>()));
      });
    });

    group('address', () {
      test('returns InternetAddress with matching raw bytes', () {
        final bytes = InternetAddress('::1').rawAddress;

        final sut = IpAddressFFI.fromRawBytes(mockSodium, bytes);

        expect(sut.address, isA<InternetAddress>());
        expect((sut.address as InternetAddress).rawAddress, bytes);
      });
    });

    group('equality', () {
      test('equal instances for same bytes', () {
        final bytes = Uint8List.fromList(List.generate(16, (i) => i));

        expect(
          IpAddressFFI.fromRawBytes(mockSodium, bytes),
          IpAddressFFI.fromRawBytes(mockSodium, bytes),
        );
      });

      test('not equal for different bytes', () {
        expect(
          IpAddressFFI.fromRawBytes(
            mockSodium,
            Uint8List.fromList(List.generate(16, (i) => i)),
          ),
          isNot(
            IpAddressFFI.fromRawBytes(
              mockSodium,
              Uint8List.fromList(List.generate(16, (i) => i + 1)),
            ),
          ),
        );
      });
    });

    group('toString', () {
      test('returns addressString', () {
        const ipString = '::1';

        when(() => mockSodium.sodium_bin2ip(any(), any(), any())).thenAnswer((
          i,
        ) {
          final strPtr = i.positionalArguments[0] as Pointer<Char>;
          for (var j = 0; j < ipString.length; j++) {
            (strPtr + j).value = ipString.codeUnitAt(j);
          }
          (strPtr + ipString.length).value = 0;
          return strPtr;
        });

        final ptr = SodiumPointer<UnsignedChar>.alloc(mockSodium, count: 16);

        expect(IpAddressFFI.fromPointer(mockSodium, ptr).toString(), ipString);
      });
    });
  });
}
