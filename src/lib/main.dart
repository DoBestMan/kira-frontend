import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
          BlocProvider<AccountBloc>(create: (context) => AccountBloc()),
        ],
        child: MaterialApp(
          title: 'Kira Core',
          initialRoute: '/',
          onGenerateRoute: FluroRouter.router.generator,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: KiraColors.kPrimaryColor,
            scaffoldBackgroundColor: Colors.white,
            textTheme:
                GoogleFonts.redHatTextTextTheme(Theme.of(context).textTheme),
            fontFamily: GoogleFonts.aleo().toString(),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
        ));
  }
}
