# Dart CLI Calculator

A command-line calculator written in Dart. It uses a hand-written recursive-descent parser, so it understands full expressions with correct operator precedence, not just `a + b`.

## Features

- Operators: `+  -  *  /  %  ^`
- Parentheses and unary minus: `-(2 + 3) * 4`
- Functions: `sqrt`, `abs`, `sin`, `cos`, `tan`, `ln`, `log` (base 10)
- Constants: `pi`, `e`
- `ans` stores the last result
- Friendly errors (divide by zero, bad syntax, unknown names)
- Interactive mode and one-shot mode

## Requirements

[Dart SDK](https://dart.dev/get-dart) 3.0 or newer.

## Usage

```bash
dart pub get

# Interactive mode
dart run bin/main.dart

# One-shot mode
dart run bin/main.dart "2 + 3 * 4"
```

### Example session

```
> 2 + 3 * 4
= 14
> (10 - 4) ^ 2 / 3
= 12
> sqrt(16) + ans
= 16
> 1 / 0
Error: Cannot divide by zero
> exit
```

Commands: `help`, `clear`, `exit` / `quit`.

## Run the tests

```bash
dart test
```

## Project structure

```
bin/main.dart              CLI (interactive + one-shot)
lib/calculator.dart        Parser and evaluator
test/calculator_test.dart  Unit tests
```

## Build a standalone executable

```bash
dart compile exe bin/main.dart -o calc
./calc "2 + 2"
```
