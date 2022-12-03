import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';

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

  /// Export a segment from the buffer as a Uint8List, if the segment is requested as Endian.little
  /// the list will be reversed.
  Uint8List inspectSegment(int start, int end, {Endian endian = Endian.big}) {
    Uint8List result = _internal.sublist(start, end);
    if(endian == Endian.little) {
      result = result.reversed.toList().toUint8List;
    }
    return result;
  }

  /// Append the passed [value] as a single byte into the buffer.
  ///
  /// In other words, [value] must be between 0 and 255, inclusive.
  void appendUint8(int value) {
    append(value.to8Bits());
  }

  /// Expose the first byte from the Buffer without modifying the buffer content. Returns null if the buffer is empty.
  int? inspectUint8() {
    if(_internal.isEmpty) {
      return null;
    } else {
      return _internal[0];
    }
  }

  /// Extract the first byte from the buffer, after this operation the buffer content will be modified and the pulled element will be removed from the head.
  /// It throws an error if the Buffer is empty.
  int pullUint8() {
    int value = _internal[0];
    _internal = _internal.sublist(1);
    return value;
  }

  /// Append 2 bytes integer value to the buffer. It reverse the appending value if Endian type is [Endian.little]
  void appendUint16(int value, {Endian endian = Endian.big}) => this + value.to16Bits(endian: endian);

  /// Expose the first 2 bytes of the buffer as an integer value. Reverse the 2 bytes if the Endian specificed is [Endian.little].
  /// The buffer will suffer no changes with this operation.
  /// It throws an error if the Buffer size is smaller than 2 bytes.
  int inspectUint16({Endian endian = Endian.big}) => _internal.buffer.asByteData().getUint16(0, endian);

  /// Extract the first 2 bytes of the buffer as an integer value. Reverse the 2 bytes if the Endian specificed is [Endian.little].
  /// The buffer will be modified after this operation, and the first 2 bytes will be removed.
  /// It throws an error if the Buffer size is smaller than 2 bytes.
  int pullUint16({Endian endian = Endian.big}) {
    int value = inspectUint16(endian: endian);
    _internal = _internal.sublist(2);
    return value;
  }

  /// Append 4 bytes integer value to the buffer. It reverse the appending value if Endian type is [Endian.little]
  void appendUint32(int value, {Endian endian = Endian.big}) => this + value.to32Bits(endian: endian);

  /// Expose the first 4 bytes of the buffer as an integer value. Reverse the 4 bytes if the Endian specificed is [Endian.little].
  /// The buffer will suffer no changes with this operation.
  /// It throws an error if the Buffer size is smaller than 4 bytes.
  int inspectUint32({Endian endian = Endian.big}) => _internal.buffer.asByteData().getUint32(0, endian);

  /// Extract the first 4 bytes of the buffer as an integer value. Reverse the 4 bytes if the Endian specificed is [Endian.little].
  /// The buffer will be modified after this operation, and the first 4 bytes will be removed.
  /// It throws an error if the Buffer size is smaller than 4 bytes.
  int pullUint32({Endian endian = Endian.big}) {
    int value = inspectUint32(endian: endian);
    _internal = _internal.sublist(4);
    return value;
  }

  /// Append 8 bytes integer value to the buffer. It reverse the appending value if Endian type is [Endian.little]
  void appendUint64(int value, {Endian endian = Endian.big}) => this + value.to64Bits(endian: endian);

  /// Expose the first 8 bytes of the buffer as an integer value. Reverse the 8 bytes if the Endian specificed is [Endian.little].
  /// The buffer will suffer no changes with this operation.
  /// It throws an error if the Buffer size is smaller than 8 bytes
  int inspectUint64({Endian endian: Endian.big}) => _internal.buffer.asByteData().getUint64(0, endian);

  /// Extract the first 8 bytes of the buffer as an integer value. Reverse the 8 bytes if the Endian specificed is [Endian.little].
  /// The buffer will be modified after this operation, and the first 8 bytes will be removed.
  /// It throws an error if the Buffer size is smaller than 8 bytes.
  int pullUint64({Endian endian = Endian.big}) {
    int value = inspectUint64(endian: endian);
    _internal = _internal.sublist(8);
    return value;
  }

  /// Show the buffer content with its HEX String representation
  String get toHex => _internal.toHex;

  /// Show the buffer content with its Base58 String representation
  String get toBase58 => _internal.toBase58;
}