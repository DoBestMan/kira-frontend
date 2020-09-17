import 'package:fluro/fluro.dart' as fluroRouter;
import 'package:flutter/material.dart';
import 'package:kira_auth/screens/account_screen.dart';
import 'package:kira_auth/screens/global_screen.dart';
import 'package:kira_auth/screens/settings_screen.dart';
import 'package:kira_auth/screens/login_screen.dart';
import 'package:kira_auth/screens/login_with_mnemonic_screen.dart';
import 'package:kira_auth/screens/login_with_keyfile_screen.dart';
import 'package:kira_auth/screens/create_new_account_screen.dart';
import 'package:kira_auth/screens/seed_backup_screen.dart';
import 'package:kira_auth/screens/token_balances_screen.dart';
import 'package:kira_auth/screens/withdrawal_screen.dart';

class FluroRouter {
  static fluroRouter.Router router = fluroRouter.Router();

  static fluroRouter.Handler _globalHandler = fluroRouter.Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          GlobalScreen());

  static fluroRouter.Handler _accountHandler = fluroRouter.Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AccountScreen());

  static fluroRouter.Handler _loginHandler = fluroRouter.Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          LoginScreen());

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

  static fluroRouter.Handler _tokenBalancesHandler = fluroRouter.Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          TokenBalanceScreen());

  static fluroRouter.Handler _withdrawalHandler = fluroRouter.Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          WithdrawalScreen());

  static void setupRouter() {
    router.define('/',
        handler: _globalHandler,
        transitionType: fluroRouter.TransitionType.fadeIn);

    router.define('/account',
        handler: _accountHandler,
        transitionType: fluroRouter.TransitionType.fadeIn);

    router.define('/login',
        handler: _loginHandler,
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

    router.define('/settings',
        handler: _settingsHandler,
        transitionType: fluroRouter.TransitionType.fadeIn);

    router.define('/tokens',
        handler: _tokenBalancesHandler,
        transitionType: fluroRouter.TransitionType.fadeIn);

    router.define('/withdrawal',
        handler: _withdrawalHandler,
        transitionType: fluroRouter.TransitionType.fadeIn);
  }
}
