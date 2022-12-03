<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

This library contains useful classes and functions to implement applications
which might need to use BTC and ETH non-custodial wallets.

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Types

### Uint

This library makes extensive usage of the dart default library Uint8List.
A Uint8List is just an array of bytes, where each entry of the list is a single byte (8 bits).
There are several operations we want to do into a Uint8List, mainly we want to write bytes using the int base type.
An int in dart can be either int8, int16, int32 or int64. Depending on the value of the int variable this can be translated
into a Uint8List of different size as per the below table:

| Bytes             | Data Type | Int range      | Uint8List Length      |
|-------------------|-----------|----------------|-----------------------|
| 1 byte = 8 bits   | Uint8     | 0 - 255        | Uint8List of length 1 |
| 2 bytes = 16 bits | Uint16    | 0 - 65535      | Uint8List of length 2 |
| 4 bytes = 32 bits | Uint32    | 0 - 4294967295 | Uint8List of length 3 |
| 8 bytes = 64 bits | Uint64    | 0 - (2^64 - 1) | Uint8List of length 4 |

We have defined a new type called Uint which can easily be converted into Uint8List and can be used to write value into the Uint8List.

We have extended the Uint8List with 2 new methods: `concat` and `appendInt`

#### Uint8List.concat

this method allows you to append another Uint8List to an existing Uint8List.
Although this function already exists as operator +, the input parameter and return type are not forced to be Uint8List.
_concat_ is a more restrictive function, where the passed argument must be a Uint8List and the return type is guarenteed to be a Uint8List.

```dart
Uint8List l1 = Uint8List.fromList([128]);
Uint8List l2 = Uint8List.fromList([64]);
Uinst8List l3 = l1.concat(l2);
expect(l3, [128, 64]);
```


#### Uint8List.appendInt

this method allow you to append any int value (8-16-32-64 bits) to an arbitrary Uint8List.
If the int value is 0-255 then a byte value is appended at the end, is greater then 2 bytes, 4 bytes or finally 8 bytes if the saze is in the range of int64.

```dart
final l0 = Uint8List(0);
final l16 = l0?.appendInt(Uint.minUint16Value);
expect(l16, [1, 0]);
expect(l16?.toHex, '0100');
final l32 = l0?.appendInt(Uint.minUint32Value);
expect(l32, [0, 1, 0, 0]);
expect(l32?.toHex, '00010000');
final l64 = l0?.appendInt(Uint.minUint64Value);
expect(l64, [0, 0, 0, 1, 0, 0, 0, 0]);
expect(l64?.toHex, '0000000100000000');
```

#### Hex Conversions: Uint8List.toHex / String.fromHex

Any array of bytes can be represented as an HEX string and viceversa.
A full byte can be represented by 2 HEX digits as per the below example:

```bash
The number 256 is represented in bynary by the byte:
00010000

A byte can be split in 2 groups of 4 bits:
0001 0000
Each group of 4 bits can be represented by 1 HEX digit:
0001 = HEX(1)
0000 = HEX(0)

HEX(10) = BINARY(0001 0000)

BINARY(1010 1111) = HEX(AF)
```

We have extended the Uint8List to provide an utility function to convert any Uint8List into an HEX string representation:

```dart
final Uint8List data = Uint8List.fromList([124, 8, 234, 156]);
final String hexData = data.toHex;
expect(hexData, '7C08EA9C'.toLowerCase());
```

Conversely, from an HEX string we can convert it back into a Uint8List using the fromHex function.
Note this function returns a nullable value as in case the string is not a valid HEX representation the 
returned value is null.

```dart
final String hexValue = '7c08ea9c'; //Capital letters are also allowed
final Uint8List bytesArray = hexValue.fromHex!;
expect(bytesArray, [124, 8, 234, 156]);
```

#### Base58 Conversions: Uint8List.toBase58 / String.fromBase58

Base58 is a convenient representation of array of bytes which make usage of the alphanumeric charachters, however,
the characters 0, O, I, l are omitted as they can be easily confused each other.
For more details on the representation check the Appendix section.

As Base58 is commonly used in blockchain, convenience functions have been provided from/to Uint8List/String Base58.

```dart
final Uint8List data = Uint8List.fromList([124, 8, 234, 156]);
expect(data.toBase58, '4AtTej');

expect('3yQ'.fromBase58?.buffer.asByteData().getInt16(0), 9999);
```

### The Type Buffer

In blockchain and bitcoin wallets, there are lots of operations which require the manipulation of array of bytes, such as concatenation of arrays, appending elements, converting little endian to big endians, having var sized buffers.
For this reason we have introduced a new Buffer type used to manipulate Uint8List types.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder. 

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.

### Used Libraries

- bip39: used to generate mnemonic words to seed. Mnemonic are 12 words text used to recovery the seed key for a non-custodial wallet.
- bip32: used to generate a hierarchical wallet with a seed private/public key
- hex: convert from/to List<int>/HEX Strings. Used to represent Uint8List into a HEX String format.

### Bit/Byte Data Types

When dealing with raw bitcoin address is key to master the basic bit data type representation.

There are 4 kind of base data types:

| Bytes             | Data Type | Int range      | Uint8List Length      |
|-------------------|-----------|----------------|-----------------------|
| 1 byte = 8 bits   | Uint8     | 0 - 255        | Uint8List of length 1 |
| 2 bytes = 16 bits | Uint16    | 0 - 65535      | Uint8List of length 2 |
| 4 bytes = 32 bits | Uint32    | 0 - 4294967295 | Uint8List of length 3 |
| 8 bytes = 64 bits | Uint64    | 0 - (2^64 - 1) | Uint8List of length 4 |

Uint types can be represented either in decimal or HEX format.

Example 1 byte = 8 bit.

#### Binary to Decimal
Use the power of 2 to convert a binary format into decimal
1 Byte can be represented by a decimal value between 0 - 255.

i.e.
```bash
0111 1100 = 0*2^7 + 1*2^6 + 1*2^5 + 1*2^4   +   0*2^3 + 0*2^2 + 0*2^1 + 0*2^0
          =              112                +                 12
          =                                124
``` 

#### Binary to HEX to Base58
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
