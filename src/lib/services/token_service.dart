import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kira_auth/models/token.dart';
import 'package:kira_auth/utils/token_icons.dart';
import 'package:kira_auth/config.dart';

class TokenService {
  List<Token> tokens = [];
  List<String> faucetTokens = [];

  Future<void> getTokens(String address) async {
    List<Token> tokenList = [];

    String apiUrl = await loadInterxURL();
    var tokenAliases = await http.get(apiUrl + "/kira/tokens/aliases");
    var tokenAliasesData = json.decode(tokenAliases.body);
    tokenAliasesData = tokenAliasesData['data'];

    var balance = await http.get(apiUrl + "/cosmos/bank/balances/$address");
    var balanceData = json.decode(balance.body);
    var coins = balanceData['balances'];

    Pagination pagination = Pagination.fromJson(balanceData['pagination']);

    if (tokenAliasesData != null) {
      for (int i = 0; i < tokenAliasesData.length; i++) {
        Token token = Token(
            graphicalSymbol: TokenIcons.getTokenIconBySymbol(tokenAliasesData[i]['name'].toString()),
            assetName: tokenAliasesData[i]['name'].toString(),
            ticker: tokenAliasesData[i]['symbol'],
            balance: 0,
            denomination: tokenAliasesData[i]['denoms'][0].toString(),
            decimals: tokenAliasesData[i]['decimals'],
            pagination: pagination);

        if (coins != null) {
          for (int j = 0; j < coins.length; j++) {
            if (tokenAliasesData[i]['denoms'].contains(coins[j]['denom']) == true) {
              token.balance = double.tryParse(coins[j]['amount']);
              token.denomination = coins[j]['denom'].toString();
            }
          }
        }

        tokenList.add(token);
      }
    }

    // if (coins != null) {
    //   for (int i = 0; i < coins.length; i++) {
    //     Token token = Token(
    //         graphicalSymbol: TokenIcons.atom,
    //         assetName: coins[i]['denom'].toString(),
    //         ticker: coins[i]['denom'].toString(),
    //         balance: double.tryParse(coins[i]['amount']),
    //         denomination: coins[i]['denom'].toString(),
    //         decimals: 6,
    //         pagination: pagination);
    //     tokenList.add(token);
    //   }
    // }

    tokens = tokenList;
  }

  Future<String> faucet(String address, String token) async {
    String apiUrl = await loadInterxURL();

    String url = apiUrl + "/faucet?claim=$address&token=$token";
    String response = "Success!";

    var data = await http.get(url);
    var bodyData = json.decode(data.body);
    // var header = data.headers;
    // print(header['interx_signature']);

    if (bodyData['hash'] != null) {
      response = "Success!";
    }

    switch (bodyData['code']) {
      case 0:
        response = "Internal Server Error";
        break;
      case 1:
        response = "Failed to send tokens";
        break;
      case 100:
        response = "Invalid address";
        break;
      case 101:
        response = "Claim time left";
        break;
      case 102:
        response = "Invalid token";
        break;
      case 103:
        response = "No need to send tokens";
        break;
      case 104:
        response = "Can't send tokens, less than minimum amount";
        break;
      case 105:
        response = "Not enough tokens in faucet server";
        break;
    }
    return response;
  }

  Future<void> getAvailableFaucetTokens() async {
    List<String> tokenList = [];
    String apiUrl = await loadInterxURL();

    var response = await http.get(apiUrl + "/faucet");
    var body = json.decode(response.body);
    var coins = body['balances'];

    if (coins != null) {
      for (int i = 0; i < coins.length; i++) {
        tokenList.add(coins[i]['denom']);
      }
    }

    faucetTokens = tokenList;
  }

  void getDummyTokens() {
    var tokenData = [
      {
        "graphical_symbol": TokenIcons.kex,
        "asset_name": 'Kira',
        "ticker": 'KEX',
        "balance": 1000,
        "denomination": 'ukex',
        "decimals": 6,
        "pagination": {"nextKey": "0", "total": "0"}
      },
      {
        "graphical_symbol": TokenIcons.btc,
        "asset_name": 'Bitcoin',
        "ticker": 'BTC',
        "balance": 532,
        "denomination": 'ubtc',
        "decimals": 6,
        "pagination": {"nextKey": "0", "total": "0"}
      },
      {
        "graphical_symbol": TokenIcons.atom,
        "asset_name": 'Cosmos',
        "ticker": 'ATOM',
        "balance": 236,
        "denomination": 'uatom',
        "decimals": 6,
        "pagination": {"nextKey": "0", "total": "0"}
      },
      {
        "graphical_symbol": TokenIcons.sent,
        "asset_name": 'Sentinel',
        "ticker": 'SENT',
        "balance": 64,
        "denomination": 'usent',
        "decimals": 6,
        "pagination": {"nextKey": "0", "total": "0"}
      },
      {
        "graphical_symbol": TokenIcons.eth,
        "asset_name": 'Ethereum',
        "ticker": 'ETH',
        "balance": 747,
        "denomination": 'ueth',
        "decimals": 6,
        "pagination": {"nextKey": "0", "total": "0"}
      },
      {
        "graphical_symbol": TokenIcons.eusd,
        "asset_name": 'e-money USD',
        "ticker": 'eUSD',
        "balance": 100,
        "denomination": 'eusd',
        "decimals": 6,
        "pagination": {"nextKey": "0", "total": "0"}
      },
      {
        "graphical_symbol": TokenIcons.eeur,
        "asset_name": 'e-money EUR',
        "ticker": 'eEUR',
        "balance": 23,
        "denomination": 'ueur',
        "decimals": 6,
        "pagination": {"nextKey": "0", "total": "0"}
      }
    ];

    for (int i = 0; i < tokenData.length; i++) {
      Token token = Token.fromJson(tokenData[i]);
      tokens.add(token);
    }
  }
}
