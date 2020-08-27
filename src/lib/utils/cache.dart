import 'package:shared_preferences/shared_preferences.dart';

Future setAccountData(String info) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final cachedData = prefs.getString('accounts');
  String accounts = cachedData == null ? "" : cachedData;
  accounts += "---";
  accounts += info;
  prefs.setString('accounts', accounts);
}

Future removeCachedAccount() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('accounts');
}

Future<bool> setPassword(String password) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('password', password);
  return true;
}

Future<bool> removeCachedPassword() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('password');
  return true;
}
