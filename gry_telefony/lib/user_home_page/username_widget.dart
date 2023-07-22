import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../login/auth.dart';

class UserNameWidget extends StatefulWidget {
  final User? user;

  const UserNameWidget({Key? key, required this.user}) : super(key: key);

  @override
  _UserNameWidgetState createState() => _UserNameWidgetState();
}

class _UserNameWidgetState extends State<UserNameWidget> {
  String _displayName = '';

  @override
  void initState() {
    super.initState();
    _loadDisplayName();
  }

  Future<void> _loadDisplayName() async {
    if (widget.user != null) {
      String userId = widget.user!.uid;
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child('users').child(userId);
      // Use `once()` to get the DatabaseEvent
      DatabaseEvent event = await userRef.once();

      // Extract DataSnapshot from the DatabaseEvent
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic>? userData = snapshot.value as Map?;
        String name = userData?['name'];
        setState(() {
          _displayName = name;
        });
      }
    }
  }

  Future<void> _changeUserName() async {
    String newDisplayName = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Wprowadź swoje imię'),
          content: TextField(
            onChanged: (value) {
              newDisplayName = value;
            },
            decoration: const InputDecoration(hintText: 'Imię'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Anuluj'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newDisplayName.trim().isNotEmpty) {
                  // Perform the name update here.
                  String userId = Auth().currentUser?.uid ?? '';

                  // Create a reference to the user node in the Realtime Database
                  DatabaseReference userRef = FirebaseDatabase.instance
                      .ref()
                      .child('users')
                      .child(userId);

                  // Update the "name" field with the new display name
                  await userRef.update({
                    'name': newDisplayName,
                  });

                  setState(() {
                    _displayName = newDisplayName;
                  });

                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Zapisz'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Witaj, $_displayName!',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          iconSize: 18.0,
          onPressed: _changeUserName,
          icon: const Icon(Icons.edit, color: Colors.white),
        ),
      ],
    );
  }
}
