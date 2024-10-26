import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/services/alert_service.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/database_services.dart';
import 'package:chat_app/services/media_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:chat_app/services/storage_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

/// Initializes Firebase with platform-specific options.
Future<void> setupFirebase() async {
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    print("Firebase initialized successfully.");
  } catch (e) {
    print("Error initializing Firebase: $e");
    // Optionally handle or log the error in a way that suits your app
  }
}

/// Registers app services with GetIt for dependency injection.
Future<void> registerServices() async {
  final GetIt getIt = GetIt.instance;
  getIt.registerSingleton<AuthService>(AuthService());
  getIt.registerSingleton<NavigationService>(NavigationService());
  getIt.registerSingleton<AlertService>(AlertService());
  getIt.registerSingleton<MediaService>(MediaService());
  getIt.registerSingleton<StorageService>(StorageService());
  getIt.registerSingleton<DatabaseService>(DatabaseService());
}

String generateChatID({required String uid1, required String uid2}) {
  List uids = [uid1, uid2];
  uids.sort();
  String chatId = uids.fold("", (id, uid) => "$id$uid");
  return chatId;
}

/// Returns the screen width for responsive UI design.
double screenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

/// Returns the screen height for responsive UI design.
double screenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}
