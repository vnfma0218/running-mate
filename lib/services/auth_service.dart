import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:running_mate/models/user.dart';

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

  getUserInfo(String? userId) async {
    final user = FirebaseAuth.instance.currentUser;
    final userDetail = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId ?? user!.uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          "id": userId ?? user!.uid,
          "email": data['email'],
          "name": data['name'],
          "imageUrl": data['imageUrl']
        };
      } else {
        return null;
      }
    });

    return userDetail;
  }

  Future<List<JoinUserModel>> fetchUserList(List<String> userIds) async {
    List<JoinUserModel> users = [];
    userIds.forEach((id) async {
      final user =
          await FirebaseFirestore.instance.collection('users').doc(id).get();
      var joinUser = user.data();
      joinUser!['id'] = id;
      users.add(JoinUserModel.fromJson(joinUser));
    });
    print('users: $users');
    return users;
  }

  isLoggedIn() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return true;
    } else {
      return false;
    }
  }
}
