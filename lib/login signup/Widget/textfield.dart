import 'package:flutter/material.dart';


class TextFieldInput  extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool ispass;
  final String hintText;
  final IconData icon;


  const TextFieldInput ({
    super.key,
    required this.textEditingController,
    this.ispass = false,
    required this.hintText,
    required this.icon,


  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:  20,vertical: 20 ),
      child: TextField(
        obscureText: ispass,
        controller: textEditingController ,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black45,fontSize: 18),
          prefixIcon:   Icon(icon),
          contentPadding:const EdgeInsets.symmetric(vertical: 15, horizontal: 20) ,
          border: InputBorder.none,
          filled: true,
          fillColor: Color(0xFFedf0f8),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder:  OutlineInputBorder(
            borderSide: const  BorderSide(
                width: 2,
                color: Colors.blue
            ),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}