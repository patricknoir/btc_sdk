import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';
import 'package:btc_sdk/src/model/var_int.dart';

/// This class is used to perform manipulation of array of bytes represented as Uint8List.
class Buffer {
  late Uint8List _internal;

  /// Create a new buffer instance. Optionally an initial value can be specified, otherwise it will create an empty buffer.
  Buffer({Uint8List? initial}) {
    _internal = initial ?? Uint8List(0);
  }

  /// Return the content of the buffer as a Uint8List
  Uint8List get toUint8List => _internal;
  /// Return the current length of the buffer in bytes.
  int get length => _internal.length;

  bool get isEmpty => _internal.isEmpty;
  bool get isNotEmpty => _internal.isNotEmpty;

  /// Append another array of bytes represented as Uint8List to the current buffer.
  void append(Uint8List element) {
    _internal = _internal.concat(element);
  }
  /// Alias for the method append
  void operator +(Uint8List element) => append(element);

  /// Export a segment from the buffer as a Uint8List, if the segment is requested as [Endian.big]
  /// the list will be reversed.
  Uint8List inspectSegment(int end, {int start = 0, Endian endian = Endian.little}) {
    Uint8List result = _internal.sublist(start, end);
    if(endian == Endian.big) {
      result = result.reversed.toList().toUint8List;
    }
    return result;
  }

  /// Extract a segment from the Buffer. If endian is [Endian.big] the segment will be reverted.
  /// The buffer is modified with the extracted segment removed.
  Uint8List pullSegment(int end, {int start = 0, Endian endian = Endian.little}) {
    Uint8List result = inspectSegment(start: start, end, endian: endian);
    _internal = _internal.sublist(0, start).concat(_internal.sublist(end));
    return result;
  }

  /// Append a specific VarInt field passed as input to the end of this buffer.
  void appendVarInt(VarInt field) => append(field.toUint8List);

  /// Parse end return the VarInt field from the specificed start position from this buffer.
  /// This operation doesn't modify the buffer content.
  VarInt inspectVarInt({int start = 0}) => VarInt.parse(_internal.sublist(start));

  /// Extract a parsed VarInt from the buffer at the start position specified.
  /// Once the VarInt is returned the field is also removed from the buffer.
  VarInt pullVarInt({int start = 0}) {
    VarInt varint = inspectVarInt(start: start);
    _internal = _internal.sublist(0, start).concat(_internal.sublist(VarInt.varIntSize(varint.flag)));
    return varint;
  }


  /// Append the passed [value] as a single byte into the buffer.
  ///
  /// In other words, [value] must be between 0 and 255, inclusive.
  void appendUint8(int value) {
    append(value.to8Bits());
  }

  /// Expose the first byte from the Buffer without modifying the buffer content.
  int inspectUint8() => _internal[0];


  /// Extract the first byte from the buffer, after this operation the buffer content will be modified and the pulled element will be removed from the head.
  /// It throws an error if the Buffer is empty.
  int pullUint8() {
    int value = _internal[0];
    _internal = _internal.sublist(1);
    return value;
  }

  /// Append 2 bytes integer value to the buffer. It reverse the appending value if Endian type is [Endian.big]
  void appendUint16(int value, {Endian endian = Endian.little}) => this + value.to16Bits(endian: endian);

  /// Expose the first 2 bytes of the buffer as an integer value. Reverse the 2 bytes if the Endian specificed is [Endian.big].
  /// The buffer will suffer no changes with this operation.
  /// It throws an error if the Buffer size is smaller than 2 bytes.
  int inspectUint16({Endian endian = Endian.little}) => _internal.buffer.asByteData().getUint16(0, endian);

  /// Extract the first 2 bytes of the buffer as an integer value. Reverse the 2 bytes if the Endian specificed is [Endian.big].
  /// The buffer will be modified after this operation, and the first 2 bytes will be removed.
  /// It throws an error if the Buffer size is smaller than 2 bytes.
  int pullUint16({Endian endian = Endian.little}) {
    int value = inspectUint16(endian: endian);
    _internal = _internal.sublist(2);
    return value;
  }

  /// Append 4 bytes integer value to the buffer. It reverse the appending value if Endian type is [Endian.big]
  void appendUint32(int value, {Endian endian = Endian.little}) => this + value.to32Bits(endian: endian);

  /// Expose the first 4 bytes of the buffer as an integer value. Reverse the 4 bytes if the Endian specificed is [Endian.big].
  /// The buffer will suffer no changes with this operation.
  /// It throws an error if the Buffer size is smaller than 4 bytes.
  int inspectUint32({Endian endian = Endian.little}) => _internal.buffer.asByteData().getUint32(0, endian);

  /// Extract the first 4 bytes of the buffer as an integer value. Reverse the 4 bytes if the Endian specificed is [Endian.big].
  /// The buffer will be modified after this operation, and the first 4 bytes will be removed.
  /// It throws an error if the Buffer size is smaller than 4 bytes.
  int pullUint32({Endian endian = Endian.little}) {
    int value = inspectUint32(endian: endian);
    _internal = _internal.sublist(4);
    return value;
  }

  /// Append 8 bytes integer value to the buffer. It reverse the appending value if Endian type is [Endian.big]
  void appendUint64(int value, {Endian endian = Endian.little}) => this + value.to64Bits(endian: endian);

  /// Expose the first 8 bytes of the buffer as an integer value. Reverse the 8 bytes if the Endian specificed is [Endian.big].
  /// The buffer will suffer no changes with this operation.
  /// It throws an error if the Buffer size is smaller than 8 bytes
  int inspectUint64({Endian endian = Endian.little}) => _internal.buffer.asByteData().getUint64(0, endian);

  /// Extract the first 8 bytes of the buffer as an integer value. Reverse the 8 bytes if the Endian specificed is [Endian.big].
  /// The buffer will be modified after this operation, and the first 8 bytes will be removed.
  /// It throws an error if the Buffer size is smaller than 8 bytes.
  int pullUint64({Endian endian = Endian.little}) {
    int value = inspectUint64(endian: endian);
    _internal = _internal.sublist(8);
    return value;
  }

  /// Show the buffer content with its HEX String representation
  String get toHex => _internal.toHex;

  /// Show the buffer content with its Base58 String representation
  String get toBase58 => _internal.toBase58;
}