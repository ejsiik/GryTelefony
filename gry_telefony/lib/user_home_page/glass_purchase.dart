import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class GlassPurchaseButton extends StatelessWidget {
  const GlassPurchaseButton({Key? key, required this.user}) : super(key: key);
  final User? user;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        String userId = user?.uid ?? '';
        DatabaseReference userRef =
            FirebaseDatabase.instance.ref().child('users').child(userId);
        // Use `once()` to get the DatabaseEvent
        DatabaseEvent event = await userRef.once();
        // Extract DataSnapshot from the DatabaseEvent
        DataSnapshot snapshot = event.snapshot;

        if (snapshot.value != null) {
          // ignore: use_build_context_synchronously
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('User ID'),
                content: Text(
                    'User ID: $userId'), // in the future probably qr code will be displayed
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
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
