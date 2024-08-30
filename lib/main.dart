import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

import 'login signup/login.dart';

void main() async  {
  //Firebase Initialization Code
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //Run app code
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const  MaterialApp(
      home: LoginScreen(),   //will build this
    );
  }
}

