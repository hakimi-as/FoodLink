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
            phone: phone);
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

  // --- 1. MODIFIED GOOGLE SIGN IN ---
  // Returns Firebase User (Authentication only), NOT UserModel (Database)
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      throw e.toString();
    }
  }

  // --- 2. NEW: CHECK IF USER EXISTS IN DB ---
  Future<UserModel?> checkUserInFirestore(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
    }
    return null; // User is authenticated but has no profile (New User)
  }

  // --- 3. NEW: FINALIZE REGISTRATION (Save with selected Role) ---
  Future<UserModel> finalizeGoogleRegistration(
      User firebaseUser, String role) async {
    UserModel newUser = UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? "",
      name: firebaseUser.displayName ?? "New User",
      role: role, // <--- Role is now passed dynamically
      phone: firebaseUser.phoneNumber ?? "",
      photoUrl: firebaseUser.photoURL,
    );

    await _db.collection('users').doc(firebaseUser.uid).set(newUser.toMap());
    return newUser;
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