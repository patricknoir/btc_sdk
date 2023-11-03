import 'dart:typed_data';
import 'package:btc_sdk/btc_sdk.dart';
import 'package:equatable/equatable.dart';
import 'package:stack/stack.dart';

abstract class ScriptElement extends Equatable {

  static const int CONST_OP_PUSHDATA1 = 0x4C;
  static const int CONST_OP_PUSHDATA2 = 0x4D;
  static const int CONST_OP_PUSHDATA4 = 0x4E;

  static const int CONST_OP_1NEGATE = 0x4F;
  static const int CONST_OP_1 = 0x51;
  static const int CONST_OP_TRUE = 0x51;
  static const int CONST_OP_2 = 0x52;
  static const int CONST_OP_3 = 0x53;
  static const int CONST_OP_4 = 0x54;
  static const int CONST_OP_5 = 0x55;
  static const int CONST_OP_6 = 0x56;
  static const int CONST_OP_7 = 0x57;
  static const int CONST_OP_8 = 0x58;
  static const int CONST_OP_9 = 0x59;
  static const int CONST_OP_10 = 0x5A;
  static const int CONST_OP_11 = 0x5B;
  static const int CONST_OP_12 = 0x5C;
  static const int CONST_OP_13 = 0x5D;
  static const int CONST_OP_14 = 0x5E;
  static const int CONST_OP_15 = 0x5F;
  static const int CONST_OP_16 = 0x60;

  static const int CONST_OP_NOP = 0x61;

  static const int CONST_OP_VERIFY = 0x69;

  static const int CONST_OP_DUP = 0x76;

  static const CONST_OP_EQUAL = 0x87;
  static const CONST_OP_EQUALVERIFY = 0x88;

  static const int CONST_OP_HASH160 = 0xa9;
  static const int CONST_OP_CHECKSIG = 0xac;

  int run(Stack<ScriptData> stack);

  Uint8List get toUint8List;
}

class ScriptData extends ScriptElement {
  final Uint8List data;

  ScriptData(this.data);

  @override
  int run(Stack<ScriptData> stack) {
    stack.push(this);
    return 1; //Do nothing
  }

  @override
  bool operator ==(Object other) {
    return (other is ScriptData) ? (data.compare(other.data)) : false;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  List<Object?> get props => [data];

  @override
  Uint8List get toUint8List => data;

  @override
  String toString() {
    return "ScriptData(${data.toHex})";
  }
}

class ScriptNumber extends ScriptData {
  ScriptNumber(int number) : super(number.to8Bits());

  @override
  String toString() {
    return "ScriptNumber(${data.buffer.asByteData().getUint8(0)})";
  }
}

abstract class ScriptOperation extends ScriptElement {

  static final OP_DUP = ScriptOpDup();
  static final OP_DROP = ScriptOpDrop();
  static final OP_HASH160 = ScriptOpHash160();
  static final OP_EQUAL = ScriptOpEqual();
  static final OP_CHECKSIG = ScriptOpCheckSig();
  static final OP_DEPTH = ScriptOpDepth();
  static final OP_ADD = ScriptOpAdd();
  static final OP_HASH256 = ScriptOpHash256();
  static final OP_VERIFY = ScriptOpVerify();
  static final OP_EQUALVERIFY = ScriptOpEqualVerify();

  final int opCode;

  ScriptOperation(this.opCode);

  @override
  bool operator ==(Object other) {
    return (other is ScriptOperation) ? (opCode == other.opCode) : false;
  }

  @override
  List<Object?> get props => [opCode];

  @override
  int get hashCode => opCode;

  @override
  Uint8List get toUint8List => opCode.to8Bits();

  @override
  String toString() {
    return "${runtimeType.toString()}()";
  }
}

class ScriptOpDup extends ScriptOperation {
  ScriptOpDup() : super(ScriptElement.CONST_OP_DUP);

  @override
  int run(Stack<ScriptData> stack) {
    if(stack.isEmpty) {
      return 1;
    }
    ScriptData element = stack.pop();
    stack.push(element);
    stack.push(element);
    return 1;
  }
}

class ScriptOpDepth extends ScriptOperation {
  ScriptOpDepth() : super(0x74);

  @override
  int run(Stack<ScriptData> stack) {
    stack.push(ScriptNumber(stack.length));
    return 1;
  }

}

class ScriptOpAdd extends ScriptOperation {
  ScriptOpAdd(): super(0x93);

  @override
  int run(Stack<ScriptData> stack) {
    if(stack.length >= 2) {
      final element1 = stack.pop();
      final element2 = stack.pop();
      final value = element1.data.toUint8List.buffer.asByteData().getUint8(0) + element2.data.toUint8List.buffer.asByteData().getUint8(0);
      stack.push(ScriptNumber(value));
      return 1;
    }

    return 0;
  }
}

class ScriptOpDrop extends ScriptOperation {

  ScriptOpDrop() : super(0x75);

  @override
  int run(Stack<ScriptData> stack) {
    if(stack.isNotEmpty) {
      stack.pop();
    }

    return 1;
  }

}

class ScriptOpHash256 extends ScriptOperation {
  ScriptOpHash256() : super(0xaa);

  @override
  int run(Stack<ScriptData> stack) {
    if(stack.isEmpty) {
      return 0;
    }

    ScriptData element = stack.pop();
    final hashed = Hash.sha256(Hash.sha256(element.data));
    stack.push(ScriptData(hashed));
    return 1;
  }
}

class ScriptOpHash160 extends ScriptOperation {

  ScriptOpHash160() : super(ScriptElement.CONST_OP_HASH160);

  @override
  int run(Stack<ScriptData> stack) {
    if(stack.isEmpty) {
      return 0;
    }

    ScriptData element = stack.pop();
    final hashed = Hash.hash160(element.data);
    stack.push(ScriptData(hashed));
    return 1;
  }

}

class ScriptOpEqual extends ScriptOperation {

  ScriptOpEqual() : super(ScriptElement.CONST_OP_EQUAL);

  @override
  int run(Stack<ScriptData> stack) {
    if(stack.length >= 2) {
      final element1 = stack.pop();
      final element2 = stack.pop();

      final result = ScriptNumber((element1.data.compare(element2.data)) ? 1 : 0);
      stack.push(result);
      return 1;
    }

    return 0;
  }

}

class ScriptOpEqualVerify extends ScriptOperation {

  ScriptOpEqualVerify() : super(ScriptElement.CONST_OP_EQUALVERIFY);

  @override
  int run(Stack<ScriptData> stack) {
    if(ScriptOperation.OP_EQUAL.run(stack) > 0) {
      return ScriptOperation.OP_VERIFY.run(stack);
    }
    return 0;
  }

}

class ScriptOpCheckSig extends ScriptOperation {

  ScriptOpCheckSig() : super(ScriptElement.CONST_OP_CHECKSIG);

  @override
  int run(Stack<ScriptData> stack) {
    if(stack.length >= 2) {
      final pubKey = stack.pop();
      final sig = stack.pop();
      final sigHash = SignedHash.fromDER(pubKey.data, sig.data.sublist(0, sig.data.length - 1));
      final verified = sigHash.verify(PublicKey.fromSEC(EllipticCurve.secp256k1, pubKey.data));
      final result = (verified) ? 1 : 0;
      stack.push(ScriptNumber(result));
      return result;
    }

    return 0;
  }
}

class ScriptOpVerify extends ScriptOperation {

  ScriptOpVerify() : super(ScriptElement.CONST_OP_VERIFY);

  @override
  int run(Stack<ScriptData> stack) {
    if(stack.isNotEmpty) {
      final element = stack.pop();

      return element.data.buffer.asByteData().getUint8(0);
    }
    return 0;
  }

}


