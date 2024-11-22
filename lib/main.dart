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

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        // Clear everything
        _input = '';
        _result = '0';
      } else if (buttonText == '=') {
        // Calculate the final result
        _calculateResult();
      } else if (buttonText == '.') {
        // Add a decimal point only if valid
        if (_input.isEmpty || _isOperator(_input[_input.length - 1])) {
          _input += '0.';
        } else {
          List<String> splitInput = _input.split(RegExp(r'[+\-*/]'));
          if (!splitInput.last.contains('.')) {
            _input += '.';
          }
        }
      } else if (buttonText == '√') {
        // Calculate the square root of the last number
        if (_input.isEmpty) {
          double resultValue = double.tryParse(_result) ?? 0.0;
          _result = resultValue >= 0 ? _sqrt(resultValue).toString() : 'Error'; // Error for negative roots
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
          List<String> splitInput = _input.split(RegExp(r'[+\-*/]'));
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
        } else if (_result != '0' && _input.isEmpty && _isOperator(buttonText)) {
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
    return value >= 0 ? sqrt(value) : double.nan; // Return NaN for negative numbers
  }



  void _calculateIntermediateResult() {
    try {
      final expression = Expression.parse(_input);
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
        final expression = Expression.parse(_input);
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
    return buttonText == '+' || buttonText == '-' || buttonText == '*' || buttonText == '/';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.black54, Colors.tealAccent.shade700],
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
    double screenWidth = MediaQuery.of(context).size.width;
    double displayWidth = screenWidth * 0.9;

    return Center(
      child: Container(
        width: displayWidth,
        height: 120.0,
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
              style: TextStyle(fontSize: 36.0, color: Colors.white, fontWeight: FontWeight.bold),
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
        _buildButtonRow(['C', '√', '%', '/']), // Added √ and %
        _buildButtonRow(['7', '8', '9', '*']),
        _buildButtonRow(['4', '5', '6', '-']),
        _buildButtonRow(['1', '2', '3', '+']),
        _buildButtonRow(['0', '.', '=', '']), // "=" is kept
      ],
    );
  }



  Widget _buildButtonRow(List<String> buttons) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons.map((buttonText) {
        return CalculatorButton(
          text: buttonText,
          onTap: () => _onButtonPressed(buttonText),
        );
      }).toList(),
    );
  }
}

class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  CalculatorButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonSize = screenWidth * 0.2; // Buttons occupy 20% of screen width

    bool isOperator = text == '/' || text == '*' || text == '-' || text == '+';
    Color buttonColor = isOperator ? Colors.tealAccent : Colors.white;
    Color textColor = isOperator ? Colors.black : Colors.tealAccent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: buttonSize, // Adjusted size dynamically
        height: buttonSize, // Adjusted size dynamically
        margin: EdgeInsets.all(screenWidth * 0.015), // Margin as a percentage of width
        decoration: BoxDecoration(
          shape: BoxShape.circle,
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
              fontSize: buttonSize * 0.35, // Font size as 35% of button size
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

