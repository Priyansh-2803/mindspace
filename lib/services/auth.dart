import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  Future signinAnon() async {
    try{
      UserCredential result = await _auth.signInAnonymously();
      User? user  = result.user;
      return user;
    } catch(e){
      print(e.toString());
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {

        // WEB EXCLUSIVE FLOW (Bypasses token errors)

        GoogleAuthProvider authProvider = GoogleAuthProvider();


        await _auth.signInWithRedirect(authProvider);
        return null;
      } else {

        // ANDROID / IOS EXCLUSIVE FLOW (VERSION 7.0+ SYNTAX)



        final googleSignIn = GoogleSignIn.instance;


        await googleSignIn.initialize(
          serverClientId: '802913604472-sfvfea01gt9i92sjeq3irpb89f4i34to.apps.googleusercontent.com',
        );


        final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();
        if (googleUser == null) return null;


        final googleAuth = await googleUser.authentication;


        final clientAuth = await googleUser.authorizationClient.authorizeScopes(['email', 'profile']);


        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: clientAuth.accessToken,
        );

        UserCredential result = await _auth.signInWithCredential(credential);
        return result.user;
      }
    } catch (e) {
      print("Error signing in with Google: ${e.toString()}");
      return null;
    }
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return {'user': result.user, 'error': null};
    } on FirebaseAuthException catch(e){
      print("FireBase Auth Error: ${e.message}");
      return {'user': null, 'error': e.message ?? 'An error occurred'};
    }
    catch (e) {
      return {'user': null, 'error': e.toString()};
    }
  }

  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return user;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  Future signOut() async{
    try{
      return await _auth.signOut();
    } catch(e){
      print(e.toString());
      return null;
    }
  }
}
