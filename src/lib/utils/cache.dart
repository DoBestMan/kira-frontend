import 'package:shared_preferences/shared_preferences.dart';

const String TS_PREFIX = 'spc_ts_';

Future setAccountData(String info) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final cachedData = prefs.getString('accounts');

  String accounts = cachedData == null ? "---" : cachedData;
  accounts += info;
  accounts += "---";
  prefs.setString('accounts', accounts);

  checkPasswordExpired();
}

Future removeCachedAccount() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('accounts');
}

Future<bool> setPassword(String password) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await setLastFetchedTime('password');

  bool isExpiredTimeExists = await checkExpireTime();
  if (isExpiredTimeExists == false) {
    setExpireTime(Duration(hours: 1));
  }

  prefs.setString('password', password);
  return true;
}

Future<bool> removeCachedPassword() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('password');
  return true;
}

Future<bool> checkPasswordExists() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.containsKey('password');
}

Future setExpireTime(Duration maxAge) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('expireTime', maxAge.inMilliseconds);
}

Future<bool> removeExpireTime() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('expireTime');
  return true;
}

Future<bool> checkExpireTime() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.containsKey('expireTime');
}

Future setLastFetchedTime(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int ts = DateTime.now().millisecondsSinceEpoch;
  prefs.setInt(getTimestampKey(key), ts);
}

String getTimestampKey(String forKey) {
  return TS_PREFIX + forKey;
}

Future<bool> checkPasswordExpired() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  int ts = prefs.getInt(getTimestampKey('password')); // Get last fetched Time
  if (ts == null) return true;

  int expireTime = prefs.getInt('expireTime');
  int diff = DateTime.now().millisecondsSinceEpoch - ts;

  if (ts == null || diff > expireTime) {
    removeCachedPassword();
    return true;
  }

  return false;
}
