import 'dart:typed_data';
import 'package:btc_sdk/btc_sdk.dart';
import 'package:equatable/equatable.dart';
import 'package:stack/stack.dart';

abstract class ScriptElement implements Equatable {

  int run(Stack<ScriptElement> stack);
}

class ScriptData extends ScriptElement {
  final Uint8List data;

  ScriptData(this.data);

  @override
  int run(Stack<ScriptElement> stack) {
    return 1; //Do nothing
  }

  @override
  List<Object?> get props => [data];

  @override
  bool? get stringify => true;

}

class ScriptNumber extends ScriptData {
  ScriptNumber(int number) : super(number.to8Bits());
}

abstract class ScriptOperation extends ScriptElement {
  final int opCode;

  ScriptOperation(this.opCode);

  @override
  // TODO: implement props
  List<Object?> get props => [opCode];

  @override
  bool? get stringify => true;
}

class ScriptOpDup extends ScriptOperation {
  ScriptOpDup() : super(0x76);

  @override
  int run(Stack<ScriptElement> stack) {
    if(stack.isEmpty) {
      return 1;
    }
    ScriptElement element = stack.pop();
    stack.push(element);
    stack.push(element);
    return 1;
  }
}

class ScriptOpDepth extends ScriptOperation {
  ScriptOpDepth() : super(0x74);

  @override
  int run(Stack<ScriptElement> stack) {
    stack.push(ScriptNumber(stack.length));
    return 1;
  }

}

class ScriptOpDrop extends ScriptOperation {

  ScriptOpDrop() : super(0x75);

  @override
  int run(Stack<ScriptElement> stack) {
    if(stack.isNotEmpty) {
      stack.pop();
    }

    return 1;
  }

}

class ScriptOpHash160 extends ScriptOperation {

  ScriptOpHash160() : super(0xa9);

  @override
  int run(Stack<ScriptElement> stack) {
    if(stack.isEmpty) {
      return 0;
    }

    ScriptElement element = stack.pop();
    if(element is ScriptData) {
      final hashed = Hash.hash160(element.data);
      stack.push(ScriptData(hashed));
      return 1;
    }

    return 0;
  }

}

class ScriptOpEqual extends ScriptOperation {

  ScriptOpEqual() : super(0x87);

  @override
  int run(Stack<ScriptElement> stack) {
    if(stack.length >= 2) {
      final element1 = stack.pop();
      final element2 = stack.pop();

      final result = ScriptNumber((element1 == element2) ? 1 : 0);
      stack.push(result);
    }

    return 0;
  }

}

class ScriptOpCheckSig extends ScriptOperation {

  ScriptOpCheckSig() : super(0xac);

  @override
  int run(Stack<ScriptElement> stack) {
    if(stack.length >= 2) {
      final pubKey = stack.pop();
      final sig = stack.pop();

    }
    throw UnimplementedError();
  }
}


