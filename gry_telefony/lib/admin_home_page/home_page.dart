import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

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
      onPressed: () {
        if (_controllerUserID.text.isNotEmpty &&
            _controllerValue.text.isNotEmpty) {
        } else {
          setState(() {
            errorMessage = 'Passwords do not match';
          });
        }
        FocusScope.of(context).unfocus();
      },
      child: const Text('Zarejestruj sprzedaż'),
    );
  }

  void signOut() async {
    await Auth().signOut();
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
