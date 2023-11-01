import 'dart:typed_data';

import '../../btc_sdk.dart';

class ScriptReader {
  final Uint8ListReader reader;

  ScriptReader(this.reader);

  factory ScriptReader.fromBytes(Uint8List script) => ScriptReader(Uint8ListReader(script));

  List<ScriptElement> readAll() {
    List<ScriptElement> expression = [];
    while(hasNext) {
      ScriptElement? element = readNext();
      if(element == null) {
        break;
      }
      expression.add(element);
    }

    return expression;
  }

  ScriptElement? readNext() {
    if(reader.currentPosition >= reader.data.length) {
      return null;
    }

    final opCode = reader.readUint8();
    return (opCode < 0) ? null : _createElement(opCode);
  }

  bool get hasNext => reader.hasNext;

  ScriptElement _createElement(int opCode) {
    if(opCode < ScriptElement.CONST_OP_PUSHDATA1) {
      return _createScriptData(opCode);
    }

    if(opCode >= ScriptElement.CONST_OP_1 && opCode <= ScriptElement.CONST_OP_16) {
      return ScriptNumber(opCode - 0x50);
    }

    switch(opCode) {
      case ScriptElement.CONST_OP_PUSHDATA1:
        return _createScriptData(reader.readUint8());
      case ScriptElement.CONST_OP_PUSHDATA2:
        return _createScriptData(reader.readUint16(littleEndian: true));
      case ScriptElement.CONST_OP_PUSHDATA4:
        return _createScriptData(reader.readUint32(littleEndian: true));
      case ScriptElement.CONST_OP_DUP:
        return ScriptOperation.OP_DUP;
      case ScriptElement.CONST_OP_HASH160:
        return ScriptOperation.OP_HASH160;
      case ScriptElement.CONST_OP_EQUALVERIFY:
        return ScriptOperation.OP_EQUALVERIFY;
      case ScriptElement.CONST_OP_EQUAL:
        return ScriptOperation.OP_EQUAL;
      default:
        throw UnimplementedError();
    }
  }

  ScriptData _createScriptData(int bytes) => ScriptData(reader.readSegment(bytes));
}