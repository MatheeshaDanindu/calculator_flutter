import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart';
import 'dart:math';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Beautiful Calculator',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        fontFamily: 'RobotoMono',
      ),
      home: CalculatorHome(),
    );
  }
}

class CalculatorHome extends StatefulWidget {
  @override
  _CalculatorHomeState createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  String _input = '';
  String _result = '0';

  int _factorial(int n) {
    if (n == 0 || n == 1) return 1; // Base case
    return n * _factorial(n - 1).toInt(); // Ensure the result is an integer
  }

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        // Clear everything
        _input = '';
        _result = '0';
      } else if (buttonText == '^') {
        // Append '^' operator
        if (_input.isNotEmpty && !_isOperator(_input[_input.length - 1])) {
          _input += '^';
        }
      } else if (buttonText == '!') {
        // Calculate the factorial of the last number
        if (_input.isNotEmpty && !_isOperator(_input[_input.length - 1])) {
          List<String> splitInput = _input.split(RegExp(r'[+\-*/()]'));
          String lastNumber = splitInput.last;

          if (lastNumber.isNotEmpty) {
            int? value = int.tryParse(lastNumber);
            if (value != null && value >= 0) {
              int factorialResult = _factorial(value);
              _input = _input.replaceFirst(lastNumber, factorialResult.toString());
              _calculateIntermediateResult();
            } else {
              _result = 'Error'; // Factorial only valid for non-negative integers
            }
          }
        }
      } else if (buttonText == '←') {
        // Backspace functionality
        if (_input.isNotEmpty) {
          _input = _input.substring(0, _input.length - 1);
        }
      } else if (buttonText == '(' || buttonText == ')') {
        // Add brackets
        _input += buttonText;
      } else if (buttonText == '=') {
        // Calculate the final result
        _calculateResult();
      } else if (buttonText == '.') {
        // Add a decimal point only if valid
        if (_input.isEmpty || _isOperator(_input[_input.length - 1])) {
          _input += '0.';
        } else {
          List<String> splitInput = _input.split(RegExp(r'[+\-*/()]'));
          if (!splitInput.last.contains('.')) {
            _input += '.';
          }
        }
      } else if (buttonText == '√') {
        // Calculate the square root of the last number
        if (_input.isEmpty) {
          double resultValue = double.tryParse(_result) ?? 0.0;
          _result = resultValue >= 0
              ? _sqrt(resultValue).toString()
              : 'Error'; // Error for negative roots
        } else {
          _calculateResult();
          double resultValue = double.tryParse(_result) ?? 0.0;
          _result = resultValue >= 0 ? _sqrt(resultValue).toString() : 'Error';
          _input = '';
        }
      } else if (buttonText == '%') {
        // Convert current number to percentage
        if (_input.isEmpty) {
          double resultValue = double.tryParse(_result) ?? 0.0;
          _result = (resultValue / 100).toString();
        } else {
          List<String> splitInput = _input.split(RegExp(r'[+\-*/()]'));
          if (splitInput.isNotEmpty) {
            double lastValue = double.tryParse(splitInput.last) ?? 0.0;
            _input = _input.replaceFirst(
              splitInput.last,
              (lastValue / 100).toString(),
            );
            _calculateIntermediateResult();
          }
        }
      } else {
        // Handle normal button presses
        if (_result != '0' && _input.isEmpty && !_isOperator(buttonText)) {
          _input = buttonText;
          _result = '0';
        } else
        if (_result != '0' && _input.isEmpty && _isOperator(buttonText)) {
          _input = _result + buttonText;
          _result = '0';
        } else {
          _input += buttonText;

          if (!_isOperator(buttonText)) {
            _calculateIntermediateResult();
          }
        }
      }
    });

  }


// Helper function to calculate square root
  double _sqrt(double value) {
    return value >= 0 ? sqrt(value) : double
        .nan; // Return NaN for negative numbers
  }


  void _calculateIntermediateResult() {
    try {
      // Replace '^' with Dart's '**' for exponentiation
      String expressionString = _input.replaceAll('^', '**');
      final expression = Expression.parse(expressionString);
      final evaluator = const ExpressionEvaluator();
      final result = evaluator.eval(expression, {});
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }


  void _calculateResult() {
    try {
      if (_input.contains('/0')) {
        setState(() {
          _result = 'Undefined'; // Division by zero returns "Undefined"
        });
      } else {
        // Replace '^' with Dart's '**' for exponentiation
        String expressionString = _input.replaceAll('^', '**');
        final expression = Expression.parse(expressionString);
        final evaluator = const ExpressionEvaluator();
        final result = evaluator.eval(expression, {});
        setState(() {
          _result = result.toString();
          _input = ''; // Clear the input after calculation
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }



  bool _isOperator(String buttonText) {
    return buttonText == '+' || buttonText == '-' || buttonText == '*' ||
        buttonText == '/';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black87,
              Colors.black54,
              Colors.tealAccent.shade700
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildDisplay(),
            SizedBox(height: 10),
            _buildButtonGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplay() {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    double displayWidth = screenWidth * 0.94;

    return Center(
      child: Container(
        width: displayWidth,
        height: 150.0,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _input.isEmpty ? '0' : _input,
              style: TextStyle(fontSize: 28.0, color: Colors.tealAccent),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 8.0),
            Text(
              _result,
              style: TextStyle(fontSize: 36.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonGrid() {
    return Column(
      children: [
        _buildButtonRow(['(', '^', '!', ')'], isRectangle: true),
        _buildButtonRow(['C', '√', '%', '←'], isRectangle: true),
        _buildButtonRow(['7', '8', '9', '*']),
        _buildButtonRow(['4', '5', '6', '-']),
        _buildButtonRow(['1', '2', '3', '+']),
        _buildButtonRow(['.', '0', '=', '/']),
      ],
    );
  }


  Widget _buildButtonRow(List<String> buttons, {bool isRectangle = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons.map((buttonText) {
        return CalculatorButton(
          text: buttonText,
          onTap: () => _onButtonPressed(buttonText),
          isRectangle: isRectangle, // Pass a flag for rectangle buttons
        );
      }).toList(),
    );
  }
}

class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isRectangle;

  CalculatorButton({
    required this.text,
    required this.onTap,
    this.isRectangle = false, // Default to circular
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonSize = isRectangle ? screenWidth * 0.2 : screenWidth * 0.2; // Keep the width consistent
    double buttonHeight = isRectangle ? screenWidth * 0.12 : buttonSize; // Height adjustment for rectangles

    bool isOperator = text == '/' || text == '*' || text == '-' || text == '+';
    Color buttonColor = isOperator ? Colors.tealAccent : Colors.white;
    Color textColor = isOperator ? Colors.black : Colors.tealAccent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: buttonSize,
        height: buttonHeight,
        margin: EdgeInsets.all(screenWidth * 0.015),
        decoration: BoxDecoration(
          borderRadius: isRectangle
              ? BorderRadius.circular(10.0) // Rounded rectangle
              : BorderRadius.circular(50.0), // Circle for other buttons
          gradient: LinearGradient(
            colors: isOperator ? [Colors.teal, Colors.tealAccent] : [Colors.grey.shade800, Colors.grey.shade700],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              offset: Offset(2, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: buttonSize * 0.35,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}


