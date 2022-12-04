# Bytes Array Algebra

## Introduction

This document will describe the Bytes Array data type and the functions and operations implemented in this library to work effectiively with this type.
The Bytes Array plays a key role in any blockchain application, as wallet and transactions are making heavy usage ot bytes array encoding and manipulation.

In the following sections we will cover the key topics:

1. Basic Types: bit, Bytes and int
2. Bytes Array and Encodings
3. Transaction Types

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

### Transaction Types

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
