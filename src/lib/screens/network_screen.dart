import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kira_auth/utils/export.dart';
import 'package:kira_auth/widgets/export.dart';
import 'package:kira_auth/services/export.dart';
import 'package:kira_auth/blocs/export.dart';
import 'package:kira_auth/models/export.dart';

class NetworkScreen extends StatefulWidget {
  @override
  _NetworkScreenState createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  ValidatorService validatorService = ValidatorService();
  List<Validator> validators = [];
  String query = "";

  void getValidators() async {
    await validatorService.getValidators();
    if (mounted) {
      setState(() {
        validators = validatorService.validators;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getValidators();
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
            childWidget: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: 50, bottom: 50),
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    addHeaderTitle(),
                    addValidatorsTable(context),
                  ],
                ),
              )
            )
          );
        })
    );
  }

  Widget addHeaderTitle() {
    return Container(
      margin: EdgeInsets.only(bottom: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            Strings.validators,
            textAlign: TextAlign.left,
            style: TextStyle(color: KiraColors.white, fontSize: 30, fontWeight: FontWeight.w900),
          ),
          Container(
            width: 500,
            height: 50,
            child: AppTextField(
              hintText: Strings.validator_query,
              labelText: Strings.search,
              textInputAction: TextInputAction.search,
              maxLines: 1,
              autocorrect: false,
              keyboardType: TextInputType.text,
              textAlign: TextAlign.left,
              onChanged: (String newText) {
                this.setState(() {
                  query = newText.toLowerCase();
                });
              },
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18.0,
                color: KiraColors.white,
                fontFamily: 'NunitoSans',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget addValidatorsTable(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ValidatorsTable(
            validators: validators.where((x) =>
              x.moniker.toLowerCase().contains(query) || x.address.toLowerCase().contains(query)).toList(),
            onChangeLikes: (rank) {
              var index = validators.indexWhere((element) => element.rank == rank);
              if (index >= 0)
                this.setState(() {
                  validators[index].isLiked = !validators[index].isLiked;
                });
            },
          ),
        ],
      ));
  }
}
