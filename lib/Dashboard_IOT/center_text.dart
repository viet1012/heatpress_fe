import 'package:flutter/material.dart';
class CenteredText extends StatelessWidget {
  final String text;
  final Color colorsText;

  const CenteredText(this.text, this.colorsText, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: colorsText,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
