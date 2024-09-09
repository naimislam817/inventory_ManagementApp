
import 'package:authentication_experiement/login%20signup/screen/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';


import 'login signup/screen/login.dart';

void main() async  {
  //Firebase Initialization Code
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = const Settings(
   persistenceEnabled: true,
  );
  //Run app code
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return   MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context,snapshot) {
        if(snapshot.hasData){
            return HomePage();
          } else {
            return LoginScreen();
          }
      }
      ),
      //will build this
    );
  }
}

