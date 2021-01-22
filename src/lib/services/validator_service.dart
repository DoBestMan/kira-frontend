import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kira_auth/models/validator.dart';
import 'package:kira_auth/config.dart';

class ValidatorService {
  List<Validator> validators = [];

  Future<void> getValidators() async {
    List<Validator> validatorList = [];

    var config = await loadConfig();
    String apiUrl = json.decode(config)['api_url'];
    var data = await http.get(apiUrl + "/valopers");

    var bodyData = json.decode(data.body);
    var validators = bodyData['validators'];

    for (int i = 0; i < validators.length; i++) {
      Validator validator = Validator(
        address: validators[i]['address'],
        valkey: validators[i]['valkey'],
        pubkey: validators[i]['pubkey'],
        moniker: validators[i]['moniker'],
        website: validators[i]['website'] ?? "",
        social: validators[i]['social'] ?? "",
        identity: validators[i]['identity'] ?? "",
        commission: double.parse(validators[i]['commission'] ?? "0"),
        status: validators[i]['status'],
        rank: validators[i]['rank'] ?? 0,
        streak: validators[i]['streak'] ?? 0,
        mischance: validators[i]['mischance'] ?? 0,
      );
      validatorList.add(validator);
    }

    validatorList.sort((a, b) => a.rank.compareTo(b.rank));
    this.validators = validatorList;
  }

  Future<void> likeValidator(String address) async {}
}
