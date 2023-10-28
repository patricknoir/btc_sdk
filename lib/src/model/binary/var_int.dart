import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// A VarInt or "Variable Integer" is an integer format used widely in Bitcoin to indicate the lengths of fields within transaction, block and peer-to-peer network data.
///
/// A VarInt is a variable length field 1, 3, 5 or 9 bytes in length dependent on the size of the object being defined. The VarInt format is used as it is space efficient over simply using an 8-byte field where variable length objects are used.
class VarInt extends Equatable {

  static bool isValid(int flag, Uint8List value) {
    switch(flag) {
      case 0xFD:
        return value.length == 1;
      case 0xFC:
        return value.length == 2;
      case 0xFE:
        return value.length == 4;
      case 0xFF:
        return value.length == 8;
      default:
        return (flag < 0xFD) ? value.length == 1 : false;
    }
  }

  final int flag;
  final int value;

  /// Private constructor of VarInt, used by the factory methods only.
  const VarInt._({required this.flag, required this.value});

  /// Given an Array of Bytes, parse it and create a VarInt instance from the specified starting index.
  ///
  /// If not provided the start index is the beginning of the array.
  factory VarInt.parse(Uint8List data, {int start = 0})  {
    assert(data.isNotEmpty && data.length > start);
    final segment = data.sublist(start);
    final int firstByte = segment.buffer.asByteData().getUint8(0);
    switch(firstByte) {
      case 0xFD: return VarInt._(value: segment.buffer.asByteData().getInt16(1), flag: firstByte);
      case 0xFE: return VarInt._(value: segment.buffer.asByteData().getInt32(1), flag: firstByte);
      case 0xFF: return VarInt._(value: segment.buffer.asByteData().getInt64(1), flag: firstByte);
      default: return VarInt._(value: firstByte, flag: firstByte);
    }
  }

  /// Given an integer value this will be converted into a VarInt.
  factory VarInt.fromValue(int value) {
    if(value <= 0xFC) {
      return VarInt._(value: value, flag: value);
    } else if(value <= 0xFFFF) {
      return VarInt._(value: value, flag: 0xFD);
    } else if(value <= 0xFFFFFFFF) {
      return VarInt._(value: value, flag: 0xFE);
    } else {
      return VarInt._(value: value, flag: 0xFF);
    }
  }

  /// Converts the VarInt into a Uint8List with the flag prefixing the field value.
  Uint8List get toUint8List {
    final length = varIntSize(flag);
    final result = Uint8List(length);
    switch(flag) {
      case 0xFD:
        result.buffer.asByteData().setUint8(0, flag);
        result.buffer.asByteData().setUint16(1, value);
        break;
      case 0xFE:
        result.buffer.asByteData().setUint8(0, flag);
        result.buffer.asByteData().setUint32(1, value);
        break;
      case 0xFF:
        result.buffer.asByteData().setUint8(0, flag);
        result.buffer.asByteData().setUint64(1, value);
        break;
      default:
        result.buffer.asByteData().setUint8(0, value);
        break;
    }
    return result;
  }

  /// The first Byte of a Uint8List of type VarInt, defines the size of the Segment associated.
  static int varIntSize(int flag) {
    switch(flag) {
      case 0xFD: return 3;
      case 0xFE: return 5;
      case 0xFF: return 9;
      default: return 1;
    }
  }

  @override
  List<Object?> get props => [flag, value];
}