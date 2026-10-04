import 'package:dart_cli_calculator/calculator.dart';
import 'package:test/test.dart';

void main() {
  late Calculator calc;

  setUp(() => calc = Calculator());

  test('basic arithmetic and precedence', () {
    expect(calc.evaluate('2 + 3 * 4'), 14);
    expect(calc.evaluate('(2 + 3) * 4'), 20);
    expect(calc.evaluate('10 / 4'), 2.5);
    expect(calc.evaluate('10 % 3'), 1);
  });

  test('power is right-associative and unary minus works', () {
    expect(calc.evaluate('2 ^ 3 ^ 2'), 512);
    expect(calc.evaluate('-2 ^ 2'), -4);
    expect(calc.evaluate('2 ^ -1'), 0.5);
    expect(calc.evaluate('--5'), 5);
  });

  test('functions, constants and ans', () {
    expect(calc.evaluate('sqrt(16)'), 4);
    expect(calc.evaluate('ans + 1'), 5);
    expect(calc.evaluate('log(1000)'), closeTo(3, 1e-9));
    expect(calc.evaluate('pi'), closeTo(3.14159265, 1e-8));
  });

  test('errors are reported', () {
    expect(() => calc.evaluate('1 / 0'), throwsA(isA<CalculatorException>()));
    expect(() => calc.evaluate('2 +'), throwsA(isA<CalculatorException>()));
    expect(() => calc.evaluate('(1 + 2'), throwsA(isA<CalculatorException>()));
    expect(() => calc.evaluate('sqrt(-4)'),
        throwsA(isA<CalculatorException>()));
    expect(() => calc.evaluate('foo'), throwsA(isA<CalculatorException>()));
  });

  test('formatNumber removes floating point noise', () {
    expect(formatNumber(0.1 + 0.2), '0.3');
    expect(formatNumber(14), '14');
    expect(formatNumber(2.5), '2.5');
  });
}
