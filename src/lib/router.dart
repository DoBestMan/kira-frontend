import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
// import 'package:kira_auth/screens/main_screen.dart';
import 'package:kira_auth/screens/welcome_screen.dart';
import 'package:kira_auth/screens/login_with_mnemonic_screen.dart';
import 'package:kira_auth/screens/login_with_keyfile_screen.dart';
import 'package:kira_auth/screens/create_new_account_screen.dart';
import 'package:kira_auth/screens/seed_backup_screen.dart';

class FluroRouter {
  static Router router = Router();

  static Handler _globalHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          WelcomeScreen());

  static Handler _loginWithMnemonicsHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          LoginWithMnemonicScreen());

  static Handler _loginWithKeyfileHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          LoginWithKeyfileScreen());

  static Handler _createNewAccountHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          CreateNewAccountScreen());

  static Handler _seedBackupHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          SeedBackupScreen());

  static void setupRouter() {
    router.define('/',
        handler: _globalHandler, transitionType: TransitionType.fadeIn);
    router.define('/login-mnemonic',
        handler: _loginWithMnemonicsHandler,
        transitionType: TransitionType.fadeIn);
    router.define('/login-keyfile',
        handler: _loginWithKeyfileHandler,
        transitionType: TransitionType.fadeIn);
    router.define('/create-account',
        handler: _createNewAccountHandler,
        transitionType: TransitionType.fadeIn);
    router.define('/seed-backup',
        handler: _seedBackupHandler, transitionType: TransitionType.fadeIn);
  }
}
