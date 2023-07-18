import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _controllerEmail = TextEditingController();
  String? errorMessage = '';

  Future passwordReset() async {
    try {
      errorMessage = 'Password reset email has been sent';
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _controllerEmail.text.trim());
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _entryField(
    String title,
    TextEditingController controller,
    IconData prefixIcon,
    bool isPassword,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: title,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(prefixIcon, color: Colors.grey),
        ),
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
        passwordReset();
        FocusScope.of(context).unfocus();
      },
      child: const Text('Reset password'),
    );
  }

  Widget _errorMessage() {
    return Text(
      errorMessage == '' ? '' : '$errorMessage',
      style: const TextStyle(
        color: Colors.white,
        decoration: TextDecoration.underline,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          color: Colors.black,
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              children: [
                Stack(
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
                    Positioned(
                      top: 40,
                      left: 4,
                      child: BackButton(
                        color: Colors.black,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                _entryField('E-mail', _controllerEmail, Icons.person, false),
                const SizedBox(height: 10),
                _errorMessage(),
                const SizedBox(height: 10),
                _submitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
