import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kira_auth/widgets/token_balances_table.dart';
import 'package:kira_auth/widgets/header_wrapper.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/cache.dart';
import 'package:kira_auth/bloc/account_bloc.dart';

class WithdrawalScreen extends StatefulWidget {
  @override
  _WithdrawalScreenState createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
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
              return HeaderWrapper(
                  childWidget: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    addHeaderText(),
                    addWithdrawalTransactionTable(),
                  ],
                ),
              ));
            }));
  }

  Widget addHeaderText() {
    return Container(
        margin: EdgeInsets.only(bottom: 50),
        child: Text(
          "Withdrawal",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: KiraColors.black,
              fontSize: 40,
              fontWeight: FontWeight.w900),
        ));
  }

  Widget addWithdrawalTransactionTable() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Container(
            margin: EdgeInsets.only(bottom: 30), child: TokenBalancesTable()));
  }
}
