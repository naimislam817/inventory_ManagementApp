import 'package:authentication_experiement/login%20signup/Services/authentication.dart';
import 'package:authentication_experiement/login%20signup/Widget/button.dart';
import 'package:flutter/material.dart';

import 'login.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
    body: Center(
      child:  Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Congratulations \nYou have Succesfully Logged In",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 35,
          ),
          ),
          MyButton(
              onTab: () async {
                await AuthServices().signOut();
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen(),),);
          } ,
              text: "Log Out")
        ],
      ),
    ) ,
    );
  }
}
