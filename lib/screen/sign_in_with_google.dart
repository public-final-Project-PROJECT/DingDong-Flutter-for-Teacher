import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<UserCredential> signInWithGoogle() async {
  if (kIsWeb) {
    // Web-specific Google Sign-In
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    // Sign in with a popup
    return await FirebaseAuth.instance.signInWithPopup(googleProvider);
  } else {
    // Mobile-specific Google Sign-In
    final GoogleSignInAccount? googleUser = await GoogleSignIn(
      clientId: defaultTargetPlatform == TargetPlatform.iOS
          ? dotenv.env['IOS_CLIENT_ID']
          : dotenv.env['WEB_CLIENT_ID'],
    ).signIn();

    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
