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
  BigIntPoint double(BigIntPoint point) {
    // slope = (3x₁² + a) / 2y₁ = (3x₁² + a) * inverse(2y₁)
    BigInt slope = ((BigInt.from(3) * point.x.pow(2) + a) * (BigInt.from(2) * point.y).modInverse(p)) % p;

    // x = slope² - 2x₁
    BigInt x = (slope.pow(2) - BigInt.from(2) * point.x) % p;

    // y = slope * (x₁ - x) - y₁
    BigInt y = (slope * (point.x - x) - point.y) % p;

    return BigIntPoint(x: x, y: y);
  }
```

### Add

As expected, “addition” of two points in elliptic curve mathematics isn’t the same as straightforward integer addition, but it’s called “addition” anyway.

From a visual perspective, to “add” two points together you draw a line between them, then find the point on the curve this line intersects (there will only be one), then take the reflection of this point across the x-axis.

```dart
  BigIntPoint add( BigIntPoint point1, BigIntPoint point2) {
    if(point1 == point2) {
      return double(point1);
    }

    // slope = (y₁ - y₂) / (x₁ - x₂) = (y₁ - y₂) * inverse(x₁ - x₂)
    BigInt slope = ((point1.y - point2.y) * (point1.x - point2.x).modInverse(p)) % p;

    // x = slope² - x₁ - x₂
    BigInt x = (slope.pow(2) - point1.x - point2.x) % p;

    // y = slope * (x₁ - x) - y₁
    BigInt y = (slope * (point1.x - x) - point1.y) % p;

    return BigIntPoint(x: x, y: y);
  }
```

### Multiply

Now that we can “double” and “add” points on the curve, we can now take any point on the curve and “multiply” it by an integer to get to a completely new point. 
**This operation is the heart of elliptic curve cryptography.**

The simplest method for elliptic curve multiplication would be to repeatedly “add” a point to itself until you reach the number you want to multiply by, which would work to a degree, but these incremental add() operations would make this approach impossibly slow when multiplying by large numbers (like the ones used in Bitcoin).

Thankfully there is a faster way to perform multiplication on elliptic curves…

#### Double-and-Add

A faster approach to multiplication is to use the double-and-add algorithm, where you make an efficient use of both doubling and adding to reach the target multiple in as few operations as possible.

For example, if you start at 2 and want to get to 128, it’s faster to perfom six double() operations than it is to perform sixty-four add() operations.

But how do you know how many double and add operations you need to get to your target multiple?

Well, amazingly, if you convert any integer in to its binary representation, the 1s and 0s will provide a map for the sequence of double() and add() operations you need to perform to reach that multiple.

Working from left to right and ignoring the first number:

- 0 = double
- 1 = double and add

For example:

```bash
e.g. 1 * 21

21 = 10101 (binary)
      │││└ double and add = 21
      ││└─ double         = 10
      │└── double and add = 5
      └─── double         = 2
                            1  <- start here
```

Anyway, here’s what elliptic curve multiplication looks like when using the double-and-add algorithm in Dart code:

```dart
  BigIntPoint multiply(BigInt k) {
    // create a copy the initial starting point (for use in addition later on)
    BigIntPoint current = G;

    // create a copy the initial starting point (for use in addition later on)
    String kBinary = k.toRadixString(2);

    for(int i=1; i<kBinary.length; i++) {
      // double
      current = double(current);

      if(kBinary[i] == "1") {
        current = add(current, G);
      }
    }

    return current;
  }
```

#### SQRT

> **Valid only for secp256k1 as p % 3 = 1.**

Stated mathematically:

> Find w such that w2 = v when we know v.
> 
> It turns out that if the finite field prime p % 4 = 3, we can do this rather easily. Here’s how.

First, we know: 

> p % 4 = 3

which implies:

> (p + 1) % 4 = 0
> 
> then (p + 1)/4 is an integer. 

By definition:

> w² = v

We are looking for a formula to calculate w. From Fermat’s little theorem:

> w^(p–1) % p = 1 

which means:

> w² = w² ⋅ 1 = w² ⋅ w^(p–1) = w^(p+1)

Since p is odd (recall p is prime), we know we can divide (p+1) by 2 and still get an
integer, implying: 

> w = w^(p+1)/2

Now we can use (p+1)/4 being an integer this way: 

> w = w^(p+1)/2 = w²^(p+1)/4 = (w²)^(p+1)/4 = v(p+1)/4

So our formula for finding the square root becomes:

> if w² = v and p % 4 = 3, w = v^(p+1)/4

It turns out that the p used in secp256k1 is such that p % 4 == 3, so we can use this

> formula: w² = v
>
> w = v^(p+1)/4