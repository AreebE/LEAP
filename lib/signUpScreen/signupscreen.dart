import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold (
        body: MyCustomForm(),
      )
    );
  }
}

class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  State<MyCustomForm> createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<MyCustomForm>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
    body: Stack (
      children: <Widget>[
          Container (
            height: MediaQuery. of(context). size.height,
            child: Image.asset("assets/images/purple2.jpeg", fit: BoxFit.fill),
          ),
          Align (
            alignment: Alignment.center,
            child: Container(
              width: MediaQuery. of(context). size.width * 0.78,
              height:  MediaQuery. of(context). size.height * 0.45,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column (
                children: <Widget> [
                  SizedBox(height:  MediaQuery. of(context). size.height * 0.03),
                  Text('Welcome to Leap!', style: TextStyle(fontSize : 30, fontFamily: 'Josefin Sans', fontWeight: FontWeight.w600)),
                  Divider(color: Colors.black),
                  SizedBox(height:  MediaQuery. of(context). size.height * 0.03),
                  Container(
                    width: MediaQuery. of(context). size. width *.7,
                    child: Text('New user?', style: TextStyle(fontSize : 15, fontFamily: 'Lato', fontWeight: FontWeight.w600), textAlign: TextAlign.left)
                  ),
                  SizedBox(height:  MediaQuery. of(context). size.height * 0.01),
                  AlternateButtons('Sign up with Google'),
                  SizedBox(height:  MediaQuery. of(context). size.height * 0.06),
                  SizedBox(
                    width: MediaQuery. of(context). size. width *.7,
                    child: Text('Already have an account?', style: TextStyle(fontSize : 15, fontFamily: 'Lato', fontWeight: FontWeight.w600), textAlign: TextAlign.left)
                  ),
                  SizedBox(height:  MediaQuery. of(context). size.height * 0.01),
                  AlternateButtons('Log in with Google')
                ]
              )
            )
          )
        ]
      )
    );
  }
}

class AlternateButtons extends StatelessWidget {
  AlternateButtons(this.buttonText);
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Column (
        children: <Widget> [
          SizedBox(
            height: MediaQuery. of(context). size. height *.06,
            width: MediaQuery. of(context). size. width *.7,
            child: ElevatedButton (
              onPressed: () {
                signInWithGoogle();  
              },
              style: ElevatedButton.styleFrom(primary: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)), side: BorderSide(color: Colors.grey)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 20.0,
                    width: 20.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image:
                              AssetImage('assets/images/google_logo.png'),
                          fit: BoxFit.cover),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(buttonText, style: TextStyle(fontSize : 16, fontFamily: 'Lato', fontWeight: FontWeight.w300, color: Colors.black))
                ],
              ),
            ),
          ),
        ],
      );
  }
}

Future<UserCredential> signInWithGoogle() async {
  String accountType = "";
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );


  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}













