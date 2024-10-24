import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:chat_app/utils.dart'; // Assuming this handles Firebase setup
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter is properly initialized
  await setup(); // Await Firebase initialization before running the app
  runApp(MyApp());
}

Future<void> setup() async {
  await setupFirebase(); // Initialize Firebase (Ensure this is properly implemented)
  await registerServices(); // Register services like NavigationService and AuthService
}

Future<void> registerServices() async {
  GetIt getIt = GetIt.instance;
  getIt.registerLazySingleton<NavigationService>(() => NavigationService());
  getIt.registerLazySingleton<AuthService>(() => AuthService());
}

class MyApp extends StatelessWidget {
  final GetIt _getIt = GetIt.instance;
  late NavigationService _navigationService;
  late AuthService _authService;

  MyApp({super.key}) {
    // Retrieve NavigationService and AuthService instances from GetIt
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
  }

  @override
  Widget build(BuildContext context) {
    String initialRoute = _authService.user != null ? "/home" : "/login";

    return MaterialApp(
      navigatorKey: _navigationService.navigatorKey,
      theme: ThemeData(textTheme: GoogleFonts.montserratTextTheme()),
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: _navigationService
          .routes, // Use the routes defined in NavigationService
    );
  }
}
