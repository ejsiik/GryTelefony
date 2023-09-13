import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

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
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
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
