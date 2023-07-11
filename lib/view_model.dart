import 'package:budget_app/components.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

final viewModel =
    ChangeNotifierProvider.autoDispose<ViewModel>((ref) => ViewModel());

class ViewModel extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  bool isSignedIn = false;
  bool isObscure = true;
  var logger = Logger();

//  check if signed in
  Future<void> isLoggedIn() async {
    await _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        isSignedIn = false;
      } else {
        isSignedIn = true;
      }
    });
    notifyListeners();
  }

  toggleObscure() {
    isObscure = !isObscure;
    notifyListeners();
  }

//  AUTHENTICATION

  Future<void> createUserWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    await _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) => logger.d("Registration success"))
        .onError((error, stackTrace) {
      logger.d("Registration error $error");
      DialogueBox(
          context, error.toString().replaceAll(RegExp('\\[.*?\\]'), ""));
    });
  }

  Future<void> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    await _auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) => logger.d("Login success"))
        .onError((error, stackTrace) {
      logger.d("login error $error");
      DialogueBox(
          context, error.toString().replaceAll(RegExp('\\[.*?\\]'), ""));
    });
  }

  Future<void> signInWithGoogleWeb(BuildContext context) async {
    GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
    await _auth.signInWithPopup(googleAuthProvider).onError(
        (error, stackTrace) =>
            // logger.d("login error $error");
            DialogueBox(
                context, error.toString().replaceAll(RegExp('\\[.*?\\]'), "")));
    logger
        .d("Current user is not empty = ${_auth.currentUser!.uid.isNotEmpty}");
  }

  Future<void> signInWithGoogleMobile(BuildContext context) async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn()
        .signIn()
        .onError((error, stackTrace) => DialogueBox(
            context, error.toString().replaceAll(RegExp('\\[.*?\\]'), "")));
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

    await _auth.signInWithCredential(credential).then((value) {
      logger.d("Google sign in successful");
    }).onError((error, stackTrace) {
      logger.d("Google sign in error $error");
      DialogueBox(
          context, error.toString().replaceAll(RegExp('\\[.*?\\]'), ""));
    });
  }
}
