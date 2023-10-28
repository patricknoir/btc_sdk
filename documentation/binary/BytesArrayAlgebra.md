# Bytes Array Algebra

## Introduction

This document will describe the Bytes Array data type and the functions and operations implemented in this library to work effectively with this type.
The Bytes Array plays a key role in any blockchain application, as wallet and transactions are making heavy usage of bytes array encoding and manipulation.

In the following sections we will cover the key topics:

1. **Basic Types**: bit, Bytes and int
2. **Bytes Array** and **Encoding**
3. **Transaction Types**

### Basic Types: bit, Bytes and int

When dealing with bytes, there are 2 main types to consider: *bit* and *Bytes*.
All computer data are encoded in binary format as this is the format which is actually used by the computer registry and the ALU.
Each binary value is called *bit*. An array of 8 bits get the name of *Byte*.

```bash
A bit can contains either the value 0 or 1 .
A byte is an Array of length 8 of bits:

00110101 # This is a Byte
```

In dart you don't deal directly with the bit/byte type, however, you use its `uint` representation.
Like any programming language, in dart the int type represents a number in base10.
Behind the scenes the `uint` value is stored in a binary format.

For example:
```bash
uint small = 7; # binary representation: 111
uint medium = 260; #  binary representation: 100000100
```

Depending on the integer value, a different number of bits/bytes are used.
In the first case for the variable `small` only 3 bits are necessary, while in case of `medium` we need 9 bits.

In general the integer type is classified in 4 subtypes:

| Uint Subtype | Value Range    | Number of Bytes required |
|--------------|----------------|--------------------------|
| uint8        | 0 - 255        | 1 Byte = 8 bits          |
| uint16       | 0 - 65535      | 2 Bytes = 16 bits        |
| uint32       | 0 - 4294967295 | 4 Bytes = 32 bits        |        
| uint64       | 0 - (2^64 - 1) | 8 Bytes = 64 bits        |    

All the Uint types are Array of Bytes which in Darts are identified by the type: *Uint8List*.
A Uint8List contains a ordered list of uint8 types and is the most important type used for raw Array Bytes manipulation.

### Bytes Array and Encodings

#### Binary to Decimal
Use the power of 2 to convert a binary format into decimal
1 Byte can be represented by a decimal value between 0 - 255.

i.e.
```bash
0111 1100 = 0*2^7 + 1*2^6 + 1*2^5 + 1*2^4   +   0*2^3 + 0*2^2 + 0*2^1 + 0*2^0
          =              112                +                 12
          =                                124
``` 

##### Binary to HEX to Base58
Groups the binary format into group of 4 and convert to HEX (0000 = 0      | 1111 = 15 = F)
1 Byte can always be represented with 2 HEX digit prefixed by 0x.

i.e.
```bash
0111 1100 = 0x7C
  7  12=C
```

**A Uint8List is a synonymous for List<Uint8>.**

```dart
final Uint8List data = Uint8List.fromList([124, 8, 234, 156]);
```

This Uint8List of length 4 is representing a Uint32 data type.

Its' binary representation is:

```bash
124 = 0111 1100
8   = 0000 1000
234 = 1110 1010
156 = 1001 1100
```

which in HEX translates into:

```bash
124 = 0111 1100 = 0x7C
8   = 0000 1000 = 0x08
234 = 1110 1010 = 0xEA
156 = 1001 1100 = 0x9C
```

```dart
final Uint8List data = Uint8List.fromList([124, 8, 234, 156]); // In HEX = [ 0x7C, 0x08, 0xEA, 0x9C]
final int valueAsInt32 = data.buffer.asByteData().getInt32(0); // = 2080959132 in decimal
expect(valueAsInt32, 0x7C08EA9C); // this is equal to concat the HEX representation of each Uint8 in the array
```
##### Base58

| Base	            | Characters                                                     |
|------------------|----------------------------------------------------------------|
| 2 (binary)       | 01                                                             |
| 10 (decimal)	    | 0123456789                                                     |
| 16 (hexadecimal) | 	0123456789abcdef                                              |
| 58               | 	123456789ABCDEFGH JKLMN PQRSTUVWXYZabcdefghijk mnopqrstuvwxyz |

***NOTE: Base58 does not include the digit 0,O,I,l because these are easily confused with other digits.***

| Decimal | Base58 |
|---------|--------|
| 0       | 1      |
| 1       | 2      |
| 2       | 3      |
| 3       | 4      |
| 4       | 5      |
| 5       | 6      |
| 6       | 7      |
| 7       | 8      |
| 8       | 9      |
| 9       | A      |
| 10      | B      | 
| 11      | C      |
| 12      | D      |
| 13      | E      |
| 14      | F      |
| 15      | G      |
| 16      | H      |
| 17      | J      |
| 18      | K      |
| 19      | L      |
| 20      | M      |
| 21      | N      |
| 22      | P      |
| 23      | Q      |
| 24      | R      |
| 25      | S      |
| 26      | T      |
| 27      | U      |
| 28      | V      |
| 29      | W      |
| 30      | X      |
| 31      | Y      |
| 32      | Z      |
| 33      | a      |
| 34      | b      |
| 35      | c      |
| 36      | d      |
| 37      | e      |
| 38      | f      |
| 39      | g      |
| 40      | h      |
| 41      | i      |
| 42      | j      |
| 43      | k      |
| 44      | m      |
| 45      | n      |
| 46      | o      |
| 47      | p      |
| 48      | q      |
| 49      | r      |
| 50      | s      |
| 51      | t      |
| 52      | u      |
| 53      | v      |
| 54      | w      |
| 55      | x      |
| 56      | y      |
| 57      | z      |


```bash
base2(9999) = 0010 0111 0000 1111 = 1 + 2 + 4 + 8 + 256 + 512 + 1024 + 8192
base10(9999) = 9999
base16(9999) = 270f
base58(9999) = 3yQ
```

Convert it back to base10:

```
base58(3) = base10(2)
base58(y) = base10(56)
base58(Q) = base10(23)

23 + 56*58 + 2*58^2 = 23 + 56*58 + 2*3364 = 23 + 3248 + 6728 = 9999
```

#### Links

- Base58: [Alphanumeric Representation for numbers](https://learnmeabitcoin.com/technical/base58)


### Transaction Types

In bitcoin wallet and transactions all the data types are array.

#### Base58 in Bitcoin
Base58 is used in bitcoin when you want to convert commonly used data in to an easier-to-share format. For example:

- WIF Private Keys
  A private key is like a “master password”, and you can use it when you want to import bitcoins in to a new wallet. For this occasion, there is such a thing as a WIF Private Key, which is basically a private key in base58.
- Addresses
  A public key is the “public” counterpart to a private key, and you use them when you want to send bitcoins to someone, so it’s expected that you’re going to type one out from time to time. However, public keys are quite lengthy, so we convert them to Addresses instead, which makes use of base58 in the final step of the conversion.

> We convert every zero byte (0x00) at the start of a hexadecimal value to a 1 in base58.

You see, putting zeros at the start of a number does not increase the size of it (e.g. 0x12 is the same as 0x0012), so when we convert to base58 (which uses the modulus function) any extra zeros at the start will not affect the result.

Therefore, to ensure that leading zeros have an influence on the result, the bitcoin base58 encoding includes a manual step to convert all leading 0x00’s to 1’s.

I’m not sure why we convert zero bytes at the start to 1s in base58, but that’s how it works in bitcoin.

#### Prefixes

In Bitcoin, different prefixes are added to data before converting to base58 to influence the leading character of the result. This leading character then helps us to identify what each base58 string represents.

These are the most common prefixes used in bitcoin:

> Mainnet

| Prefix (hex) | Base58 Leading character | Represents           | Example                                                                                                           |
|--------------|--------------------------|----------------------|-------------------------------------------------------------------------------------------------------------------|
| `00`         | 1                        | P2PKH Address        | `1AKDDsfTh8uY4X3ppy1m7jw1fVMBSMkzjP`                                                                              |
| `05`         | 3                        | P2SH Address         | `34nSkinWC9rDDJiUY438qQN1JHmGqBHGW7`                                                                              |
| `80`         | K / L                    | WIF Private Key*     | `L4mee2GrpBSckB9SgC9WhHxvtEgKUvgvTiyYcGu38mr9CGKBGp93`                                                            |
| `80`         | 5                        | WIF Private Key**    | `5KXWNXeaVMwjzMsrKPv8dmdEZuVPmPay4nm5SfVZCjLHoy1B56w`                                                             |
| `0488ADE4`   | xprv                     | Extended Private Key | `xprv9tuogRdb5YTgcL3P8Waj7REqDuQx4sXcodQaWTtEVFEp6yRKh1CjrWfXChnhgHeLDuXxo2auDZegMiVMGGxwxcrb2PmiGyCngLxvLeGsZRq` |
| `0488B21E`   | xpub                     | Extended Public Key  | `xpub67uA5wAUuv1ypp7rEY7jUZBZmwFSULFUArLBJrHr3amnymkUEYWzQJz13zLacZv33sSuxKVmerpZeFExapBNt8HpAqtTtWqDQRAgyqSKUHu` |


> *NOTES*
> 
> *when the private key is used to create a compressed public key.
> 
> **when the private key is used to create an uncompressed public key.

> Testnet

| Prefix (hex) | Base58 Leading character | Represents           | Example                                                                                                           |
|--------------|--------------------------|----------------------|-------------------------------------------------------------------------------------------------------------------|
| `6F`         | m / n                    | P2PKH Address        | `ms2qxPw1Q2nTkm4eMHqe6mM7JAFqAwDhpB`                                                                              |
| `C4`         | 2                        | P2SH Address         | `2MwSNRexxm3uhAKF696xq3ztdiqgMj36rJo`                                                                             |
| `EF`         | c                        | WIF Private Key*     | `cV8e6wGiFF8succi4bxe4cTzWTyj9NncXm81ihMYdtW9T1QXV5gS`                                                            |
| `EF`         | 9                        | WIF Private Key**    | `93J8xGU85b1sxRP8wjp3WNBCDZr6vZ8AQjd2XHr4YU5Lb21jS1L`                                                             |
| `04358394`   | tprv                     | Extended Private Key | `tprv9tuogRdb5YTgcL3P8Waj7REqDuQx4sXcodQaWTtEVFEp6yRKh1CjrWfXChnhgHeLDuXxo2auDZegMiVMGGxwxcrb2PmiGyCngLxvLeGsZRq` |
| `043587CF`   | tpub                     | Extended Public Key  | `tpub67uA5wAUuv1ypp7rEY7jUZBZmwFSULFUArLBJrHr3amnymkUEYWzQJz13zLacZv33sSuxKVmerpZeFExapBNt8HpAqtTtWqDQRAgyqSKUHu` |


> *NOTES*
>
> *when the private key is used to create a compressed public key.
>
> **when the private key is used to create an uncompressed public key.


#### VarInt
A VarInt (variable integer) is a field used in transaction data to indicate the number of upcoming fields, or the length of an upcoming field.

A VarInt is most commonly a 1 byte hexadecimal value:
```bash
                 0x6a = 106 bytes
--|------------------------------------- ... --|
6a47304402200aa5891780e216bf1941b502de29 ... 926
```

However, if the VarInt is going to be greater than 0xfc (so the number you’re trying to express won’t fit inside of two hexadecimal characters) then you can expand the field in the following way:

| Size                  | 	Example	(Hex)     | Description                                                             |
|-----------------------|--------------------|-------------------------------------------------------------------------|
| <= 0xfc	              | 12                 |                                                                         |
| <= 0xffff             | fd1234             | 	Prefix with fd, and the next 2 bytes is the VarInt (in little-endian). |
| <= 0xffffffff         | fe12345678         | 	Prefix with fe, and the next 4 bytes is the VarInt (in little-endian). |
| <= 0xffffffffffffffff | ff1234567890abcdef | 	Prefix with ff, and the next 8 bytes is the VarInt (in little-endian). |

### Private Key

A private key is a random number. It is a 256 bits (32 Bytes = Uint32) number.

It is used as the source of a public key.

> **A private key can be almost any 256-bit number.**
>
> When you create a public key, your private key is put through a special mathematical function, and this function can only handle numbers up to just below 256 bits. The maximum value is:
>
> ```bash
> max = 115792089237316195423570985008687907852837564279074904382605163141518161494336
> ```
>
> This number is n-1, where n is the number of points on the elliptic curve used in Bitcoin. So when you generate a 256 bit number, you will want to check that it’s not above this maximum value.

#### Formats

A hexadecimal private key is 32 bytes (64 characters):

```bash
ef235aacf90d9f4aadd8c92e4b2562e1d9eb97f0df9ba3b508258739cb013db2
```
However, you can convert your private key to a **WIF Private Key**, which basically makes it easier to copy and import in to wallets.

#### WIF Private Key

A private key can be converted in to a “Wallet Import Format”, which basically makes it easier to copy and move around (because it’s shorter and contains a checksum for detecting errors).

A WIF private key is a standard private key, but with a few added extras:

1. Version Byte prefix - Indicates which network the private key is to be used on.
   - 0x80 = Mainnet
   - 0xEF = Testnet
2. Compression Byte suffix (optional) - Indicates if the private key is used to create a compressed public key.
   - 0x01
3. Checksum - Useful for detecting errors/typos when you type out your private key.

This is all then converted to Base58, which shortens the entire thing and makes it easier to transcribe…