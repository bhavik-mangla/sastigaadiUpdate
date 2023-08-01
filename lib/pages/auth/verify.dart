//is email verified page

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/pages/auth/verify.dart';
import '/pages/home_screen.dart';
import '/providers/sign.dart';
import 'package:provider/provider.dart';

class IsEmailVerified extends StatefulWidget {
  const IsEmailVerified({Key? key}) : super(key: key);

  @override
  _IsEmailVerifiedState createState() => _IsEmailVerifiedState();
}

class _IsEmailVerifiedState extends State<IsEmailVerified> {
  final User user = FirebaseAuth.instance.currentUser!;

  bool isEmailVerified = false;

  @override
  void initState() {
    final data = Provider.of<SignInOrRegister>(context, listen: false);

    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    if (!isEmailVerified) {
      Timer.periodic(Duration(seconds: 1), (timer) async {
        await user.reload();
        if (FirebaseAuth.instance.currentUser!.emailVerified) {
          timer.cancel();
          setState(() {
            data.setIsSignIn(true);
            isEmailVerified = true;
          });
        }
      });
      try {
        user.sendEmailVerification();
      } catch (e) {
        print("An error occured while trying to send email verification");
        print(e.toString());
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? HomeScreen()
      : Scaffold(
          appBar: AppBar(
            title: const Text("Email Verification"),
            backgroundColor: Colors.red[900],
            actions: [
              IconButton(
                onPressed: () {
                  //help toast
                  Fluttertoast.showToast(
                      msg: "Contact us to report bugs",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                  Navigator.pushNamed(context, 'dev');
                },
                icon: Icon(Icons.help),
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Please verify your email",
                    style: TextStyle(fontSize: 20)),
                TextButton(
                  onPressed: () async {
                    await user.reload();
                    if (user.emailVerified) {
                      setState(() {
                        isEmailVerified = true;
                      });
                    } else {
                      Fluttertoast.showToast(
                          msg: "Email not verified",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                  },
                  child: const Text("Continue"),
                ),
                TextButton(
                  onPressed: () async {
                    await user.sendEmailVerification();
                    Fluttertoast.showToast(
                        msg: "Verification email sent",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  },
                  child: const Text("Resend Email"),
                ),
              ],
            ),
          ),
        );
}
