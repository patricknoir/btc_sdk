# Finite Field Math

## Definition

A *finite field* is defined as a finite set of numbers on which we can define 2 operations *addition (+)* and *multiplication (\*)* that satisfy tge following conditions:

1. **Closure**: if `a` and `b` are defined in the set then also `a+b` and `a*b` are in the set.
2. **Additive Identity**: we define `0` as the *additive identity* which has the following property: `a + 0 = 0 + a = a`.
3. **Multiplicative Identity**: we define `1` as the *multiplicative identity* which has the following property: `a * 1 = 1 * a = a`.
4. **Additive Inverse**: we define `-a` as the *additive inverse* of `a` if `a + (-a) = (-a) + a = 0`.
5. **multiplicative Inverse**: we define `a⁻¹` as the *multiplicative inverse* of `a` if `a * a⁻¹ = a⁻¹ * a = 1`.

Each `finite field` is defined by the `order`, which represents the biggest element in the field and indicated with the letter `p`.

>**Finite Field of order `p`** or simplier **Field of p**:
>```
> Fₚ = {0, 1, 2, ..., p-1}
>```
>
>i.e.:
> ```
> F₁₁ = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10} // Field of 11
> F₁₇ = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16} // Field of 17
>```

> **Note**
> 
> > in the F₇ the value `-2` is by definition:
> > ```
> > -2 + ? = 0 in F₇ 
> > -2 + ? = 7 => ? = 7 - 2 = 5
> > 
> `-2` is equivalent to write `5` in F₇
> > ```



