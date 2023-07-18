import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

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
            Positioned(
              top: 10,
              right: 10,
              child: Image.asset(
                'logo/male.png',
                width: 50,
                height: 50,
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  UserNameWidget(userName: user?.email ?? ''),
                  const SizedBox(height: 20),
                  const Text(
                    'Kupony:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(6, (index) {
                      return CouponCard(
                        number: index + 1,
                        title: 'Screen Glass Coupon ${index + 1}',
                        description: 'Limited time offer!',
                        discount: (index == 5) ? 'Free' : '',
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
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
      'Welcome, $userName!',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class CouponCard extends StatelessWidget {
  const CouponCard({
    Key? key,
    required this.number,
    required this.title,
    required this.description,
    required this.discount,
  }) : super(key: key);

  final int number;
  final String title;
  final String description;
  final String discount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
              ),
              padding: const EdgeInsets.all(2),
              child: const Text(
                'Świat Gier i Telefonów',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Coupon $number',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Discount: $discount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
