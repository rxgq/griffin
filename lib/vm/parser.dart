import 'result.dart';

final class VirtualMachineParser {
  int _current = 0;

  final String _source;
  final _tokens = <int>[];

  static const Map<String, int> _opcodeMap = {
    'nop':  0x00,
    'halt': 0x01,
    'push': 0x02,
    'pop':  0x03,
    'add':  0x04,
    'sub':  0x05,
    'mul':  0x06,
    'div':  0x07,
    'jmp':  0x08,
    'out':  0x09,
    'jz':   0x0a,
    'jnz':  0x0b,
  };

  VirtualMachineParser({
    required String source
  }) : _source = source;

  VMResult parse() {
    while (_current < _source.length) {
      if (_source[_current].trim().isEmpty) {
        _current++;
        continue;
      }

      final VMResult result = switch (_isAlpha(_source[_current])) {
        true => _parseOperation(),
        false => _parseNumber(),
      };
      if (!result.isSuccess) return result;

      if (_current < _source.length) {
        _current++;
      }
    }

    return VMResult.ok(value: _tokens);
  }

  VMResult _parseOperation() {
    int start = _current;
    while (_current < _source.length && _isAlpha(_source[_current])) {
      _current++;
    }

    final stmt = _source.substring(start, _current);
    if (!_opcodeMap.containsKey(stmt)) {
      return VMResult.undefinedOperation(stmt);
    }

    _tokens.add(_opcodeMap[stmt]!);
    return VMResult.ok();
  }

  bool _isDigit(String s, int idx) => (s.codeUnitAt(idx) ^ 0x30) <= 9;

  bool _isAlpha(String str) => RegExp(r'^[a-zA-Z]$').hasMatch(str);

  VMResult _parseNumber() {
    final numStr = StringBuffer();

    while (_current < _source.length && (_isDigit(_source, _current) || _source[_current] == '-')) {
      numStr.write(_source[_current]);
      _current++;
    }
    _current--;

    final number = int.tryParse(numStr.toString());
    if (number == null) return VMResult.expectedNumberType(numStr.toString());

    _tokens.add(number);
    return VMResult.ok();
  }
}