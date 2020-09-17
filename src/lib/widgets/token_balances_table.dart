import 'package:flutter/material.dart';

class TokenBalancesTable extends StatefulWidget {
  const TokenBalancesTable({
    Key key,
  }) : super(key: key);

  @override
  _TokenBalancesTableState createState() => _TokenBalancesTableState();
}

class _TokenBalancesTableState extends State<TokenBalancesTable> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Text('TEST')]));
  }
}
