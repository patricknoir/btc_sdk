# Hirerchical Deterministic Wallet

A **hirerchical deterministic wallet** ("HD" Wallet) is a wallet that generates all of its keys and addresses from a single source.

- **Deterministic:** the keys and addresses are *always generated in the same way*.
- **Hierarchical:** the keys and addresses are *organised in a tree structure*.

> The best property of this kind of wallet is that you can generate `public keys` without knowing the `private keys` for them.

## Advantages of HD Wallet

### Single Backup

You can use a single seed to create a **master private key**, and you can use this to generate billions of *“child”* **private keys and public keys**.

So now all you need to back up is the **seed**, as the master private key you create from it will always generate the keys for your wallet in the same way *(deterministically)*.

### Organised

Each **child key** in the wallet can also **generate its own keys**, which means you can create a **tree structure** (_or hierarchy_) to organize the keys in your wallet.

For example, you could use different parts of the tree for different “accounts”.

### Generating Public Keys Independently

But the really cool thing about a **master private key** is that it has a corresponding **master public key**, and this can generate the _same child_ **public keys** _without knowing_ the **private keys**.

So you could send the **master public key** to a different computer (e.g. a webshop server) to generate new _receiving addresses_, without worrying that the **private keys** will get stolen if the server gets hacked.

> This is useful for things like **hardware wallets** where you want to keep your private keys on a secure device, but also want the convenience of being able to generate new addresses on a different computer for receiving payments.

## How does it work

### Seed

To start the HD Wallet you need to generate a random 64 bytes, which will be used as seed.

The seed must be kept safe as this will allow anyone to derivate all the private and public keys of the wallet.

Equally, losing the Seed means you won't be able to unlock all the bitcoin associated to its addresses.

For this reason the Seed is generated from a Mnemonic, which is the concatenation of either 12 or 24 words sentence.

### Mnemonic

There are 2 main versions of mnemonics: 12 words and 24 words.

In order to generate a mnemonic you need to take a random number either 16 bytes (for 12 words mnemonic) or 32 bytes (for 24 words mnemonic).

```dart
static const int _SIZE_BYTE = 255;

    /// Generates a random number of either 16 or 32 bytes to be used to create the Mnemonic sentence.
  static Uint8List generateEntropy([MnemonicType mnemonicType = MnemonicType.long24Words]) {
    final rng = Random.secure();
    final bytes = Uint8List(mnemonicType.bytes);
    for (var i = 0; i < mnemonicType.bytes; i++) {
      bytes[i] = rng.nextInt(_SIZE_BYTE);
    }
    return bytes;
  }
  
```
Once an entropy value has been generated, a checksum is performed and the first n bytes of the checksum are appended at the end of the entropy.
The bytes taken from the checksum are the `entropy mod 4`.

Once we obtain this extended entropy value, we split it in group of 11 bytes, convert into a number and we take a word
from a standard array of valid words to generate the mnemonic.

```dart
  /// Given an entropy random value, this will generate an either 12 or 24 words mnemonic sentence used to
  /// deterministically generate a Seed value, used to create the Master Private Key.
  static String generateMnemonic([Uint8List? entropy, MnemonicType mnemonicType = MnemonicType.long24Words]) {
    entropy ??= generateEntropy(mnemonicType); // either 16 or 32 bytes => 128 bits / 256 bits
    final checksum = Hash.sha256(entropy).toBinaryString.substring(0, entropy.length ~/ 4); //take 1 bit each 32 bits (4 bytes)
    final extended = entropy.toBinaryString + checksum;
    String wordList = "";
    for(int i=0; i<extended.length ~/ 11; i++) {
      final wordIndex = int.parse(extended.substring(i * 11, i * 11 + 11), radix: 2);
      wordList += " " + WORDLIST_ENGLISH[wordIndex];
    }
    return wordList.trim();
  }
```

Once the mnemonic is obtained, we take the mnemonic value, concatenate with a passphrase and we perform 2 hasing algorithms:
`HMAC(hash256(mnemonic + "mnemonic:$passphrase"))`:

```dart
  /// Given a mnemonic and an optional passphrase a seed value of 64 bytes will be created in order to generate
  /// deterministically the Private Master Key
  static Uint8List generateSeedFromMnemonic(String mnemonic, {String passphrase = ""}) => Hash.pbkdf2(mnemonic, passphrase: passphrase);
```

