import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';

class Transaction {

  static const int TX_VERSION_1 = 0x01000000;
  static const int TX_VERSION_2 = 0x02000000;

  static const int TX_nLOCK_DEFAULT = 0x00000000;

  final int version; //32 bits (4 Bytes) little endian
  final List<TransactionInput> inputs;
  final List<TransactionOutput> outputs;
  final int nLockTime;

  const Transaction({required this.version, required this.inputs, required this.outputs, this.nLockTime = Transaction.TX_nLOCK_DEFAULT});

  factory Transaction.fromBytes(Uint8List data) => TransactionReader.fromUint8List(data).readTransaction();

  Transaction copyWith({int? version, List<TransactionInput>? inputs, List<TransactionOutput>? outputs, int? nLockTime}) =>
      Transaction(
        version: version ??= this.version,
        inputs: inputs ??= this.inputs,
        outputs: outputs ??= this.outputs,
        nLockTime: nLockTime ??= this.nLockTime
      );

  Transaction copyWithClearSigScriptAt({List<int>? indices}) {
    if(indices == null) {
      return copyWith();
    } else {
      List<TransactionInput> inputs = [];
      for(int i=0; i < this.inputs.length; i++) {
        final txIn = (indices.contains(i)) ? this.inputs[i].copyWithEmptyScript() : this.inputs[i].copyWith();
        inputs.add(txIn);
      }
      return copyWith(inputs: inputs);
    }
  }

  Uint8List get toUint8List {
    Uint8List result = version.to32Bits(endian: Endian.little);
    result = result.concat(inputs.length.to8Bits());
    result = result.concat(inputs.fold(Uint8List(0),(acc, e) => acc.concat(e.toUint8List)));
    result = result.concat(outputs.length.to8Bits());
    result = result.concat(outputs.fold(Uint8List(0),(acc, e) => acc.concat(e.toUint8List)));
    result = result.concat(nLockTime.to32Bits(endian: Endian.little));
    return result;
  }
}