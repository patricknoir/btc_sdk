import 'dart:typed_data';

import 'package:btc_sdk/src/model/binary/uint8list_reader.dart';
import 'package:btc_sdk/src/model/bitcoin/transaction_output.dart';

import '../model/bitcoin/transaction.dart';
import '../model/bitcoin/transaction_input.dart';

class TransactionReader {

  final Uint8ListReader reader;

  int get currentPosition => reader.currentPosition;

  TransactionReader(this.reader);

  factory TransactionReader.fromUint8List(Uint8List data) {
    return TransactionReader(Uint8ListReader(data));
  }

  Transaction readTransaction() {
    // transaction version
    int version = reader.readUint32(littleEndian: true);
    // counter of the inputs in the transaction
    final inputVarInt = reader.readVarInt();

    final List<TransactionInput> inputs = [];

    for(int i=0; i< inputVarInt.value; i++) {
      inputs.add(_readTransactionInput());
    }

    final outputVarInt = reader.readVarInt();

    final List<TransactionOutput> outputs = [];

    for(int i=0; i < outputVarInt.value; i++) {
      outputs.add(_readTransactionOutput());
    }

    final nLockTime = reader.readUint32(littleEndian: true);

    return Transaction(version: version, inputs: inputs, outputs: outputs, nLockTime: nLockTime);
  }

  TransactionInput _readTransactionInput() {
    // refId of the first transaction
    final inRefID = reader.readSegment(32);

    // get the index of the output to spend from the previous transaction
    final inOutIndex = reader.readUint32(littleEndian: true);

    // getting the scriptSig (unlock scrip) length for the first input
    final inScriptSigLen = reader.readVarInt();

    // reading the ScriptSig (unlock scrip) data for hte first input
    final inScriptSig = reader.readSegment(inScriptSigLen.value);

    final inNSequence = reader.readUint32(littleEndian: true);

    final TransactionInput input = TransactionInput(refTXID: inRefID, outIndex: inOutIndex, scriptSig: inScriptSig, nSequence: inNSequence);
    return input;
  }

  TransactionOutput _readTransactionOutput() {
    final nValue = reader.readUint64(littleEndian: true);
    final pubScriptLen = reader.readVarInt();
    final pubScript = reader.readSegment(pubScriptLen.value);
    return TransactionOutput(nValue: nValue, scriptPubKey: pubScript);
  }
}