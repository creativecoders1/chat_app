import 'package:chat_app/models/user_profile.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final UserProfile chatUser;
  const ChatPage({super.key, required this.chatUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatUser.name!),
      ),
      body: _buildUi(),
    );
  }

  Widget _buildUi() {
    return Container(
      color: Colors.blue,
    );
  }
}
