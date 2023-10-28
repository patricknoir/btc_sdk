# Uint

## Introduction

A `Uint` type represents a generic unsigned integer value which could be either `Uint8`, `Uint16`, `Uint32` or `Uint64`.

This library makes extensive usage of the dart default library Uint8List. A Uint8List is just an array of bytes, where each entry of the list is a single byte (8 bits). 
There are several operations we want to do with a Uint8List, mainly we want to write bytes using the int base type. 
An int in dart can be either int8, int16, int32 or int64. Depending on the value of the int variable this can be translated into a Uint8List of different size as per the below table:

| Bytes              | Data Type	 | Int range	      | Uint8List Length       |
|--------------------|------------|-----------------|------------------------|
| 1 byte = 8 bits    | 	Uint8     | 	0 - 255        | 	Uint8List of length 1 |
| 2 bytes = 16 bits	 | Uint16     | 	0 - 65535      | 	Uint8List of length 2 |
| 4 bytes = 32 bits  | Uint32     | 	0 - 4294967295 | Uint8List of length 4  |
| 8 bytes = 64 bits  | Uint64     | 0 - (2^64 - 1)  | Uint8List of length 8  |

We have defined a new type called Uint which can easily be converted into Uint8List and can be used to write value into the Uint8List.

```dart 
class Uint extends Equatable {
  final int value;
  
  Uint(this.value)
}
```

`Uint` can be converted into `Uint8List` type through the getter method:

```dart
Uint8List get toUint8List;
```

## Conversions

`int` types can be converted into `Uint` by using this extension method:

```dart
extension IntToUint on int {
  Uint? get toUint => (this >= 0) ? Uint(this) : null;
}
```

If the int value is negative it returns null.

## Examples

From the 'uint_test.dart' file that can be found [here](../../test/model/binary/uint_test.dart).

```dart
Uint uint8 = Uint(32);
Uint uint16 = Uint(432);
Uint uint32 = Uint(165536);
Uint throwsAssertionError = Uint(-4); // This will throw an assertion error
```