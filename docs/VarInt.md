# VarInt

## Introduction

A VarInt or `Variable Integer` is an integer format used widely in Bitcoin to indicate the lengths of fields within transaction, block and peer-to-peer network data.

The `VarInt` is made of 2 parts:

* _FLAG_: is 1 byte flag which determines the maximum length of the value content.
* _VALUE_: is the real content of this field, the part containing the information.

Depending on the value of the _FLAG_ byte, the _VALUE_ field can have different sizes:

| FLAG VALUE          | FLAG length (Bytes) | _VALUE_ field length | Total VarInt Length <br> FLAG.Size + VALUE.Size (Bytes) |
|---------------------|---------------------|----------------------|---------------------------------------------------------|
| FLAG ≤ `0xFC` (252) | **`1 Byte`**        | **`1 Byte`**         | **`1 Byte + 1 Byte = 2 Bytes`**                         |
| FLAG = `0xFD` (253) | **`1 Byte`**        | **`2 Bytes`**        | **`1 Byte + 2 Bytes = 3 Bytes`**                        |
| FLAG = `0xFE` (254) | **`1 Byte`**        | **`4 Bytes`**        | **`1 Byte + 4 Bytes = 5 Bytes`**                        |
| FLAG = `0xFF` (255) | **`1 Byte`**        | **`8 Bytes`**        | **`1 Byte + 8 Bytes = 9 Bytes`**                        | 

## Construct VarInt types

A VarInt field has an internal constructor defined as below: 

```dart
final int flag;
final int value;

/// Private constructor of VarInt, used by the factory methods only.
const VarInt._({required this.flag, required this.value});
```

Although this constructor is not publicly accessible there are 2 ways you can create a VarInt:

* Parsing a valid sequence of bytes representing a VarInt
* Wrapping a VALUE sequence of bytes (Uint8List) into a VarInt, determining the FLAG from the VALUE input provided

### Parsing a VarInt

```dart
/// Given an Array of Bytes, parse it and create a VarInt instance from the specified starting index.
///
/// If not provided the start index is the beginning of the array.
factory VarInt.parse(Uint8List data, {int start = 0})
```
example:
```dart
VarInt parsedVarInt1 = VarInt.parse([253, 0, 255].toUint8List
```

>**NOTE**
>
>for a full list of examples refers to the test class [here](../test/model/binary/var_int_test.dart)

### Wrapping VALUE

```dart
/// Given an integer value this will be converted into a VarInt.
factory VarInt.fromValue(int value)
```
example:
```dart
VarInt varint4 = VarInt.fromValue(134250981); //0x80081E5
```

>**NOTE**
>
>for a full list of examples refers to the test class [here](../test/model/binary/var_int_test.dart)





