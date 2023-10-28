# Uint

## Introduction

A `Uint` type represents a generic unsigned integer value which could be either `Uint8`, `Uint16`, `Uint32` or `Uint64`.

```dart 
class Uint extends Equatable {
  final int value;
  
  Uint(this.value)
}
```

`Uint` can be converted into `Uint8List` type through the getter method:

```dart
Uint8List get toUint8List
```

Depending of the value of the provided integer value the `Uint8List` will have a different size based on the below table.

| `value`                      | `UintType` | `Uint8List` length |
|------------------------------|------------|--------------------|
| 0 ≤ `value` ≤ 255            | *uint8*    | 1                  |
| 255 < `value` ≤ 65535        | *uint16*   | 2                  |
| 65535 < `value` ≤ 4294967295 | *uint32*   | 4                  |
| 4294967295 < `value`         | *uint64*   | 8                  |

## Conversions

`int` types can be converted into `Uint` by using this extension method:

```dart
extension IntToVarUint on int {
  Uint? get toUint => (this >= 0) ? Uint(this) : null;
}
```

If the int value is negative it returns null.

## Examples

From the 'uint_test.dart' file that can be found [here](../test/model/binary/uint_test.dart).

```dart
Uint uint8 = Uint(32);
Uint uint16 = Uint(432);
Uint uint32 = Uint(165536);
Uint throwsAssertionError = Uint(-4); // This will throw an assertion error
```