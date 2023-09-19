import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:gry_telefony/user_home_page/phone_data.dart';
import 'admin_home_page/home_page.dart';
import 'login/login_register.dart';
import 'login/verify_email_page.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;

          if (user != null) {
            String userEmailAddress =
                user.email ?? ""; // Fetch user's email address

            if (userEmailAddress == "daw.wydra@gmail.com") {
              return const AdminHomePage();
              //return MyApp();
            } else {
              return const VerifyEmailPage();
              //return MyApp();
            }
          } else {
            return const LoginPage();
          }
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
