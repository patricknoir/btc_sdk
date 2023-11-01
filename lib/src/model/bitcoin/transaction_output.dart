import 'dart:typed_data';

class TransactionOutput {
  // Uint64 (8 Bytes) bitcoin amount in satoshi
  final int nValue;
  final Uint8List scriptPubKey;

  TransactionOutput({required this.nValue, required this.scriptPubKey});
}