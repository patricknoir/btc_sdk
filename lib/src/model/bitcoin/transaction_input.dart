import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';

class TransactionInput {
  // Previous transaction ID (hash256 of prev trx: 32 Bytes little endian)
  final Uint8List refTXID; // Uint8List(32);
  // Index of the output to be unlocked
  final int outIndex; // uint32
  final Uint8List scriptSig;
  final int nSequence; //uint32

  TransactionInput({required this.refTXID, required this.outIndex, required this.scriptSig, this.nSequence = 0xFFFFFFFF});

  Uint8List get toUint8List =>
      refTXID
          .concat(outIndex.to32Bits())
          .concat(VarInt.fromValue(scriptSig.length).toUint8List)
          .concat(scriptSig)
          .concat(nSequence.to32Bits());
}