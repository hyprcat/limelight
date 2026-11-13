import 'package:lime_time_app/logics/engines/media_urls.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lime_time_app/logics/engines/user_engine.dart';
import 'package:lime_time_app/main.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';

class AuthRepository {
  final _firebaseAuth = FirebaseAuth.instance;
  UserProfile? loggedInUser;

  Future<void> signUp({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided for that user.');
      }
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<AuthorizationCredentialAppleID> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          // TODO: Set the `clientId` and `redirectUri` arguments to the values you entered in the Apple Developer portal during the setup
          clientId: 'gg.hazel.limelight',
          redirectUri: Uri.parse(
            appleCallbackUrl,
          ),
        ),
      );
      return credential;
    } catch (E) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception(e);
    }
  }

  User? getUser() {
    return _firebaseAuth.currentUser;
  }

  Future<String> handleLimeSignIn() async {
    User? user = _firebaseAuth.currentUser;
    String? token = await user!.getIdToken(true);
    return await UserEngine().handleGoogleSignIn(token);
  }

  Future<void> loadCachedUser() async {
    loggedInUser = await UserEngine().getCachedUserInfo();
    if (loggedInUser != null && loggedInUser!.userId != null) {
      analytics!.setUserId(id: loggedInUser!.userId!.toString());
    }
  }

  Future<UserProfile?> refreshUser() async {
    UserProfile? temp = await UserEngine().getUserInfo(loggedInUser!.userId!);
    if (temp != null) {
      loggedInUser = temp;
      UserEngine().cacheUserInfo(temp);
    }
    return temp;
  }
}
