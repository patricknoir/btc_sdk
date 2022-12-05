# Elliptic Curve Algebra

## Introduction

An elliptic curve is a set of points described by the equation:
```
y² = x³ + ax + b (mod p)
```

so this is where the `a` and `b` variables come from. Different curves will have different values for these coefficients, and `a=0` and `b=7` are the ones specific to `secp256k1`.

### Secp256k1

**Note**: Why is it called `secp256k1`?

This is a nickname for one of the specific curves used in elliptic curve cryptography:

- sec = Standard for Efficient Cryptography — A consortium that develops commercial standards for cryptography.
- p = Prime — The prime number used to create the finite field.
- 256 = 256 bits — Size of the prime field used.
- k = Koblitz — Specific type of curve.
- 1 = First curve in this category.

## Mathematics

There are a few mathematical operations that you can perform on points on the elliptic curve. The main two operations are `double()` and `add()`, and these can then be combined to perform `multiply()`.

These operations are the building blocks of elliptic curve cryptography, and they are used for generating `public keys` and signatures in ECDSA.

- Modular Inverse 
- Double 
- Add 
- Multiply

### Modular Inverse

You see, there is no actual straightforward “division” operation in elliptic curve cryptography because all of the mathematics takes place within a finite field of numbers.

> However, in a finite field you can **multiply by the inverse** of a number to achieve the same result as **division**.

```bash
8 * 13 mod 47 = 104 mod 47 = 10
10 * ? mod 47 = 8 # Which number I can multiply to 10 in order to obtain 8 ?
10 * 29 mod 47 = 290 mod 47 = 8
```

> `29` is the modular multiplicative inverse of `13` in the finite field of `47`

> **This always works when you have a prime number of elements in the field.** 
> 
> A prime number cannot be divided by any other number, so it will distribute the results from modular multiplication back across each of the numbers in the field evenly (without repeating and missing some numbers). So by using a prime number as the modulus you can guarantee that each number in the finite field will have a multiplicative inverse (or a “division” operation).

The code below shows a basic implementation of the modular multiplicative inverse in dart:

```dart
class Modulus {
  static int inverse(int a, {required int p}) {
    assert(a > 0);
    int m = p;
    a = a % m;
    int y = 1;
    int prevY = 0;
    while(a > 1) {
      int q = m ~/ a;
      int currentY = y;
      y = prevY - q * y;
      prevY = currentY;
      int originA = a;
      a = m % a;
      m = originA;
    }
    return y % p;
  }
}
```

### Double

“Doubling” a point is the same thing as “adding” a point to itself.

From a visual perspective, to “double” a point you draw a tangent to the curve at the given point, then find the point on the curve this line intersects (there will only be one), then take the reflection of this point across the x-axis.

```dart

```