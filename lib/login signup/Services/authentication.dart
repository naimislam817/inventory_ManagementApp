import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  // for storing data in cloud firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
 // for authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

//for signUp
  Future<String> signUpUser(
{
  required String email,
required String password,
required String name}) async {
  String res = "Some error Occured";
  try {
  //for register user in firebase  auth with email and password
  UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password) ;
  //for adding user to our cloud firestore
    await _firestore.collection("users").doc(credential.user!.uid).set({
    'name' : name,
    'email' : email,
    'uid' : credential.user!.uid,
    //
    });
    res = "success";
  } catch (e) {
    print(e.toString());
  }
  return res ;



  }
  }