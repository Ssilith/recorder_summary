import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  // auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  // storage
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // remember current user
  bool _rememberMe = false;

  // current user
  User? _user;

  // user getter
  User? get user => _user;

  // constructor
  AuthProvider() {
    initUser();
  }

  // value notifier
  Future initUser() async {
    _rememberMe = await secureStorage.read(key: 'rememberMe') == 'true';
    _auth.authStateChanges().listen((User? user) {
      if (_rememberMe) {
        _user = user;
        notifyListeners();
      }
    });
  }

  // login with email and password function
  Future signInWithEmailAndPassword(
      String email, String password, bool rememberMe) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _rememberMe = rememberMe;
      _user = userCredential.user;

      // store user credentials
      if (rememberMe) {
        await _storeUserCredentials(email, password);
        await secureStorage.write(key: 'rememberMe', value: 'true');
      } else {
        await secureStorage.delete(key: 'rememberMe');
      }

      notifyListeners();
    } catch (e) {
      _user = null;
    }
  }

  // login with google function
  Future signInWithGoogle(bool rememberMe) async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        _user = null;
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      _rememberMe = rememberMe;
      _user = userCredential.user;

      // store user credentials
      if (rememberMe) {
        await _storeUserCredentials(userCredential.user!.email!, "");
        await secureStorage.write(key: 'rememberMe', value: 'true');
      } else {
        await secureStorage.delete(key: 'rememberMe');
      }

      notifyListeners();
    } catch (e) {
      _user = null;
    }
  }

  // delete account function
  Future deleteUserAccount() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        await currentUser.delete();
        await signOut();
      } catch (e) {
        _user = _auth.currentUser;
        notifyListeners();
      }
    }
  }

  // reset password function
  Future resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // sign up function
  Future signUp(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  // store user credentials
  Future _storeUserCredentials(String email, String password) async {
    await secureStorage.write(key: 'email', value: email);
    await secureStorage.write(key: 'password', value: password);
  }

  // retrieve user credentials
  Future<Map<String, String>> getUserCredentials() async {
    String? email = await secureStorage.read(key: 'email');
    String? password = await secureStorage.read(key: 'password');

    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }

    return {};
  }

  // try logging in with stored credential
  Future autoLogin() async {
    var credentials = await getUserCredentials();
    bool? rememberMe = await secureStorage.read(key: 'rememberMe') == 'true';

    if (credentials.isNotEmpty && rememberMe) {
      String? email = credentials['email'];
      String? password = credentials['password'];

      if (email != null && password != null && password.isNotEmpty) {
        UserCredential userCredential =
            await signInWithEmailAndPassword(email, password, false);
        _user = userCredential.user;
      } else if (email != null) {
        UserCredential userCredential = await signInWithGoogle(false);
        _user = userCredential.user;
      } else {
        _user = null;
      }
      notifyListeners();
    }
  }

  // sign out function
  Future signOut() async {
    await _auth.signOut();
    await googleSignIn.signOut();
    await secureStorage.delete(key: 'email');
    await secureStorage.delete(key: 'password');
    await secureStorage.delete(key: 'rememberMe');

    _user = null;
    _rememberMe = false;
    notifyListeners();
  }
}
