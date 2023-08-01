import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  User? getFirebaseUser() {
    return auth.currentUser;
  }

  Stream<User?> get userChanges {
    debugPrint("Auth state changed");
    return auth.authStateChanges();
  }

  Future<Map<String, dynamic>> signOut() async {
    try {
      await auth.signOut();
      return {
        "error": null,
      };
    } on FirebaseAuthException catch (e) {
      return {
        "error": e.code,
      };
    } catch (e) {
      return {
        "error": "Unknown Error",
      };
    }
  }

  Future<Map<String, dynamic>> signUp(String email, String password) async {
    try {
      UserCredential credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = credential.user!;
      return {"user": user, "error": null};
    } on FirebaseAuthException catch (e) {
      return {"user": null, "error": e.code};
    } catch (e) {
      return {"user": null, "error": "Unknown Error"};
    }
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      UserCredential credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = credential.user!;
      return {"user": user, "error": null};
    } on FirebaseAuthException catch (e) {
      return {"user": null, "error": e.code};
    } catch (e) {
      return {"user": null, "error": "Unknown Error"};
    }
  }

  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return {"error": null};
    } on FirebaseAuthException catch (e) {
      return {"error": e.code};
    } catch (e) {
      return {"error": "Unknown Error"};
    }
  }

  Future<Map<String, dynamic>> changePassword(String password) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await user!.updatePassword(password);
      return {"error": null};
    } on FirebaseAuthException catch (e) {
      return {"error": e.code};
    } catch (e) {
      return {"error": "Unknown Error"};
    }
  }

  Future<Map<String, dynamic>> changeEmail(String email) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await user!.updateEmail(email);
      return {"error": null};
    } on FirebaseAuthException catch (e) {
      return {"error": e.code};
    } catch (e) {
      return {"error": "Unknown Error"};
    }
  }

  Future<Map<String, dynamic>> deleteUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await user!.delete();
      return {"error": null};
    } on FirebaseAuthException catch (e) {
      return {"error": e.code};
    } catch (e) {
      return {"error": "Unknown Error"};
    }
  }

  Future<Map<String, dynamic>> reauthenticate(String password) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      UserCredential credential = await user!.reauthenticateWithCredential(
        EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        ),
      );
      return {"user": credential.user, "error": null};
    } on FirebaseAuthException catch (e) {
      return {"user": null, "error": e.code};
    } catch (e) {
      return {"user": null, "error": "Unknown Error"};
    }
  }

  Future<Map<String, dynamic>> reload() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await user!.reload();
      return {"error": null};
    } on FirebaseAuthException catch (e) {
      return {"error": e.code};
    } catch (e) {
      return {"error": "Unknown Error"};
    }
  }

  var acs = ActionCodeSettings(
      // URL you want to redirect back to. The domain (www.example.com) for this
      // URL must be whitelisted in the Firebase Console.
      url: 'https://www.instagram.com/sastigaadi_/',
      // This must be true
      handleCodeInApp: true,
      iOSBundleId: 'com.mavikdev.sastigaadi',
      // installIfNotAvailable
      androidInstallApp: true,
      // minimumVersion
      androidMinimumVersion: '12');

  //send verifying email link
  Future<void> sendEmailVerificationLink(var emailAuth) async {
    await FirebaseAuth.instance.currentUser
        ?.sendEmailVerification(acs)
        .then((value) =>
            Fluttertoast.showToast(msg: 'Successfully sent email verification'))
        .catchError((onError) =>
            print("Error sending email verification link: $onError"));
  }

  //get user from uid
}
