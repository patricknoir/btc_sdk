import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';
import 'package:stack/stack.dart';

class ScriptExpression {
  final List<ScriptElement> expression;

  ScriptExpression(this.expression);

  factory ScriptExpression.fromReader(ScriptReader reader) => ScriptExpression(reader.readAll());
  factory ScriptExpression.fromBytes(Uint8List script) => ScriptExpression.fromReader(ScriptReader.fromBytes(script));

  Uint8List get toUint8List => expression.fold(Uint8List(0), (previousValue, element) => previousValue.concat(element.toUint8List));

  ScriptExpression concat(ScriptExpression exp) => ScriptExpression(expression + exp.expression);

  operator >>(ScriptExpression exp) => concat(exp);

  int run(Stack<ScriptData> stack) {
    for(var exp in expression) {
      final result = exp.run(stack);
      if(result == 0) {
        return 0;
      }
    }
    return 1;
  }

  operator +(ScriptElement element) => this >> ScriptExpression([element]);
}