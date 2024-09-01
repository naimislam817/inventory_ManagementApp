import 'package:authentication_experiement/login%20signup/Widget/button.dart';
import 'package:authentication_experiement/login%20signup/screen/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

import '../Services/authentication.dart';
import '../Widget/snackbar.dart';
import '../Widget/textfield.dart';
import 'home_screen.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading =  false;
  void dispose(){
    super.dispose();
    emailController.dispose();
    passwordController.dispose();

  }
  void loginUsers() async {
    String res = await AuthServices().loginUser(
        email: emailController.text,
        password: passwordController.text,
       );
    if (res == "success") {
      setState(() {
        isLoading = true;
      }); //navigate to the next screen
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen()));
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
                SizedBox(height: height/3 , child: Image.asset("images/login.jpg"),
                ),
                TextFieldInput(
                    textEditingController: emailController,
                    hintText: "Enter Your Email",
                    icon: Icons.email),
                TextFieldInput(
                    textEditingController: passwordController,
                    hintText: "Enter Your password",
                    ispass: true,
                    icon: Icons.lock),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text("Forgot Password?", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.blue),),),
                ),
                MyButton(onTab: loginUsers , text: "Log In"),
                SizedBox(height: height/15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an Account?" , style: TextStyle(fontSize: 16),),
                    SizedBox(width: 10,),
                    GestureDetector(onTap: () {
            
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                      child: Text("Sighn Up", style:  TextStyle(
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
//Login Page Ui