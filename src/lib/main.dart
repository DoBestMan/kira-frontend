import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:provider/provider.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kira_auth/data/account_repository.dart';
import 'package:kira_auth/router.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/bloc/account_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    FluroRouter.setupRouter();

    return MultiBlocProvider(
        providers: [
          BlocProvider<AccountBloc>(
              create: (context) => AccountBloc(IAccountRepository())),
        ],
        child: DynamicTheme(
            defaultBrightness: Brightness.light,
            data: (brightness) {
              return brightness == Brightness.light
                  ? ThemeData(
                      // The background color for major parts of the app (toolbars, tab bars, etc)
                      primaryColor: KiraColors.kPrimaryColor,
                      // The default color of the Material that underlies the Scaffold.
                      scaffoldBackgroundColor: Colors.white,
                      // // Text with a color that contrasts with the card and canvas colors.
                      textTheme: GoogleFonts.redHatTextTextTheme(
                          Theme.of(context).textTheme),
                      // fontFamily: GoogleFonts.aleo().toString(),
                      visualDensity: VisualDensity.adaptivePlatformDensity,
                      primarySwatch: Colors.purple,
                      // A color that contrasts with the primaryColor, e.g. used as the remaining part of a progress bar.
                      backgroundColor: KiraColors.white,
                      cardColor: KiraColors.white,
                      primaryTextTheme: TextTheme(
                        button: TextStyle(
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
                      bottomAppBarColor: Colors.purple[800],
                      iconTheme: IconThemeData(color: Colors.purple),
                      brightness: brightness,
                    )
                  : ThemeData(
                      primarySwatch: Colors.purple,
                      backgroundColor: Colors.purple[900],
                      cardColor: Colors.black12,
                      primaryTextTheme: TextTheme(
                        button: TextStyle(
                          color: Colors.purple[200],
                          decorationColor: Colors.purple[50],
                        ),
                        subtitle2: TextStyle(
                          color: Colors.white,
                        ),
                        subtitle1: TextStyle(
                          color: Colors.purple[300],
                        ),
                        headline1: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                      bottomAppBarColor: Colors.black,
                      iconTheme: IconThemeData(color: Colors.purple[200]),
                      brightness: brightness,
                    );
            },
            themedWidgetBuilder: (context, data) => MaterialApp(
                title: 'Kira Core',
                initialRoute: '/',
                onGenerateRoute: FluroRouter.router.generator,
                debugShowCheckedModeBanner: false,
                theme: data)));
  }
}
