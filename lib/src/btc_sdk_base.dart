// TODO: Put public facing types in this file.

import 'dart:typed_data';

import 'package:fast_base58/fast_base58.dart';
import 'package:hex/hex.dart';

import 'model/uint.dart';

/// Checks if you are awesome. Spoiler: you are.
class Awesome {
  bool get isAwesome => true;
}

extension StringExtensions on String {
  Uint8List? get fromHex {
    try {
      return HEX.decode(this).toUint8List;
    } catch(exception) {
      return null;
    }
  }

  Uint8List? get fromBase58 {
    try {
      return Base58Decode(this).toUint8List;
    } catch(exception) {
      return null;
    }
  }
}

extension ListIntConvertible on List<int> {
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

  String get toHex => HEX.encode(this);
  String get toBase58 => Base58Encode(this);
}

/// Utility extension for int to convert into Uint8List with different Endian options.
extension BtcUtil on int {
  Uint8List to8Bits() {
    final Uint8List result = Uint8List(1);
    result.buffer.asByteData().setUint8(0, this);
    return result;
  }
  Uint8List to16Bits({Endian endian = Endian.little}) {
    final Uint8List result = Uint8List(2);
    result.buffer.asByteData().setUint16(0, this, endian);
    return result;
  }
  Uint8List to32Bits({Endian endian = Endian.little}) {
    final Uint8List result = Uint8List(4);
    result.buffer.asByteData().setUint32(0, this, endian);
    return result;
  }
  Uint8List to64Bits({Endian endian = Endian.little}) {
    final Uint8List result = Uint8List(8);
    result.buffer.asByteData().setUint64(0, this, endian);
    return result;
  }
}