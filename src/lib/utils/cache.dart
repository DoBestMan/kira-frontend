import 'package:shared_preferences/shared_preferences.dart';

Future<bool> saveAccountData(String info) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String accounts = prefs.getString('accounts');
  accounts += info;
  prefs.setString('accounts', accounts);
  return true;
}

Future<String> getAccountData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String accounts = prefs.getString('accounts');
  return accounts;
}

Future<bool> savePassword(String password) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('password', password);
  return true;
}

Future<String> getPassword() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('password');
}

Future<bool> removePassword() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('password');
  return true;
}
