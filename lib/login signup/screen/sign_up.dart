import 'package:authentication_experiement/login%20signup/Services/authentication.dart';
import 'package:authentication_experiement/login%20signup/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:authentication_experiement/login signup/Widget/snackbar.dart';

import 'package:flutter/cupertino.dart';

import '../Widget/button.dart';
import '../Widget/textfield.dart';
import 'login.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool isLoading = false;
  @override
  void dispose(){
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
  }
 void signUpUser() async {
  String res = await AuthServices().signUpUser(
  email: emailController.text,
  password: passwordController.text,
  name: nameController.text);
  if (res == "success") {
  setState(() {
  isLoading = true;
  }); //navigate to the next screen
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
  } else {
   setState(() {
   isLoading = false;
   });
   ShowSnackBar(context, res);
  }

 }
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(

      backgroundColor: Colors.white ,
      body: SafeArea(
        child: SizedBox(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: height/3 , child: Image.asset("images/signup.jpg"),
                ),
                TextFieldInput(
                    textEditingController: nameController,
                    hintText: "Enter Your Name",
                    icon: Icons.person),
                TextFieldInput(
                    textEditingController: emailController,
                    hintText: "Enter Your Email",
                    icon: Icons.email),
                TextFieldInput(
                    textEditingController: passwordController,
                    hintText: "Enter Your password",
                    ispass: true,
                    icon: Icons.lock
                ),

                MyButton(onTab: signUpUser , text: "Sign Up"),
                SizedBox(height: height/15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already Have An Account?" , style: TextStyle(fontSize: 16),),
                    SizedBox(width: 10,),
                    GestureDetector(onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),),);
                    },
                      child: Text("LogIn", style:  TextStyle(
                          fontWeight: FontWeight.bold , fontSize: 16
                      ),
                      ) ,
                    ),
                  ],
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}
