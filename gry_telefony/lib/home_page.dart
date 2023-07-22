import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login/auth.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showWelcomeBanner = false;

  @override
  void initState() {
    super.initState();
    checkUserCreationDate();
  }

  Future<void> checkUserCreationDate() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final firebaseCreationDate = DateTime.fromMillisecondsSinceEpoch(
          user.metadata.creationTime!.millisecondsSinceEpoch);
      final currentDate = DateTime.now();
      final daysDifference =
          currentDate.difference(firebaseCreationDate).inDays;

      if (daysDifference <= 14) {
        // If the user's account is created within 14 days, check the coupon status
        DatabaseReference usersRef =
            FirebaseDatabase.instance.ref().child('users');

        // Use `DatabaseEvent` type to fetch the snapshot
        DatabaseEvent snapshotEvent =
            await usersRef.child(user.uid).child('couponUsed').once();

        // Access the DataSnapshot from the DatabaseEvent
        DataSnapshot snapshot = snapshotEvent.snapshot;

        // Check if the snapshot contains a valid boolean value
        if (snapshot.value is bool && snapshot.value == false) {
          // If the couponUsed is false, set the showWelcomeBanner to true
          setState(() {
            showWelcomeBanner = true;
          });
        }

        if (snapshot.value is bool && snapshot.value == true) {
          // If the couponUsed is true, hide the welcome banner
          setState(() {
            showWelcomeBanner = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Auth().currentUser;
    final DatabaseReference usersRef =
        FirebaseDatabase.instance.ref().child('users').child(user!.uid);

    Future<void> signOut() async {
      await Auth().signOut();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Świat Gier i Telefonów',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  UserNameWidget(userName: user.email ?? ''),
                  const SizedBox(height: 20),
                  if (showWelcomeBanner) const WelcomeBanner(),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(6, (index) {
                      final String couponKey = 'coupon${index + 1}';

                      return CouponCardWithFirebaseData(
                        usersRef.child('coupons').child(couponKey),
                        isFree: index == 5,
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  const GlassPurchaseButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CouponCardWithFirebaseData extends StatelessWidget {
  const CouponCardWithFirebaseData(
    this.couponRef, {
    Key? key,
    required this.isFree,
  }) : super(key: key);

  final DatabaseReference couponRef;
  final bool isFree;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: couponRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final couponData =
            snapshot.data?.snapshot.value as Map<dynamic, dynamic>? ?? {};
        final wasUsed = couponData['wasUsed'] ?? false;
        final couponValue = couponData['couponValue'] ?? 0;

        return CouponCard(
          isFree: isFree,
          wasUsed: wasUsed,
          couponValue: couponValue,
        );
      },
    );
  }
}

class WelcomeBanner extends StatelessWidget {
  const WelcomeBanner({super.key});

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

class GlassPurchaseButton extends StatelessWidget {
  const GlassPurchaseButton({super.key});

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

class UserNameWidget extends StatefulWidget {
  final String userName;

  const UserNameWidget({Key? key, required this.userName}) : super(key: key);

  @override
  _UserNameWidgetState createState() => _UserNameWidgetState();
}

class _UserNameWidgetState extends State<UserNameWidget> {
  String _displayName = '';

  @override
  void initState() {
    super.initState();
    _displayName = widget.userName;
  }

  Future<void> _changeUserName() async {
    String newDisplayName = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Wprowadź swoje imię'),
          content: TextField(
            onChanged: (value) {
              newDisplayName = value;
            },
            decoration: const InputDecoration(hintText: 'Imię'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Anuluj'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newDisplayName.trim().isNotEmpty) {
                  // Perform the name update here.
                  String userId = Auth().currentUser?.uid ?? '';

                  // Create a reference to the user node in the Realtime Database
                  DatabaseReference userRef = FirebaseDatabase.instance
                      .ref()
                      .child('users')
                      .child(userId);

                  // Update the "name" field with the new display name
                  await userRef.update({
                    'name': newDisplayName,
                  });

                  setState(() {
                    _displayName = newDisplayName;
                  });

                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Zapisz'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Witaj, $_displayName!',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
            iconSize: 18.0,
            onPressed: _changeUserName,
            icon: const Icon(Icons.edit, color: Colors.white)),
      ],
    );
  }
}

class CouponCard extends StatelessWidget {
  const CouponCard({
    Key? key,
    required this.isFree,
    required this.wasUsed,
    required this.couponValue,
  }) : super(key: key);

  final bool isFree;
  final bool wasUsed;
  final int couponValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (wasUsed)
            ClipOval(
              child: Image.asset(
                'logo/male.png',
                width: 60,
                height: 60,
              ),
            )
          else if (isFree)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Darmowe',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Szkło!',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(), // Empty widget to show nothing when coupon is not used
          if (wasUsed)
            Positioned(
              bottom: 0,
              child: Text(
                '$couponValue',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
