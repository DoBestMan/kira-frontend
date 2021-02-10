import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:kira_auth/data/account_repository.dart';
import 'package:kira_auth/data/token_repository.dart';
import 'package:kira_auth/router.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/blocs/export.dart';

Future main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    FluroRouter.setupRouter();

    return MultiBlocProvider(
        providers: [
          BlocProvider<AccountBloc>(create: (context) => AccountBloc(IAccountRepository())),
          BlocProvider<TokenBloc>(create: (context) => TokenBloc(ITokenRepository())),
        ],
        child: MaterialApp(
            title: 'Kira Network',
            initialRoute: '/',
            onGenerateRoute: FluroRouter.router.generator,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              // The background color for major parts of the app (toolbars, tab bars, etc)
              primaryColor: KiraColors.kPrimaryColor,
              // The default color of the Material that underlies the Scaffold.
              // scaffoldBackgroundColor: Colors.white,
              // // Text with a color that contrasts with the card and canvas colors.
              textTheme: GoogleFonts.redHatTextTextTheme(Theme.of(context).textTheme),
              // fontFamily: GoogleFonts.aleo().toString(),
              visualDensity: VisualDensity.adaptivePlatformDensity,
              primarySwatch: Colors.purple,
              // A color that contrasts with the primaryColor, e.g. used as the remaining part of a progress bar.
              backgroundColor: KiraColors.kBackgroundColor,
              canvasColor: KiraColors.kBrownColor,
              // cardColor: KiraColors.white,
              primaryTextTheme: TextTheme(
                button: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 60,
                  color: KiraColors.kBrownColor,
                  decorationColor: Colors.purple[300],
                ),
                subtitle2: TextStyle(
                  color: KiraColors.blue2,
                ),
                //Used for the primary text in lists
                subtitle1: TextStyle(
                  color: KiraColors.green1,
                ),
                headline1: TextStyle(color: Colors.purple[50]),
              ),
              // bottomAppBarColor: Colors.purple[900],
              // iconTheme: IconThemeData(color: Colors.purple),
            )));
  }
}
