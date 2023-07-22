import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth.dart';
import 'forgot_password_page.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword =
      TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text.trim(),
        password: _controllerPassword.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text.trim(),
        password: _controllerPassword.text.trim(),
      );
      // Get the currently logged-in user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Get the user ID
        String userId = currentUser.uid;

        // Create a reference to the "users" node in the Realtime Database
        DatabaseReference usersRef =
            FirebaseDatabase.instance.ref().child('users');

        DateTime currentDate = DateTime.now().toUtc();

        // Create a new record for the user
        await usersRef.child(userId).set({
          'email': _controllerEmail.text.trim(),
          'Id': userId,
          'name': _controllerEmail.text.trim(),
          'createdAt': currentDate.toString(),
          'couponUsed': false,
          'coupons': {
            'coupon1': {
              'wasUsed': false,
              'couponValue': 0,
            },
            'coupon2': {
              'wasUsed': true,
              'couponValue': 0,
            },
            'coupon3': {
              'wasUsed': false,
              'couponValue': 0,
            },
            'coupon4': {
              'wasUsed': false,
              'couponValue': 0,
            },
            'coupon5': {
              'wasUsed': false,
              'couponValue': 0,
            },
            'coupon6': {
              'wasUsed': false,
              'couponValue': 0,
            },
          },
        });
      }
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

  Widget _confirmPasswordField() {
    if (isLogin) {
      return const SizedBox(height: 10);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        controller: _controllerConfirmPassword,
        style: const TextStyle(color: Colors.white),
        obscureText: true,
        decoration: const InputDecoration(
          hintText: 'Confirm Password',
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.lock, color: Colors.grey),
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
      onPressed: isLogin
          ? signInWithEmailAndPassword
          : () {
              if (_controllerPassword.text == _controllerConfirmPassword.text) {
                createUserWithEmailAndPassword();
              } else {
                setState(() {
                  errorMessage = 'Passwords do not match';
                });
              }
              FocusScope.of(context).unfocus();
            },
      child: Text(isLogin ? 'LOGIN' : 'REGISTER'),
    );
  }

  Widget _loginOrRegisterButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isLogin = !isLogin;
        });
      },
      child: Text(
        isLogin
            ? 'Not a member? Register now'
            : 'Already have an account? Login',
        style: const TextStyle(
          color: Colors.white,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _forgotPassword() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const ForgotPasswordPage();
            },
          ),
        );
        FocusScope.of(context).unfocus();
      },
      child: const Text(
        'Forgot Password?',
        style: TextStyle(
          color: Colors.white,
          decoration: TextDecoration.underline,
        ),
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
                  _entryField('E-mail', _controllerEmail, Icons.person, false),
                  const SizedBox(height: 10),
                  _entryField(
                      'Password', _controllerPassword, Icons.lock, true),
                  _confirmPasswordField(),
                  _forgotPassword(),
                  const SizedBox(height: 30),
                  _errorMessage(),
                  _submitButton(),
                  const SizedBox(height: 20),
                  _loginOrRegisterButton(),
                ],
              ),
            ),
          ),
        ));
  }
}
