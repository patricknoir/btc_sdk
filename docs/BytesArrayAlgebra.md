# Bytes Array Algebra

## Introduction

This document will describe the Bytes Array data type and the functions and operations implemented in this library to work effectiively with this type.
The Bytes Array plays a key role in any blockchain application, as wallet and transactions are making heavy usage ot bytes array encoding and manipulation.

In the following sections we will cover the key topics:

1. Basic Types: bit, Bytes and int
2. Bytes Array and Encoding

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

