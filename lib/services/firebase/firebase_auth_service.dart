import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'model/fuser_with_access_token.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();

  FirebaseAuthService._internal();

  factory FirebaseAuthService() {
    return _instance;
  }

  static FirebaseAuthService get instance => _instance;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        'googleusercontent.com_id',
    scopes: [
      'email',
      // 'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  User? get currentUser => _firebaseAuth.currentUser;

  /// Once server send OTP successfully then we have to verify mobile number and
  /// this function will return us different callbacks.
  Future<FUserWithAccessToken?> verifyMobileNumber(String mobile,
      {

      /// Auto detect SMS callback
      required Function(FUserWithAccessToken) autoDetectSMSCallback,

      /// Code sent successfully
      required PhoneCodeSent otpSentSuccessfullyCallback,

      /// Something wrong in auth
      required Function(FirebaseAuthException) authException,

      /// Timeout
      required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,

      /// Default resend seconds
      required int resendSeconds,
      int? forceResendingToken}) async {
    try {
      _firebaseAuth.verifyPhoneNumber(
        phoneNumber: mobile,
        timeout: Duration(seconds: resendSeconds),

        // Automatic handling of the SMS code on Android devices.
        forceResendingToken: forceResendingToken,
        verificationCompleted: (phoneAuthCredentials) async {
          final UserCredential userCredentials =
              await _firebaseAuth.signInWithCredential(
            phoneAuthCredentials,
          );

          String accessToken = await userCredentials.user!.getIdToken();

          autoDetectSMSCallback.call(
            FUserWithAccessToken(
              userCredentials.user!,
              accessToken,
              refreshToken: userCredentials.user!.refreshToken!,
            ),
          );
        },

        // Handle failure events such as invalid phone numbers or whether the SMS quota has been exceeded.
        verificationFailed: authException,

        // Handle when a code has been sent to the device from Firebase, used to prompt users to enter the code.
        // codeSent: otpSentSuccessfullyCallback,
        codeSent: (
          String verificationId,
          int? forceResendingToken,
        ) {
          otpSentSuccessfullyCallback.call(verificationId, forceResendingToken);
        },

        // Handle a timeout of when automatic SMS code handling fails.
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<FUserWithAccessToken> verifyOTP(
      String smsCode, String verificationId) async {
    // Update the UI - wait for the user to enter the SMS code
    // String smsCode = 'xxxx';

    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);

    // Sign the user in (or link) with the credential
    final UserCredential userCredentials =
        await _firebaseAuth.signInWithCredential(credential);
    String token = await userCredentials.user!.getIdToken();

    return FUserWithAccessToken(userCredentials.user!, token,
        refreshToken: userCredentials.user!.refreshToken);
  }

  /// Once PhoneCodeSent callback called (Means OTP sent successfully )
  Future<UserCredential?> signInWithAuthCredentials(
      AuthCredential credential) async {
    try {
      _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// This method is useful well we aren't using any firebase sign-in methods
  /// but server will generate a credentials for us to verify a user.
  Future<UserCredential> signInWithCustomToken(String token) async {
    try {
      return _firebaseAuth.signInWithCustomToken(token);
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<FUserWithAccessToken> signInWithGoogle() async {
    try {
      var googleSignIn = await _googleSignIn.signIn();
      if (googleSignIn != null) {
        ///
        final GoogleSignInAuthentication googleAuthCredential =
            await googleSignIn.authentication;

        ///
        final UserCredential userCredentials =
            await _firebaseAuth.signInWithCredential(
          GoogleAuthProvider.credential(
            idToken: googleAuthCredential.idToken,
            // Note: Access token is null when running on web, so we don't check for it above
            accessToken: googleAuthCredential.accessToken,
          ),
        );

        ///
        return FUserWithAccessToken(
          userCredentials.user!,
          googleAuthCredential.accessToken!,
        );
      } else {
        throw GoogleAuthNullException('Google user is null');
      }
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      return _firebaseAuth.signOut();
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}

class GoogleAuthNullException implements Exception {
  final String message;

  GoogleAuthNullException(this.message);
}
