import 'dart:typed_data';

import 'package:equatable/equatable.dart';

enum UintType {
  uint8(1),
  uint16(2),
  uint32(4),
  uint64(8);

  final int bytes;
  const UintType(this.bytes);
}

/// Represent a generic unsigned integer value which could be either Uint8, Uint16, Uint32 or Uint64.
class Uint extends Equatable {

  static const minUint8Value = 0;
  static const maxUint8Value = 255;

  static const minUint16Value = 256;
  static const maxUint16Value = 65535;

  static const minUint32Value = 65536;
  static const maxUint32Value = 4294967295;

  static const minUint64Value = 4294967296;



  final int value;
  late final UintType type;
  late final Uint8List list;

  /// Creates a Uint from a provided integer value. This constructor will fail if the integer value is negative.
  Uint(this.value) {
    assert(value > 0);
    _init();

  }

  void _init() {
    if(value <= maxUint8Value) {
      list = Uint8List.fromList([value]);
      type = UintType.uint8;
    } else if( value <= maxUint16Value) {
      var result = Uint8List(2);
      result.buffer.asByteData().setUint16(0, value);
      list = result;
      type = UintType.uint16;
    } else if(value <= maxUint32Value) {
      var result = Uint8List(4);
      result.buffer.asByteData().setUint32(0, value);
      list = result;
      type = UintType.uint32;
    } else {
      var result = Uint8List(8);
      result.buffer.asByteData().setUint64(0, value);
      list = result;
      type = UintType.uint64;
    }
  }

  Uint8List get toUint8List => list;

  @override
  List<Object?> get props => [value];

}

extension IntToUint on int {
  Uint? get toUint => (this >= 0) ? Uint(this) : null;
}