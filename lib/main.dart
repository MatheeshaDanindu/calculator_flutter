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
        _input = '';
        _result = '0';
      } else if (buttonText == '=') {
        _calculateResult();
      } else {
        _input += buttonText;
      }
    });
  }

  void _calculateResult() {
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
    double screenWidth = MediaQuery.of(context).size.width;
    double displayWidth = screenWidth * 0.95; // 90% of screen width
    double minFontSize = 28.0; // Minimum font size before switching to scientific notation
    double maxFontSizeInput = 36.0; // Maximum font size for input
    double maxFontSizeResult = 48.0; // Maximum font size for result

    return Center(
      child: Container(
        width: displayWidth, // Set width to 90% of the screen
        height: 150.0, // Fixed height
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              offset: Offset(2, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Input Display
            LayoutBuilder(
              builder: (context, constraints) {
                double fontSize = maxFontSizeInput;
                String displayText = _input.isEmpty ? '0' : _input;

                // Adjust font size dynamically
                while (_textWidth(displayText, fontSize) > constraints.maxWidth && fontSize > minFontSize) {
                  fontSize -= 1.0; // Decrease font size
                }

                // Convert to scientific notation if minimum font size is reached
                if (fontSize <= minFontSize && _textWidth(displayText, fontSize) > constraints.maxWidth) {
                  displayText = _convertToScientific(displayText);
                }

                return Text(
                  displayText,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.tealAccent,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.right,
                );
              },
            ),
            SizedBox(height: 8.0), // Space between input and result
            // Result Display
            LayoutBuilder(
              builder: (context, constraints) {
                double fontSize = maxFontSizeResult;
                String displayText = _result;

                // Adjust font size dynamically
                while (_textWidth(displayText, fontSize) > constraints.maxWidth && fontSize > minFontSize) {
                  fontSize -= 1.0; // Decrease font size
                }

                // Convert to scientific notation if minimum font size is reached
                if (fontSize <= minFontSize && _textWidth(displayText, fontSize) > constraints.maxWidth) {
                  displayText = _convertToScientific(displayText);
                }

                return Text(
                  displayText,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

// Helper method to calculate text width
  double _textWidth(String text, double fontSize) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fontSize)),
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

// Helper method to convert to scientific notation
  String _convertToScientific(String text) {
    try {
      double value = double.parse(text);
      return value.toStringAsExponential(3); // 3 significant figures
    } catch (e) {
      return 'Error';
    }
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
        return Expanded( // Ensure buttons fill available space
          child: CalculatorButton(
            text: buttonText,
            onTap: () => _onButtonPressed(buttonText),
          ),
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
    double buttonSize = screenWidth * 0.18; // Buttons are 18% of screen width

    bool isOperator = text == '/' || text == '*' || text == '-' || text == '+';
    Color buttonColor = isOperator ? Colors.tealAccent : Colors.white;
    Color textColor = isOperator ? Colors.black : Colors.tealAccent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: buttonSize,
        height: buttonSize,
        margin: EdgeInsets.all(8.0),
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
              fontSize: buttonSize * 0.4, // Font size 40% of button size
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

