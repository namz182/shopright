import 'package:flutter/material.dart';

import 'app/shop_right_app.dart';
import 'data/local/app_database.dart';
import 'data/repositories/repositories.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await AppDatabase.open();
  runApp(ShopRightApp(repositories: Repositories(db: database)));
}
