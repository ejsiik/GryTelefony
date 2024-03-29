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
  bool _welcomeBanner = false;

  final TextEditingController _controllerUserID = TextEditingController();
  final TextEditingController _controllerValue = TextEditingController();

  Future<void> assignCoupon() async {}

  Widget _entryField(
    String title,
    TextEditingController controller,
    IconData prefixIcon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title == 'Cena')
            Row(
              children: [
                Checkbox(
                  value: _welcomeBanner,
                  onChanged: (value) {
                    setState(() {
                      _welcomeBanner = value ?? false;
                      if (_welcomeBanner) {
                        controller.clear();
                      }
                    });
                  },
                  activeColor: Colors.grey, // Checkbox color when selected
                  checkColor: Colors.black, // Checkmark color when selected
                  fillColor: MaterialStateColor.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.grey; // Checkbox color when unselected
                    }
                    return Colors.grey;
                  }),
                ),
                const Text(
                  'Kupon powitalny',
                  style: TextStyle(color: Colors.grey), // Text color
                ),
              ],
            ),
          TextField(
            controller: controller,
            enabled: title != 'Cena' || !_welcomeBanner,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: title,
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: Icon(prefixIcon, color: Colors.grey),
            ),
            keyboardType:
                title == 'Cena' ? TextInputType.number : TextInputType.text,
          ),
        ],
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
        if (_controllerUserID.text.isNotEmpty) {
          final DatabaseReference usersRef =
              FirebaseDatabase.instance.ref().child('users');

          String userId = _controllerUserID.text.trim();
          DatabaseEvent event = await usersRef.child(userId).once();
          DataSnapshot snapshot = event.snapshot;

          if (snapshot.value != null) {
            if (_welcomeBanner) {
              // Update the 'couponUsed' field to true in the database
              await usersRef.child(userId).child('couponUsed').set(true);
              errorMessage = "Wykorzystano kupon powitalny";
            } else {
              if (_controllerValue.text.isNotEmpty) {
                int couponValue =
                    int.tryParse(_controllerValue.text.trim()) ?? 0;

                final DatabaseReference usersRef =
                    FirebaseDatabase.instance.ref().child('users');

                String userId = _controllerUserID.text.trim();
                DatabaseEvent event = await usersRef.child(userId).once();

                if (event.snapshot.value != null) {
                  // Retrieve the user's data from Firebase
                  Map<dynamic, dynamic>? userData =
                      event.snapshot.value as Map<dynamic, dynamic>?;

                  if (userData != null) {
                    // Retrieve the 'coupons' map from the user's data with a null check
                    Map<dynamic, dynamic>? couponsData =
                        userData['coupons'] as Map<dynamic, dynamic>?;

                    if (couponsData != null) {
                      // Create a list of coupon keys sorted in ascending order
                      List couponKeys = couponsData.keys.toList();
                      couponKeys.sort();

                      bool foundUnusedCoupon = false;
                      String? unusedCouponKey;

                      // Iterate through the sorted keys
                      for (String key in couponKeys) {
                        if (couponsData[key]['wasUsed'] == false) {
                          foundUnusedCoupon = true;
                          unusedCouponKey = key;
                          break; // Exit the loop as soon as an unused coupon is found
                        }
                      }

                      if (foundUnusedCoupon && unusedCouponKey != null) {
                        // Update the specific coupon to mark it as used
                        await usersRef
                            .child(userId)
                            .child('coupons')
                            .child(unusedCouponKey)
                            .update({
                          'wasUsed': true,
                          'couponValue': couponValue,
                        });

                        // Check if five coupons are used
                        int usedCouponsCount = 0;
                        couponsData.forEach((key, value) {
                          if (value['wasUsed'] == true) {
                            usedCouponsCount++;
                          }
                        });

                        if (usedCouponsCount >= 5) {
                          double totalCouponValue = 0;

                          couponsData.forEach((key, value) {
                            if (value['wasUsed'] == true) {
                              totalCouponValue += (value['couponValue'] as int);
                            }
                          });
                          // Check for the Average value of coupons
                          double meanCouponValue = totalCouponValue / 5;
                          // Set all coupons to false
                          couponsData.forEach((key, value) async {
                            await usersRef
                                .child(userId)
                                .child('coupons')
                                .child(key)
                                .update({
                              'wasUsed': false,
                              'couponValue': 0,
                            });
                          });

                          setState(() {
                            errorMessage =
                                'Zakupione szkło jest darmowe! Średnia wartość: $meanCouponValue';
                          });
                        } else {
                          setState(() {
                            errorMessage = 'Kupon przyjęty';
                          });
                        }
                      } else {
                        setState(() {
                          errorMessage = 'Brak dostępnych kuponów';
                        });
                      }
                    } else {
                      setState(() {
                        errorMessage = 'Brak dostępnych kuponów';
                      });
                    }
                  } else {
                    setState(() {
                      errorMessage = 'Brak danych użytkownika';
                    });
                  }
                } else {
                  setState(() {
                    errorMessage = 'Podaj ID użytkownika';
                  });
                }
              } else {
                setState(() {
                  errorMessage = 'Podaj cenę szkła';
                });
              }
            }
          }
        } else {
          setState(() {
            errorMessage = 'Podaj ID użytkownika';
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
