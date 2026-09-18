import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/shop_right_app.dart';
import 'data/local/app_database.dart';
import 'data/repositories/repositories.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final database = await AppDatabase.open();
  runApp(ShopRightApp(repositories: Repositories(db: database)));
}
