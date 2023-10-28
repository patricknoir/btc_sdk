# Checksum

A checksum is a small piece of data that allows you check if another piece of data is the same as expected.

For example, in Bitcoin, **addresses** include checksums so they can be checked to see if they have been typed correctly.

## How to build it

In Bitcoin, checksums are created by hashing data through SHA256 twice, and then taking the first 4 bytes of the result:

```bash
              Private Key (hex)           Checksum
----------------------------------------|----------|
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa  05c4de7c
```

```java

int privateKey = 0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa;
int doubleHash = sha256(sha256(privateKey)) = 0x05c4de7c1069e9de703efd172e58c1919f48ae03910277a49c9afd7ded58bbeb;
int checksum = take(4, doubleHash) = 0x05c4de7c
```

## Examples

For more examples on hash functions refers to the test cases [here](../test/model/crypto/hash_test.dart).