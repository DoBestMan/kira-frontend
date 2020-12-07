import 'dart:core';

import 'package:flutter_dotenv/flutter_dotenv.dart';

String apiUrl = DotEnv().env['ENVIRONMENT'] == "PRODUCTION"
    ? DotEnv().env['INTERX_PROD_URL']
    : DotEnv().env['INTERX_DEV_URL'];
