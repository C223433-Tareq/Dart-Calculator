import 'dart:io';

import 'package:dart_cli_calculator/calculator.dart';

const _help = '''
Dart CLI Calculator
-------------------
Operators : +  -  *  /  %  ^   and parentheses ( )
Functions : sqrt(x) abs(x) sin(x) cos(x) tan(x) ln(x) log(x)
Constants : pi, e
Memory    : ans  (the last result)

Commands  : help, clear, exit (or quit)

Examples  : 2 + 3 * 4
            (10 - 4) ^ 2 / 3
            sqrt(16) + ans
''';

void main(List<String> args) {
  final calc = Calculator();

  // One-shot mode: dart run bin/main.dart "2 + 2"
  if (args.isNotEmpty) {
    try {
      stdout.writeln(formatNumber(calc.evaluate(args.join(' '))));
    } on CalculatorException catch (e) {
      stderr.writeln('Error: $e');
      exitCode = 1;
    }
    return;
  }

  // Interactive mode.
  stdout.writeln(_help);
  while (true) {
    stdout.write('> ');
    final line = stdin.readLineSync()?.trim();

    if (line == null) break; // Ctrl+D / end of input
    if (line.isEmpty) continue;

    switch (line.toLowerCase()) {
      case 'exit':
      case 'quit':
        stdout.writeln('Goodbye!');
        return;
      case 'help':
        stdout.writeln(_help);
        continue;
      case 'clear':
        stdout.write('\x1B[2J\x1B[H');
        continue;
    }

    try {
      stdout.writeln('= ${formatNumber(calc.evaluate(line))}');
    } on CalculatorException catch (e) {
      stdout.writeln('Error: $e');
    }
  }
}
