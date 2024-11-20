import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart';

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
        // Calculate the result and lock it as the starting point for further calculations
        _calculateResult();
      } else {
        // Handle inputs after '='
        if (_result != '0' && _input.isEmpty && !_isOperator(buttonText)) {
          // Replace input with new number after '='
          _input = buttonText;
          _result = '0'; // Reset result to avoid confusion
        } else if (_result != '0' && _input.isEmpty && _isOperator(buttonText)) {
          // Continue calculation from the result if an operator is pressed
          _input = _result + buttonText;
          _result = '0';
        } else {
          // Append button text to input
          _input += buttonText;

          // Calculate intermediate result for dynamic updates
          if (!_isOperator(buttonText)) {
            _calculateIntermediateResult();
          }
        }
      }
    });
  }

  void _calculateIntermediateResult() {
    try {
      final expression = Expression.parse(_input);
      final evaluator = const ExpressionEvaluator();
      final result = evaluator.eval(expression, {});
      setState(() {
        _result = result.toString();
      });
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }

  void _calculateResult() {
    try {
      final expression = Expression.parse(_input);
      final evaluator = const ExpressionEvaluator();
      final result = evaluator.eval(expression, {});
      setState(() {
        _result = result.toString();
        _input = ''; // Reset input after '='
      });
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
        _buildButtonRow(['7', '8', '9', '/']),
        _buildButtonRow(['4', '5', '6', '*']),
        _buildButtonRow(['1', '2', '3', '-']),
        _buildButtonRow(['C', '0', '=', '+']),
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

