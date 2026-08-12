import '../local/app_database.dart';
import 'catalog_repository.dart';
import 'comparison_repository.dart';
import 'data_sources.dart';
import 'settings_repository.dart';

class Repositories {
  Repositories({
    AppDatabase? db,
    CatalogDataSource? catalog,
    ComparisonDataSource? comparisons,
    SettingsDataSource? settings,
  })  : assert(
          db != null || (catalog != null && comparisons != null && settings != null),
          'Provide a database or all three data sources',
        ),
        catalog = catalog ?? CatalogRepository(db: db!),
        comparisons = comparisons ?? ComparisonRepository(db: db!),
        settings = settings ?? SettingsRepository(db: db!);

  final CatalogDataSource catalog;
  final ComparisonDataSource comparisons;
  final SettingsDataSource settings;
}
