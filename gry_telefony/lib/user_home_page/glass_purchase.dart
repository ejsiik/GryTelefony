import 'package:flutter/material.dart';

class GlassPurchaseButton extends StatelessWidget {
  const GlassPurchaseButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // onPressed
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: const Text(
        'Zakup szkło',
        style: TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }
}
