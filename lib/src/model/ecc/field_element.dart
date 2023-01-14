import 'package:equatable/equatable.dart';

class FieldElement extends Equatable {

  late final BigInt value;
  late final BigInt order;

  FieldElement(BigInt value, BigInt order) {
    assert(order > BigInt.zero);
    final positiveVal = (value < BigInt.zero) ? order - value : value;
    this.value = positiveVal % order;
  }

  @override
  List<Object?> get props => [value, order];

  FieldElement operator+(FieldElement other) {
    assert(other.order == order);
    return FieldElement(value + other.value, order);
  }

  FieldElement operator-(FieldElement other) {
    assert(order == other.order);
    return this + FieldElement(-other.value, order);
  }

  FieldElement operator*(FieldElement other) {
    assert(other.order == order);
    return FieldElement(value * other.value, order);
  }

  FieldElement pow(BigInt exp) {
    if(exp == BigInt.from(-1)) {
      return FieldElement(BigInt.one, order);
    }
    return (exp.isNegative) ? FieldElement(value.modPow(order - exp, order), order) : FieldElement(value.modPow(exp, order), order);
  }

  FieldElement get additiveInverse => FieldElement(-value, order);
  FieldElement get multiplicativeInverse => FieldElement(value.modInverse(order), order);

  FieldElement operator/(FieldElement other) => this * multiplicativeInverse;
}