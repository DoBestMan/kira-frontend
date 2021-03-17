class Tokens {
  static const String kex = 'https://s2.coinmarketcap.com/static/img/coins/64x64/6930.png';
  static const String btc = 'https://s2.coinmarketcap.com/static/img/coins/64x64/1.png';
  static const String atom = 'https://s2.coinmarketcap.com/static/img/coins/64x64/3794.png';
  static const String sent = 'https://s2.coinmarketcap.com/static/img/coins/64x64/2643.png';
  static const String eth = 'https://s2.coinmarketcap.com/static/img/coins/64x64/1027.png';
  static const String eusd = 'https://s2.coinmarketcap.com/static/img/coins/64x64/2075.png';
  static const String eeur = 'https://s2.coinmarketcap.com/static/img/coins/64x64/2075.png';

  static String getTokenIconBySymbol(String name) {
    switch (name) {
      case 'KEX':
        return kex;
      case 'BTC':
        return btc;
      case 'ATOM':
        return atom;
      case 'SENT':
        return sent;
      case 'ETH':
        return eth;
      case 'EUSD':
        return eusd;
      case 'EEUR':
        return eeur;
    }
    return kex;
  }

  static String getTokenFromDenom(String denom) {
    switch (denom) {
      case 'ukex':
      case 'mkex':
        return "KEX";
    }
  }
}
