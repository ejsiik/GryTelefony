// ignore_for_file: nullable_type_in_catch_clause

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:barcode_scan2/barcode_scan2.dart' as scanner;
import '../login/auth.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String? errorMessage = '';

  final TextEditingController _controllerUserID = TextEditingController();
  final TextEditingController _controllerValue = TextEditingController();

  Future<void> assignCoupon() async {}

  Widget _entryField(
    String title,
    TextEditingController controller,
    IconData prefixIcon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: title,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(prefixIcon, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _errorMessage() {
    return Text(
      errorMessage == '' ? '' : 'Hmm? $errorMessage',
      style: const TextStyle(
        color: Colors.white,
        decoration: TextDecoration.underline,
      ),
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.red,
      ),
      onPressed: () async {
        if (_controllerUserID.text.isNotEmpty &&
            _controllerValue.text.isNotEmpty) {
          final DatabaseReference usersRef =
              FirebaseDatabase.instance.ref().child('users');

          String userId = _controllerUserID.text.trim();
          DatabaseEvent event = await usersRef.child(userId).once();
          DataSnapshot snapshot = event.snapshot;

          if (snapshot.value != null) {
            int couponValue = int.tryParse(_controllerValue.text.trim()) ?? 0;
            DataSnapshot couponsSnapshot = snapshot.child('coupons');
            Map<dynamic, dynamic> couponsData =
                couponsSnapshot.value as Map<dynamic, dynamic>;
            bool foundUnusedCoupon = false;
            String unusedCouponKey = '';

            couponsData.forEach((key, value) {
              if (value['wasUsed'] == false && !foundUnusedCoupon) {
                foundUnusedCoupon = true;
                unusedCouponKey = key;
              }
            });

            if (foundUnusedCoupon) {
              await usersRef
                  .child(userId)
                  .child('coupons')
                  .child(unusedCouponKey)
                  .update({
                'wasUsed': true,
                'couponValue': couponValue,
              });
            } else {
              setState(() {
                errorMessage = 'No available unused coupons for this user.';
              });
            }
          } else {
            setState(() {
              errorMessage =
                  'User with the specified ID not found in the database.';
            });
          }
        } else {
          setState(() {
            errorMessage = 'Brak danych';
          });
        }
        // ignore: use_build_context_synchronously
        FocusScope.of(context).unfocus();
      },
      child: const Text('Zarejestruj sprzedaż'),
    );
  }

  void signOut() async {
    await Auth().signOut();
  }

  Future<void> _scanQRCode() async {
    try {
      var result = await scanner.BarcodeScanner.scan();
      if (!mounted) {
        return; // Handle the case when the widget is removed from the tree during the scan process.
      }
      setState(() {
        _controllerUserID.text = result.rawContent;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Błąd przy skanowaniu';
      });
    }
  }

  Widget _scanQRButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.red,
      ),
      onPressed: _scanQRCode,
      child: const Text('Scan QR Code'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
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
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      image: DecorationImage(
                        image: AssetImage('logo/duze.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _scanQRButton(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _entryField('User ID', _controllerUserID, Icons.person),
                  const SizedBox(height: 10),
                  _entryField('Cena', _controllerValue, Icons.money),
                  const SizedBox(height: 30),
                  _errorMessage(),
                  _submitButton(),
                ],
              ),
            ),
          ),
        ));
  }
}
