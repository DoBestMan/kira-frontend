class Tokens {
  static String getTokenFromDenom(String denom) {
    switch (denom) {
      case 'ukex':
      case 'mkex':
        return "KEX";
    }
    return '';
  }
}
