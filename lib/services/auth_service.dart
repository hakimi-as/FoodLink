import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); 

  Stream<User?> get user => _auth.authStateChanges();

  // --- REGISTER ---
  Future<UserModel?> register({
    required String email,
    required String password,
    required String name,
    required String role,
    required String phone,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        UserModel newUser = UserModel(
          uid: user.uid, 
          email: email, 
          name: name, 
          role: role, 
          phone: phone
        );
        await _db.collection('users').doc(user.uid).set(newUser.toMap());
        return newUser;
      }
    } catch (e) {
      throw e.toString();
    }
    return null;
  }

  // --- LOGIN ---
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      throw e.toString();
    }
  }

  // --- GOOGLE SIGN IN (Stable v6.2.1 Logic) ---
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; 

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, // v6.2.1 supports this safely
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot doc = await _db.collection('users').doc(user.uid).get();

        if (!doc.exists) {
          UserModel newUser = UserModel(
            uid: user.uid,
            email: user.email ?? "",
            name: user.displayName ?? "New User",
            role: 'student', 
            phone: user.phoneNumber ?? "",
            photoUrl: user.photoURL,
          );
          await _db.collection('users').doc(user.uid).set(newUser.toMap());
          return newUser;
        } else {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>, user.uid);
        }
      }
      return null;
    } catch (e) {
      throw e.toString();
    }
  }

  // --- UPDATE USER ---
  Future<void> updateUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).update(user.toMap());
  }

  // --- GET USER DETAILS ---
  Future<UserModel?> getUserDetails(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
      }
    } catch (e) {
      debugPrint("Error getting user: $e");
    }
    return null;
  }

  // --- SIGN OUT ---
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint("Error signing out: $e");
    }
  }
}