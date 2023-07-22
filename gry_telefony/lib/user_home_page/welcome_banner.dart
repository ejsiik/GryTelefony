import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class WelcomeBanner extends StatelessWidget {
  const WelcomeBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.yellow,
      child: Column(
        children: [
          const Text(
            'Przyznano 10% zniżki na akcesoria!\nKupon ważny przez 2 tygodnie od założenia konta.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title:
                        const Text('Czy jesteś pewien, że chcesz użyć kuponu?'),
                    content: const Text(
                        'Nie zamykaj tego okna przed okazaniem go sprzedawcy'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Anuluj'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // Get the current user
                          User? user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            // Update the 'couponUsed' field to true in the database
                            DatabaseReference usersRef =
                                FirebaseDatabase.instance.ref().child('users');
                            await usersRef
                                .child(user.uid)
                                .child('couponUsed')
                                .set(true);
                          }
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Użyj kuponu'),
                      ),
                    ],
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'Wykorzystaj',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
