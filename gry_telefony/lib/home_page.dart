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
  bool showWelcomeBanner = true;

  @override
  void initState() {
    super.initState();
    // Timer do ukrycia banera po 14 dniach
    Timer(const Duration(days: 14), () {
      setState(() {
        showWelcomeBanner = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Auth().currentUser;

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
                  UserNameWidget(userName: user?.email ?? ''),
                  const SizedBox(height: 20),
                  if (showWelcomeBanner) const WelcomeBanner(),
                  /*const Text(
                    'Kupony:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),*/
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(6, (index) {
                      return CouponCard(
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
              // onPressed
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
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
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: const Text(
        'Zakup szkło',
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
      ),
    );
  }
}

class UserNameWidget extends StatelessWidget {
  const UserNameWidget({Key? key, required this.userName}) : super(key: key);

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Witaj, $userName!',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class CouponCard extends StatelessWidget {
  const CouponCard({Key? key, required this.isFree}) : super(key: key);

  final bool isFree;

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
      child: isFree
          ? const Center(
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
          : ClipOval(
              child: Image.asset(
                'logo/male.png',
                width: 60,
                height: 60,
              ),
            ),
    );
  }
}
