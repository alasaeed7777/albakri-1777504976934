```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ø­Ø§Ø³Ø¨Ù',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueGrey,
        brightness: Brightness.light,
      ),
      debugShowCheckedModeBanner: false,
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  double? _firstOperand;
  String? _operator;
  bool _waitingForSecondOperand = false;
  String _expression = '';

  void _inputDigit(String digit) {
    setState(() {
      if (_waitingForSecondOperand) {
        _display = digit;
        _waitingForSecondOperand = false;
      } else {
        _display = _display == '0' ? digit : _display + digit;
      }
    });
  }

  void _inputDecimal() {
    setState(() {
      if (_waitingForSecondOperand) {
        _display = '0.';
        _waitingForSecondOperand = false;
        return;
      }
      if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  void _performOperation(String operator) {
    if (_operator != null && !_waitingForSecondOperand) {
      _calculate();
    }
    _firstOperand = double.parse(_display);
    _operator = operator;
    _waitingForSecondOperand = true;
    _expression = '$_firstOperand $operator';
  }

  void _calculate() {
    if (_operator == null || _firstOperand == null) return;
    final double secondOperand = double.parse(_display);
    double result;
    switch (_operator) {
      case '+':
        result = _firstOperand! + secondOperand;
        break;
      case '-':
        result = _firstOperand! - secondOperand;
        break;
      case 'Ã':
        result = _firstOperand! * secondOperand;
        break;
      case 'Ã·':
        result = secondOperand != 0 ? _firstOperand! / secondOperand : double.nan;
        break;
      default:
        return;
    }
    _expression = '$_firstOperand $_operator $secondOperand =';
    _display = result.isNaN ? 'Error' : _formatResult(result);
    _firstOperand = result;
    _operator = null;
    _waitingForSecondOperand = true;
  }

  String _formatResult(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  void _clear() {
    setState(() {
      _display = '0';
      _firstOperand = null;
      _operator = null;
      _waitingForSecondOperand = false;
      _expression = '';
    });
  }

  void _delete() {
    setState(() {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
      }
    });
  }

  void _toggleSign() {
    setState(() {
      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else if (_display != '0') {
        _display = '-$_display';
      }
    });
  }

  void _percentage() {
    setState(() {
      final double value = double.parse(_display) / 100;
      _display = _formatResult(value);
    });
  }

  Widget _buildButton(String text, {Color? color, double flex = 1}) {
    return Expanded(
      flex: flex ~/ 1,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          height: 70,
          child: ElevatedButton(
            onPressed: () {
              switch (text) {
                case 'C':
                  _clear();
                  break;
                case 'â«':
                  _delete();
                  break;
                case 'Â±':
                  _toggleSign();
                  break;
                case '%':
                  _percentage();
                  break;
                case 'Ã·':
                case 'Ã':
                case '-':
                case '+':
                  _performOperation(text);
                  break;
                case '=':
                  _calculate();
                  break;
                case '.':
                  _inputDecimal();
                  break;
                default:
                  _inputDigit(text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color ?? Theme.of(context).colorScheme.surfaceContainerHighest,
              foregroundColor: color != null ? Colors.white : Theme.of(context).colorScheme.onSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Display area
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _expression,
                      style: TextStyle(
                        fontSize: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _display,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              ),
            ),
            // Button area
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Row 1: C, â«, %, Ã·
                    Row(
                      children: [
                        _buildButton('C', color: colorScheme.error),
                        _buildButton('â«', color: colorScheme.tertiary),
                        _buildButton('%', color: colorScheme.tertiary),
                        _buildButton('Ã·', color: colorScheme.primary),
                      ],
                    ),
                    // Row 2: 7, 8, 9, Ã
                    Row(
                      children: [
                        _buildButton('7'),
                        _buildButton('8'),
                        _buildButton('9'),
                        _buildButton('Ã', color: colorScheme.primary),
                      ],
                    ),
                    // Row 3: 4, 5, 6, -
                    Row(
                      children: [
                        _buildButton('4'),
                        _buildButton('5'),
                        _buildButton('6'),
                        _buildButton('-', color: colorScheme.primary),
                      ],
                    ),
                    // Row 4: 1, 2, 3, +
                    Row(
                      children: [
                        _buildButton('1'),
                        _buildButton('2'),
                        _buildButton('3'),
                        _buildButton('+', color: colorScheme.primary),
                      ],
                    ),
                    // Row 5: 0, ., Â±, =
                    Row(
                      children: [
                        _buildButton('0', flex: 2),
                        _buildButton('.'),
                        _buildButton('Â±'),
                        _buildButton('=', color: colorScheme.primary),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```