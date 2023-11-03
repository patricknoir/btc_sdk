import 'package:btc_sdk/btc_sdk.dart';

void main() {

  // Provided the mnemonic, creates the associated HDWallet
  final String mnemonic = 'card file race stamp craft behave pulp achieve security grace leopard recall';
  final HDWallet wallet = HDWallet.fromMnemonic(mnemonic);

  final wif = wallet.masterPrivateKey.toWifPrivateKey(Network.mainnet, true); // L3tPgshYhzxDFf9EyGdCZEyZcQ6LqtxV5CmRy5q178EokrhRQqyU

  print("Wallet Inport Format for the HD Wallet: ${wif.toWif}");

  final ExtendedPublicKey pubKey = wallet.masterPrivateKey.extendedPublicKey;

  final p2pkhAddr = pubKey.toAddress().p2pkhBase58;

  print("Pay to Public Key Hash address: ${p2pkhAddr}"); // 1HnX4BnhhYXQNMBGPMVDABE4HHYjanDRCh
  print("Address length: ${p2pkhAddr.length}"); // length = 34

  final bitcoinTransactionBytes = "020000000255a736179f5ee498660f33ca6f4ce017ed8ad4bd286c162400d215f3c5a876af000000001976a9140af2c7db949861cdc7767ad211432789f1852e9488acffffffff4d89764cf5490ac5023cb55cd2a0ecbfd238a216de62f4fd49154253f1a750920200000000ffffffff0200e20400000000001976a914e993470936b573678dc3b997e56db2f9983cb0b488ac20cb0000000000001976a914b780d54c6b03b053916333b50a213d566bbedd1388ac0000000001000000".toUint8ListFromHex!;

  final Transaction transaction = Transaction.fromBytes(bitcoinTransactionBytes);

  print("Transaction version: ${transaction.version}"); // Version: 2
  print("Transaction Inputs: ${transaction.inputs.length}"); // 2 Inputs in this transaction
  print("Transaction Outputs: ${transaction.outputs.length}"); // 2 Outputs in this transaction

  final TransactionInput input1 = transaction.inputs[0];

  print("Input1 TX ID reference: ${input1.refTXID.toHex}"); // TXID this input is referring: 55a736179f5ee498660f33ca6f4ce017ed8ad4bd286c162400d215f3c5a876af
  print("Input1 previous transaction output index: ${input1.outIndex}"); // Index of the output associated to this input from the referred TXID: index = 0
  print("Input1 scriptSig: ${input1.scriptSig?.toHex}");
  print("Input1 nSequence: ${input1.nSequence.toHex}");

  final TransactionOutput output1 = transaction.outputs[0];

  print("Output1 bitcoin value in satoshi: ${output1.nValue}"); // Amount of bitcoin in satoshi: 320000
  print("Output1 scriptPubKey: ${output1.scriptPubKey.toHex}"); // scriptPubKey: 76a914e993470936b573678dc3b997e56db2f9983cb0b488ac
}