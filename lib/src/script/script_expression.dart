import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';

class ScriptExpression {
  final List<ScriptElement> expression;

  ScriptExpression(this.expression);

  factory ScriptExpression.fromReader(ScriptReader reader) => ScriptExpression(reader.readAll());

  Uint8List get toUint8List => expression.fold(Uint8List(0), (previousValue, element) => previousValue.concat(element.toUint8List));
}