import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';

class Uint8ListReader {
  final Uint8List data;

  int _currentPosition = 0;

  int get currentPosition => _currentPosition;

  Uint8ListReader(this.data);

  Uint8List readSegment(int bytes) {
    // if the current position is over the data length, return an empty list
    if(_currentPosition >= data.length) {
      _currentPosition = data.length;
      return Uint8List(0);
    }
    // if the current position plus the bytes exceed the data length, return all the remaining data from the current position
    if(_currentPosition + bytes >= data.length) {
      _currentPosition = data.length;
      return data.sublist(_currentPosition).toUint8List;
    }

    final Uint8List result = data.getRange(_currentPosition, _currentPosition + bytes).toList().toUint8List;
    _currentPosition += bytes;
    return result;
  }

  /// Return an integer representation of a Uint32 (Uint8List(4)), the value will be converted using the little endian representation if
  /// specified via the input parameters, otherwise will read in big endian notation if not specified.
  int readUint32({bool littleEndian = false}) {
    Uint8List result = readSegment(4);
    if (result.isEmpty) {
      return -1;
    }
    return result.buffer.asByteData().getUint32(0, (littleEndian) ? Endian.little : Endian.big);
  }

  /// Return an integer representation of a Uint64 (Uint8List(8)), the value will be converted using the little endian representation if
  /// specified via the input parameters, otherwise will read in big endian notation if not specified.
  int readUint64({bool littleEndian = false}) {
    Uint8List result = readSegment(8);
    if (result.isEmpty) {
      return -1;
    }
    return result.buffer.asByteData().getUint64(0, (littleEndian) ? Endian.little : Endian.big);
  }

  VarInt readVarInt() {
    VarInt varInt = VarInt.parse(data, start: _currentPosition);
    _currentPosition += varInt.toUint8List.length;
    if(_currentPosition > data.length) {
      _currentPosition = data.length;
    }
    return varInt;
  }
}