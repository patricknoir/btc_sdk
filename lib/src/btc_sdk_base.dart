// TODO: Put public facing types in this file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';
import 'package:fast_base58/fast_base58.dart';
import 'package:hex/hex.dart';

import 'model/binary/uint.dart';

/// Enable a [BigInt] type to be converted in a list of bytes as [Uint8List].
extension BigIntExtensions on BigInt {

  /// Convert the current [BigInt] in a [Uint8List]
  Uint8List get toUint8List => toRadixString(16).toUint8ListFromHex!;

}

/// Provides conversion functions to get a String representation of a number value with a specific encoding to be transformed into a [Uint8List].
/// This extension will help to convert from Hex, Base58, UTF8 to the equivalent [Uint8List].
extension StringExtensions on String {

  /// Nullable converter that taken a [String] containing the **HEX** representation of a number, will return the equivalent [Uint8List].
  Uint8List? get toUint8ListFromHex {
    try {
      return HEX.decode(this).toUint8List;
    } catch(exception) {
      return null;
    }
  }

  /// Nullable converter that taken a [String] containing the [**Base58**](../docs/binary/BytesArrayAlgebra.md) representation of a number, will return the equivalent [Uint8List].
  Uint8List? get toUint8ListFromBase58 {
    try {
      return Base58Decode(this).toUint8List;
    } catch(exception) {
      return null;
    }
  }

  /// Converter that taken a [String] containing the **HEX** representation of a number, will return the equivalent [Uint8List].
  Uint8List get toUint8ListFromUtf8 => utf8.encode(this).toUint8List;
}

extension ListIntExtensions on List<int> {
  Uint8List get toUint8List => Uint8List.fromList(this);
}

extension Uint8ListExtensions on Uint8List {
  Uint8List concat(Uint8List other) {
    Uint8List list = Uint8List(length + other.length);
    list.setRange(0, length, this);
    list.setRange(length, list.length, other);
    return list;
  }

  /// It returns a nullable if the argument is a negative value.
  Uint8List? appendInt(int value) {
    Uint8List? element = value.toUint?.toUint8List;
    if(element != null) {
      return concat(element);
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

  String get toBinaryString => map((byte) => byte.toRadixString(2).padLeft(8, '0')).join('');

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
  Uint8List to16Bits({Endian endian = Endian.big}) {
    final Uint8List result = Uint8List(2);
    result.buffer.asByteData().setUint16(0, this, endian);
    return result;
  }

  /// Convert an integer value into a Uint8List. If the value is bigger than uint32 the most significant bits are be truncated.
  Uint8List to32Bits({Endian endian = Endian.big}) {
    final Uint8List result = Uint8List(4);
    result.buffer.asByteData().setUint32(0, this, endian);
    return result;
  }

  /// Convert an integer value into a Uint8List.
  Uint8List to64Bits({Endian endian = Endian.big}) {
    final Uint8List result = Uint8List(8);
    result.buffer.asByteData().setUint64(0, this, endian);
    return result;
  }

  /// Return the Hex String representation for this int value.
  String get toHex => HEX.encode(Uint(this).toUint8List);
}

extension PublicKeyToAddress on PublicKey {
  Address toAddress({Network network = Network.mainnet, bool compress = false}) => Address(network, toPublicKeyHash(compress: compress));
}