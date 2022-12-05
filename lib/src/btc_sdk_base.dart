// TODO: Put public facing types in this file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:fast_base58/fast_base58.dart';
import 'package:hex/hex.dart';

import 'model/binary/uint.dart';

extension BigIntExtensions on BigInt {

  /// Convert the current [BigInt] in a [Uint8List]
  Uint8List get toUint8List => toRadixString(16).toUint8ListFromHex!;

}

extension StringExtensions on String {
  Uint8List? get toUint8ListFromHex {
    try {
      return HEX.decode(this).toUint8List;
    } catch(exception) {
      return null;
    }
  }

  Uint8List? get toUint8ListFromBase58 {
    try {
      return Base58Decode(this).toUint8List;
    } catch(exception) {
      return null;
    }
  }

  Uint8List get toUint8ListFromUtf8 => utf8.encode(this).toUint8List;
}

extension ListIntExtensions on List<int> {
  Uint8List get toUint8List => Uint8List.fromList(this);
}

extension Uint8ListExtensions on Uint8List {
  Uint8List concat(Uint8List other) {
    return (this + other).toUint8List;
  }

  /// It returns a nullable if the argument is a negative value.
  Uint8List? appendInt(int value) {
    Uint8List? element = value.toUint?.toUint8List;
    if(element != null) {
      return concat(element!);
    }
    return null;
  }

  /// Return the Hex String representation for the current [Uint8List]
  String get toHex => HEX.encode(this);

  /// Return the Base58 String representation for the current [Uint8List]
  String get toBase58 => Base58Encode(this);

  /// Return the [BigInt] value associated to the current [Uint8List]
  BigInt get toBigInt => BigInt.parse(toHex, radix: 16);
}

/// Utility extension for int to convert into Uint8List with different Endian options.
extension IntExtensions on int {
  /// Convert an integer value into a Uint8List. If the value is bigger than uint8 the most significant bits are be truncated.
  Uint8List to8Bits() {
    final Uint8List result = Uint8List(1);
    result.buffer.asByteData().setUint8(0, this);
    return result;
  }

  /// Convert an integer value into a Uint8List. If the value is bigger than uint16 the most significant bits are be truncated.
  Uint8List to16Bits({Endian endian = Endian.little}) {
    final Uint8List result = Uint8List(2);
    result.buffer.asByteData().setUint16(0, this, endian);
    return result;
  }

  /// Convert an integer value into a Uint8List. If the value is bigger than uint32 the most significant bits are be truncated.
  Uint8List to32Bits({Endian endian = Endian.little}) {
    final Uint8List result = Uint8List(4);
    result.buffer.asByteData().setUint32(0, this, endian);
    return result;
  }

  /// Convert an integer value into a Uint8List.
  Uint8List to64Bits({Endian endian = Endian.little}) {
    final Uint8List result = Uint8List(8);
    result.buffer.asByteData().setUint64(0, this, endian);
    return result;
  }

  /// Return the Hex String representation for this int value.
  String get toHex => HEX.encode(Uint(this).toUint8List);
}