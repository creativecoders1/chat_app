import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/services/alert_service.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../models/user_profile.dart';
import '../services/database_services.dart';
import '../widgets/chat_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    try {
      _authService = _getIt.get<AuthService>();
      _navigationService = _getIt<NavigationService>();
      _alertService = _getIt.get<AlertService>();
      // _databaseService = DatabaseService();
    } catch (e) {
      debugPrint('Error retrieving services: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        actions: [
          IconButton(
            onPressed: () async {
              bool result = await _authService.logout();
              if (result) {
                _alertService.showToast(
                  text: "Successfully logged out!",
                  icon: Icons.check,
                );
                _navigationService.pushReplacementNamed('/login');
              }
            },
            icon: const Icon(Icons.logout),
            color: Colors.red,
          ),
        ],
      ),
      body: _buildUi(),
    );
  }

  Widget _buildUi() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
        child: _buildUserList(),
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot<UserProfile>>(
      stream: _databaseService.getUserProfiles(),
      builder: (context, AsyncSnapshot<QuerySnapshot<UserProfile>> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Unable to Load Data"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data != null) {
          final users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              UserProfile user = users[index].data();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ChatTile(
                  userProfile: user,
                  onTap: () async {
                    final authUser = _authService.user;
                    if (authUser != null && user.uid != null) {
                      final chatExists = await _databaseService.checkChatExists(
                        authUser.uid,
                        user.uid!,
                      );
                      if (!chatExists) {
                        await _databaseService.createNewChat(
                            _authService.user!.uid, user.uid!);
                      }
                      _navigationService
                          .push(MaterialPageRoute(builder: (context) {
                        return ChatPage(chatUser: user);
                      }));
                    }
                  },
                ),
              );
            },
          );
        }

        return const Center(child: Text("No users found"));
      },
    );
  }
}
