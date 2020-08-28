import 'package:fluro/fluro.dart' as fluroRouter;
import 'package:flutter/material.dart';
import 'package:kira_auth/screens/main_screen.dart';
import 'package:kira_auth/screens/welcome_screen.dart';
import 'package:kira_auth/screens/settings_screen.dart';
import 'package:kira_auth/screens/login_with_mnemonic_screen.dart';
import 'package:kira_auth/screens/login_with_keyfile_screen.dart';
import 'package:kira_auth/screens/create_new_account_screen.dart';
import 'package:kira_auth/screens/seed_backup_screen.dart';

class FluroRouter {
  static fluroRouter.Router router = fluroRouter.Router();

  static fluroRouter.Handler _globalHandler = fluroRouter.Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          WelcomeScreen());

  static fluroRouter.Handler _mainHandler = fluroRouter.Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          MainScreen());

  static fluroRouter.Handler _loginWithMnemonicsHandler = fluroRouter.Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          LoginWithMnemonicScreen());

  static fluroRouter.Handler _loginWithKeyfileHandler = fluroRouter.Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          LoginWithKeyfileScreen());

  static fluroRouter.Handler _createNewAccountHandler = fluroRouter.Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          CreateNewAccountScreen());

  static fluroRouter.Handler _seedBackupHandler = fluroRouter.Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          SeedBackupScreen());

  static fluroRouter.Handler _settingsHandler = fluroRouter.Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          SettingsScreen());

  static void setupRouter() {
    router.define('/',
        handler: _globalHandler,
        transitionType: fluroRouter.TransitionType.fadeIn);
    router.define('/login-mnemonic',
        handler: _loginWithMnemonicsHandler,
        transitionType: fluroRouter.TransitionType.fadeIn);
    router.define('/login-keyfile',
        handler: _loginWithKeyfileHandler,
        transitionType: fluroRouter.TransitionType.fadeIn);
    router.define('/create-account',
        handler: _createNewAccountHandler,
        transitionType: fluroRouter.TransitionType.fadeIn);
    router.define('/seed-backup',
        handler: _seedBackupHandler,
        transitionType: fluroRouter.TransitionType.fadeIn);
    router.define('/main',
        handler: _mainHandler,
        transitionType: fluroRouter.TransitionType.fadeIn);
    router.define('/settings',
        handler: _settingsHandler,
        transitionType: fluroRouter.TransitionType.fadeIn);
  }
}
