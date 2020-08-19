import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:kira_auth/screens/login_screen.dart';
import 'package:kira_auth/screens/create_new_account_screen.dart';
import 'package:kira_auth/screens/seed_backup_screen.dart';

class FluroRouter {
  static Router router = Router();

  static Handler _globalHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          LoginScreen());

  static Handler _loginHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          LoginScreen());

  static Handler _createNewAccountHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          CreateNewAccountScreen());

  static Handler _seedBackupHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          SeedBackupScreen());

  static void setupRouter() {
    router.define('/',
        handler: _globalHandler, transitionType: TransitionType.fadeIn);
    router.define('/login',
        handler: _loginHandler, transitionType: TransitionType.fadeIn);
    router.define('/create-account',
        handler: _createNewAccountHandler,
        transitionType: TransitionType.fadeIn);
    router.define('/seed-backup',
        handler: _seedBackupHandler, transitionType: TransitionType.fadeIn);
  }
}
