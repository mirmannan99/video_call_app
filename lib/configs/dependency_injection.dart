import 'package:get_it/get_it.dart';

import '../core/controller/global_naviagtor.dart';

final locator = GetIt.instance;
void setupLocator() {
  locator.registerLazySingleton<GlobalNavigator>(() => GlobalNavigator());
}
