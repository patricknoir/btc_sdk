import 'package:btc_sdk/src/model/bitcoin/transaction_input.dart';

class Transaction {
  final int version; //32 bits (4 Bytes) little endian
  final List<TransactionInput> inputs;

const Transaction({required this.version, required this.inputs});
}