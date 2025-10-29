import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_call_app/core/controller/global_naviagtor.dart';
import 'package:video_call_app/features/splash_screen/presentation/splash_screen.dart';
import 'package:video_call_app/features/users/logic/bloc/user_list_bloc.dart';

import 'configs/dependency_injection.dart';
import 'data/hive/hive_keys.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getTemporaryDirectory()).path,
    ),
  );
  setupLocator();
  //+ Hive
  await Hive.initFlutter();
  await Hive.openBox(HiveBoxNames.userBox);

  HydratedBloc.storage = storage;

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => UserListBloc())],
      child: MaterialApp(
        title: 'Hipster Inc Video Call App',
        navigatorKey: locator<GlobalNavigator>().navigatorKey,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: BlocProvider(
          create: (context) => UserListBloc(),
          child: const SplashScreen(),
        ),
      ),
    );
  }
}
