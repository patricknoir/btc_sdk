import 'package:btc_sdk/btc_sdk.dart';
import 'package:btc_sdk/src/model/bitcoin/transaction.dart';
import 'package:btc_sdk/src/model/bitcoin/transaction_input.dart';
import 'package:btc_sdk/src/trx/transaction_reader.dart';
import 'package:test/test.dart';

void main() {

  group("transaction", () {

    test("parsing a transaction", () {
      final basicTransaction = "020000000255a736179f5ee498660f33ca6f4ce017ed8ad4bd286c162400d215f3c5a876af000000001976a9140af2c7db949861cdc7767ad211432789f1852e9488acffffffff4d89764cf5490ac5023cb55cd2a0ecbfd238a216de62f4fd49154253f1a750920200000000ffffffff0200e20400000000001976a914e993470936b573678dc3b997e56db2f9983cb0b488ac20cb0000000000001976a914b780d54c6b03b053916333b50a213d566bbedd1388ac0000000001000000".toUint8ListFromHex!;

      final TransactionReader reader = TransactionReader.fromUint8List(basicTransaction);

      final Transaction transaction =  reader.readTransaction();
      // validating the transaction version
      expect(transaction.version, 2);
      // counter of the inputs in the transaction
      final inputs = transaction.inputs;
      expect(inputs.length, 2);
      // validate the inputs
      final TransactionInput input1 = inputs[0];
      expect(input1.refTXID.toHex, "55a736179f5ee498660f33ca6f4ce017ed8ad4bd286c162400d215f3c5a876af");
      expect(input1.outIndex, 0);
      expect(input1.scriptSig.toHex, "76a9140af2c7db949861cdc7767ad211432789f1852e9488ac");
      expect(input1.nSequence, 0xffffffff);

      final TransactionInput input2 = inputs[1];
      expect(input2.refTXID.toHex, "4d89764cf5490ac5023cb55cd2a0ecbfd238a216de62f4fd49154253f1a75092");
      expect(input2.outIndex, 2);
      expect(input2.scriptSig.isEmpty, true);
      expect(input2.nSequence, 0xffffffff);

      final outputs = transaction.outputs;
      expect(outputs.length, 2);

      final output1 = outputs[0];
      expect(output1.nValue, 320000);
      expect(output1.scriptPubKey.toHex, "76a914e993470936b573678dc3b997e56db2f9983cb0b488ac");

      final output2 = outputs[1];
      expect(output2.nValue, 52000);
      expect(output2.scriptPubKey.toHex, "76a914b780d54c6b03b053916333b50a213d566bbedd1388ac");

      expect(transaction.nLockTime, 0);
    });

  });

}
