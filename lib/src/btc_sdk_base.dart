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

  /// Compares two [Uint8List]s by comparing 8 bytes at a time.
  ///
  /// This is an alias for the method [memEquals].
  bool compare(Uint8List other) => memEquals(other);

  /// Compares two [Uint8List]s by comparing 8 bytes at a time.
  bool memEquals(Uint8List bytes2) {
    Uint8List bytes1 = this;
    if (identical(bytes1, bytes2)) {
      return true;
    }

    if (bytes1.lengthInBytes != bytes2.lengthInBytes) {
      return false;
    }

    // Treat the original byte lists as lists of 8-byte words.
    var numWords = bytes1.lengthInBytes ~/ 8;
    var words1 = bytes1.buffer.asUint64List(0, numWords);
    var words2 = bytes2.buffer.asUint64List(0, numWords);

    for (var i = 0; i < words1.length; i += 1) {
      if (words1[i] != words2[i]) {
        return false;
      }
    }

    // Compare any remaining bytes.
    for (var i = words1.lengthInBytes; i < bytes1.lengthInBytes; i += 1) {
      if (bytes1[i] != bytes2[i]) {
        return false;
      }
    }

    return true;
  }
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