/*
 * @Author: duncy
 * @Date: 2025-09-19 09:56:16
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-11-11 10:34:53
 * @FilePath: /novel_oversea/lib/global/login/controller/firebase_auth.dart
 * @Description: 
 */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:novel_oversea/core/ui/dialog/loading_dialog.dart';
import 'package:novel_oversea/core/ui/dialog/toast.dart';
import 'package:novel_oversea/global/const/consts.dart';
import 'package:novel_oversea/global/login/controller/login_controller.dart';
import 'package:novel_oversea/global/login/controller/login_manager.dart';

import '../../../core/cache/byhy_aes_storage_utils.dart';
import '../../const/const_string.dart';

class FirebaseUser {
  String? uid;
  String? displayName;
  String? email;
  String? photoURL;
  String? phoneNumber;
  bool? emailVerified;
  String? token;

  FirebaseUser({
    this.uid,
    this.displayName,
    this.email,
    this.photoURL,
    this.phoneNumber,
    this.emailVerified,
    this.token,
  });

  factory FirebaseUser.fromFirebaseUser(User user) {
    return FirebaseUser(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      photoURL: user.photoURL,
      phoneNumber: user.phoneNumber,
      emailVerified: user.emailVerified,
    );
  }
}

class LoginUtil {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const List<String> scopes = <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ];

  /// google登录
  static Future<FirebaseUser?> signInWithGoogle() async {
    if (GoogleSignIn.instance.supportsAuthenticate()) {
      // Trigger the authentication flow
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      googleSignIn.initialize(
        serverClientId: '883280627227-udm0gelvgstvfc20oe3pudpaovo23u35.apps.googleusercontent.com'
      );
      try {
        final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();
        if (googleUser != null) {
          // Obtain the auth details from the request
          final GoogleSignInAuthentication googleAuth =
              googleUser.authentication;
          // Create a new credential
          final GoogleSignInClientAuthorization? authorization = await googleUser.authorizationClient.authorizationForScopes(
            scopes,
          );
          final credential = GoogleAuthProvider.credential(
            idToken: googleAuth.idToken,
            accessToken: authorization?.accessToken,
          );
          // Once signed in, return the UserCredential
          UserCredential userCredential = await _auth.signInWithCredential(
            credential,
          );
          return getAuthToken(userCredential);
        }
      } catch (e) {
        print('_____ERROR:${e.toString()}');
        return null;
      }
    }
    return null;
  }

  ///Apple登录
  static Future<FirebaseUser?> signInWithApple() async {
    final appleProvider = AppleAuthProvider();
    try {
      UserCredential userCredential;
      if(kIsWeb) {
        userCredential = await _auth.signInWithPopup(appleProvider);
      }
      else {
        userCredential = await _auth.signInWithProvider(appleProvider,);
      }
      return getAuthToken(userCredential);
    } catch (e) {
      //do nothing
    }
    return null;
  }

  ///邮箱登录
  static Future<FirebaseUser?> signInWithEmail(String sendEmail, {Function? onSuccess}) async {
    if(sendEmail.isEmpty) {
      return null;
    }
    var acs = ActionCodeSettings(
      // URL you want to redirect back to. The domain (www.example.com) for this
      // URL must be whitelisted in the Firebase Console.
      url: Consts.firebaseSignin,
      // This must be true
      handleCodeInApp: true,
      iOSBundleId: 'com.AI.novel.story.book.generator',
      androidPackageName: 'com.AI.novel.story.book.generatorPro',
      androidInstallApp: false, 
    );
    ///存储当前输入邮箱
    ByStorageUtils.saveString(ConstString.kLoginEmailVerification, sendEmail);
    FirebaseAuth.instance
        .sendSignInLinkToEmail(email: sendEmail, actionCodeSettings: acs)
        .catchError(
          (onError) => print('Error sending email verification $onError'),
        )
        .then((value) {
          onSuccess?.call();
          LoadingDialog().dismiss();
          Toast.showText(text: 'Successfully sent email verification.');
          print('Successfully sent email verification.');
        });
    
    return null;

  }

  static void verifyEmail(String emailLink) async {
    // Confirm the link is a sign-in with email link.
    final String email = ByStorageUtils.getString(ConstString.kLoginEmailVerification) ?? '';
    if(email.isEmpty) {
      return;
    }
    LoadingDialog().show(message: 'login...');
    if (FirebaseAuth.instance.isSignInWithEmailLink(emailLink)) {
      try {
        // The client SDK will parse the code from the link for you.
        final userCredential = await FirebaseAuth.instance.signInWithEmailLink(
          email: email,
          emailLink: emailLink,
        );
        
        FirebaseUser? user = await getAuthToken(userCredential);
        if(user != null) {
          LoginManager.createLogin(
            user, 
            LoginType.email,
            onSuccess: (data, type) {
              ///用户登录成功
              if(type == 1) {
                ByStorageUtils.remove(ConstString.kLoginEmailVerification);
              }
            },);
        }
        print('_______user----yonghu : ${user?.token}');
        // return getAuthToken(userCredential);
      } on FirebaseAuthException catch (e) {
        LoadingDialog().dismiss();
        print('_____Error signing in with email link. ${e.code}___${e.message}__${e.phoneNumber}__${e.email}');
        // 判断错误类型
        if (e.code == 'expired-action-code') {
          // 链接已过期
          Toast.showText(text: 'The email verification is expired.');
          print('____链接已过期');
          // 可在此处触发重新发送验证链接的逻辑
        } else if (e.code == 'invalid-action-code') {
          // 链接无效（非过期原因，如被篡改、已使用等）
          Toast.showText(text: 'The email verification is invalid.');
          print('____无效的验证链接');
        } else {
          // 其他错误（如邮箱不匹配、网络问题等）
          Toast.showText(text: 'Email error');
          print('____登录失败：${e.message}');
        }
      } catch (error) {
        LoadingDialog().dismiss();
        // return null;
      }
    }
  }

  ///获取授权token
  static Future<FirebaseUser?> getAuthToken(UserCredential userCredential) async {
    User? user = userCredential.user;
    if (user != null) {
      print('_______======>>>>>>auth user = ${user.displayName}, ${user.email}, ${user.photoURL}, ${user.uid}, ${user.phoneNumber}, ${user.emailVerified}');
      IdTokenResult idTokenResult = await user.getIdTokenResult(true);
      FirebaseUser firebaseUser = FirebaseUser.fromFirebaseUser(user);
      firebaseUser.token = idTokenResult.token;
      return firebaseUser;
    }
    return null;
  }


  ///获取当前用户
  static User? currentUser() {
    return _auth.currentUser;
  }

  /// sign out.
  static Future<void> signOut() async {
    await _auth.signOut();
    // await _googleSignIn.signOut();
  }
}