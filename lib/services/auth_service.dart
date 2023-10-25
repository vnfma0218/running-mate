import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Google Sign in
  signInWithGoogle() async {
    // begin interactive sign in process

    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    // obtain auth details from request
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    // create a new credential for user
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    //finally, lets sign in

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  getUserInfo(String uid) {
    final userDetail = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        "email": data['email'],
        "name": data['name'],
        "imageUrl": data['imageUrl']
      };
    });

    return userDetail;
  }
}
