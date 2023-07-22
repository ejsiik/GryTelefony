import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gry_telefony/user_home_page/welcome_banner.dart';
import '../login/auth.dart';
import 'coupons.dart';
import 'glass_purchase.dart';
import 'username_widget.dart';

class UserDataProvider {
  final User? user;

  UserDataProvider(this.user);

  Future<bool> isUserCreatedWithin14Days() async {
    if (user == null) return false;

    final firebaseCreationDate = DateTime.fromMillisecondsSinceEpoch(
        user!.metadata.creationTime!.millisecondsSinceEpoch);
    final currentDate = DateTime.now();
    final daysDifference = currentDate.difference(firebaseCreationDate).inDays;

    if (daysDifference <= 14) {
      final DatabaseEvent snapshotEvent = await FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user!.uid)
          .child('couponUsed')
          .once();

      final DataSnapshot snapshot = snapshotEvent.snapshot;

      if (snapshot.value is bool && snapshot.value == false) {
        return true;
      }
    }

    return false;
  }

  DatabaseReference getCouponRef(int index) {
    return FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(user!.uid)
        .child('coupons')
        .child('coupon${index + 1}');
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showWelcomeBanner = false;
  User? user;

  @override
  void initState() {
    super.initState();
    user = Auth().currentUser;
    checkUserCreationDate();
  }

  Future<void> checkUserCreationDate() async {
    final userDataProvider = UserDataProvider(user);
    final isCreatedWithin14Days =
        await userDataProvider.isUserCreatedWithin14Days();

    setState(() {
      showWelcomeBanner = isCreatedWithin14Days;
    });
  }

  void signOut() async {
    await Auth().signOut();
  }

  @override
  Widget build(BuildContext context) {
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
                  UserNameWidget(user: user),
                  const SizedBox(height: 20),
                  if (showWelcomeBanner) const WelcomeBanner(),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(6, (index) {
                      return CouponCardWithFirebaseData(
                        UserDataProvider(user).getCouponRef(index),
                        isFree: index == 5,
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  GlassPurchaseButton(user: user),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
