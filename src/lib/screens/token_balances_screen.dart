import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kira_auth/widgets/appbar_wrapper.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/cache.dart';
import 'package:kira_auth/bloc/account_bloc.dart';

class TokenBalanceScreen extends StatefulWidget {
  @override
  _TokenBalanceScreenState createState() => _TokenBalanceScreenState();
}

class _TokenBalanceScreenState extends State<TokenBalanceScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    checkPasswordExpired().then((success) {
      if (success) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });

    return Scaffold(
        body: BlocConsumer<AccountBloc, AccountState>(
            listener: (context, state) {},
            builder: (context, state) {
              return AppbarWrapper(
                  childWidget: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    addHeaderText(),
                  ],
                ),
              ));
            }));
  }

  Widget addHeaderText() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Text(
          "Tokens",
          textAlign: TextAlign.center,
          style: TextStyle(color: KiraColors.kPrimaryColor, fontSize: 30),
        ));
  }
}
