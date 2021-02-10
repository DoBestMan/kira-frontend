import 'package:shared_preferences/shared_preferences.dart';

abstract class ValidatorRepository {
  Future<List<String>> getFavoriteValidatorsFromCache(userAddress);
  Future<void> toggleFavoriteValidator(address, userAddress);
}

class IValidatorRepository implements ValidatorRepository {
  @override
  Future<List<String>> getFavoriteValidatorsFromCache(userAddress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String favoriteValidatorsString = prefs.getString('favoriteValidators-$userAddress') ?? "";
    return favoriteValidatorsString.split(",");
  }

  @override
  Future<void> toggleFavoriteValidator(address, userAddress) async {
    var favoriteValidators = await getFavoriteValidatorsFromCache(userAddress);
    if (favoriteValidators.contains(address))
      favoriteValidators.remove(address);
    else
      favoriteValidators.add(address);
    var favoriteValidatorsString = favoriteValidators.join(",");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('favoriteValidators-$userAddress', favoriteValidatorsString);
  }
}
