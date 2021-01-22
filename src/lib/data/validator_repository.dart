import 'package:shared_preferences/shared_preferences.dart';

class ValidatorRepository {
  final String KEY = 'favoriteValidators';

  Future<List<String>> getFavoriteValidatorsFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String favoriteValidatorsString = prefs.getString(KEY) ?? "";
    return favoriteValidatorsString.split(",");
  }

  Future<void> toggleFavoriteValidator(String address) async {
    var favoriteValidators = await getFavoriteValidatorsFromCache();
    if (favoriteValidators.contains(address))
      favoriteValidators.remove(address);
    else
      favoriteValidators.add(address);
    var favoriteValidatorsString = favoriteValidators.join(",");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(KEY, favoriteValidatorsString);
  }
}
