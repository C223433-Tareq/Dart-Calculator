import 'dart:math' as math;

/// Thrown when an expression is invalid or cannot be evaluated.
class CalculatorException implements Exception {
  CalculatorException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// A calculator that evaluates math expressions and remembers the last result.
///
/// Supports: + - * / % ^, parentheses, unary minus, `ans`, constants (pi, e)
/// and functions (sqrt, abs, sin, cos, tan, ln, log).
class Calculator {
  double ans = 0;

  double evaluate(String input) {
    if (input.trim().isEmpty) {
      throw CalculatorException('Empty expression');
    }
    final result = _Parser(input, ans).parse();
    if (result.isNaN || result.isInfinite) {
      throw CalculatorException('Math error: result is not a real number');
    }
    ans = result;
    return result;
  }
}

/// Formats a number for display (drops float noise like 0.30000000000000004).
String formatNumber(double value) {
  if (value == value.truncateToDouble() && value.abs() < 1e15) {
    return value.toInt().toString();
  }
  var s = value.toStringAsPrecision(12);
  if (s.contains('e')) return s;
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r'\.$'), '');
  }
  return s;
}

/// Recursive-descent parser.
///
/// expr    := term (('+' | '-') term)*
/// term    := unary (('*' | '/' | '%') unary)*
/// unary   := ('-' | '+') unary | power
/// power   := primary ('^' unary)?
/// primary := number | constant | function '(' expr ')' | '(' expr ')'
class _Parser {
  _Parser(this._src, this._ans);

  final String _src;
  final double _ans;
  int _pos = 0;

  static final _numberRe = RegExp(r'\d+(\.\d*)?|\.\d+');
  static final _identRe = RegExp(r'[a-zA-Z_]+');

  double parse() {
    final value = _expr();
    _skipSpaces();
    if (_pos < _src.length) {
      throw CalculatorException(
          "Unexpected '${_src[_pos]}' at position ${_pos + 1}");
    }
    return value;
  }

  void _skipSpaces() {
    while (_pos < _src.length && _src[_pos].trim().isEmpty) {
      _pos++;
    }
  }

  bool _match(String char) {
    _skipSpaces();
    if (_pos < _src.length && _src[_pos] == char) {
      _pos++;
      return true;
    }
    return false;
  }

  double _expr() {
    var value = _term();
    while (true) {
      if (_match('+')) {
        value += _term();
      } else if (_match('-')) {
        value -= _term();
      } else {
        return value;
      }
    }
  }

  double _term() {
    var value = _unary();
    while (true) {
      if (_match('*')) {
        value *= _unary();
      } else if (_match('/')) {
        final divisor = _unary();
        if (divisor == 0) throw CalculatorException('Cannot divide by zero');
        value /= divisor;
      } else if (_match('%')) {
        final divisor = _unary();
        if (divisor == 0) throw CalculatorException('Cannot modulo by zero');
        value %= divisor;
      } else {
        return value;
      }
    }
  }

  double _unary() {
    if (_match('-')) return -_unary();
    if (_match('+')) return _unary();
    return _power();
  }

  double _power() {
    final base = _primary();
    if (_match('^')) {
      final exponent = _unary(); // right-associative
      return math.pow(base, exponent).toDouble();
    }
    return base;
  }

  double _primary() {
    _skipSpaces();
    if (_pos >= _src.length) {
      throw CalculatorException('Unexpected end of expression');
    }

    if (_match('(')) {
      final value = _expr();
      if (!_match(')')) throw CalculatorException("Missing closing ')'");
      return value;
    }

    final number = _numberRe.matchAsPrefix(_src, _pos);
    if (number != null) {
      _pos = number.end;
      return double.parse(number.group(0)!);
    }

    final ident = _identRe.matchAsPrefix(_src, _pos);
    if (ident != null) {
      _pos = ident.end;
      return _identifier(ident.group(0)!.toLowerCase());
    }

    throw CalculatorException(
        "Unexpected '${_src[_pos]}' at position ${_pos + 1}");
  }

  double _identifier(String name) {
    switch (name) {
      case 'pi':
        return math.pi;
      case 'e':
        return math.e;
      case 'ans':
        return _ans;
    }

    const functions = {'sqrt', 'abs', 'sin', 'cos', 'tan', 'ln', 'log'};
    if (!functions.contains(name)) {
      throw CalculatorException("Unknown name '$name'");
    }
    if (!_match('(')) throw CalculatorException("Expected '(' after '$name'");
    final arg = _expr();
    if (!_match(')')) throw CalculatorException("Missing closing ')'");

    switch (name) {
      case 'sqrt':
        if (arg < 0) throw CalculatorException('sqrt of a negative number');
        return math.sqrt(arg);
      case 'abs':
        return arg.abs();
      case 'sin':
        return math.sin(arg);
      case 'cos':
        return math.cos(arg);
      case 'tan':
        return math.tan(arg);
      case 'ln':
        if (arg <= 0) throw CalculatorException('ln needs a positive number');
        return math.log(arg);
      default: // log (base 10)
        if (arg <= 0) throw CalculatorException('log needs a positive number');
        return math.log(arg) / math.ln10;
    }
  }
}
