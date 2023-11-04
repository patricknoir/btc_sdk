import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';
import 'package:test/test.dart';

void main() {

  group("transaction", () {

    test("parsing a transaction P2PKH", () {
      final basicTransaction = "020000000255a736179f5ee498660f33ca6f4ce017ed8ad4bd286c162400d215f3c5a876af000000001976a9140af2c7db949861cdc7767ad211432789f1852e9488acffffffff4d89764cf5490ac5023cb55cd2a0ecbfd238a216de62f4fd49154253f1a750920200000000ffffffff0200e20400000000001976a914e993470936b573678dc3b997e56db2f9983cb0b488ac20cb0000000000001976a914b780d54c6b03b053916333b50a213d566bbedd1388ac00000000".toUint8ListFromHex!;

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
      expect(input1.scriptSig!.toHex, "76a9140af2c7db949861cdc7767ad211432789f1852e9488ac");
      expect(input1.nSequence, 0xffffffff);

      final TransactionInput input2 = inputs[1];
      expect(input2.refTXID.toHex, "4d89764cf5490ac5023cb55cd2a0ecbfd238a216de62f4fd49154253f1a75092");
      expect(input2.outIndex, 2);
      expect(input2.scriptSig!.isEmpty, true);
      expect(input2.nSequence, 0xffffffff);

      final outputs = transaction.outputs;
      expect(outputs.length, 2);

      final output1 = outputs[0];
      expect(output1.nValue, 320000);
      expect(output1.scriptPubKey.toHex, "76a914e993470936b573678dc3b997e56db2f9983cb0b488ac");
      final script1 = ScriptExpression.fromBytes(output1.scriptPubKey);

      final output2 = outputs[1];
      expect(output2.nValue, 52000);
      expect(output2.scriptPubKey.toHex, "76a914b780d54c6b03b053916333b50a213d566bbedd1388ac");

      expect(transaction.nLockTime, 0);

      final txBytes = transaction.toUint8List;

      expect(txBytes.toHex, basicTransaction.toHex);
    });

    test("transaction P2PKH", () {
      final trxStr = "0100000001416e9b4555180aaa0c417067a46607bc58c96f0131b2f41f7d0fb665eab03a7e000000006a47304402201c3be71e1794621cbe3a7adec1af25f818f238f5796d47152137eba710f2174a02204f8fe667b696e30012ef4e56ac96afb830bddffee3b15d2e474066ab3aa39bad012103bf350d2821375158a608b51e3e898e507fe47f2d2e8c774de4a9a7edecf74edaffffffff01204e0000000000001976a914e81d742e2c3c7acd4c29de090fc2c4d4120b2bf888ac00000000";

      final trx = Transaction.fromBytes(trxStr.toUint8ListFromHex!);

      final script = ScriptExpression.fromBytes(trx.inputs[0].scriptSig!);
      final sigPart = (script.expression[0] as ScriptData).data;
      final pubKey = (script.expression[1] as ScriptData).data;
      final sig = sigPart.sublist(0, sigPart.length - 1);
      final sigHash = sigPart.last;
      expect(sigHash, 1);

      final previousScriptPubKey = "76a91499b1ebcfc11a13df5161aba8160460fe1601d54188ac".toUint8ListFromHex!;

      expect(pubKey.toHex, "03bf350d2821375158a608b51e3e898e507fe47f2d2e8c774de4a9a7edecf74eda");

      PublicKey pk = PublicKey.fromSEC(EllipticCurve.secp256k1, pubKey);
      expect(pk.compressed.toUint8List, pubKey);

      expect(sig.toHex, "304402201c3be71e1794621cbe3a7adec1af25f818f238f5796d47152137eba710f2174a02204f8fe667b696e30012ef4e56ac96afb830bddffee3b15d2e474066ab3aa39bad");

      final hash = SigHash.sigHashAll(0, previousScriptPubKey, trx);

      SignedHash sh = SignedHash.fromDER(hash, sig);
      final result = sh.verify(PublicKey.fromSEC(EllipticCurve.secp256k1, pubKey));
      expect(result, true);

      expect(trx.toUint8List.toHex, trxStr);
      });

    });

}
