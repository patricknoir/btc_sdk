class TransactionInput {
  // Previous transaction ID (hash256 of prev trx: 4 Bytes little endian)
  final int refId;
  // • Previous transaction index
  // • ScriptSig
  // • Sequence

  TransactionInput(this.refId);
}