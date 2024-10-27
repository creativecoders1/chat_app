import 'dart:io';

import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/media_service.dart';
import 'package:chat_app/services/storage_services.dart';
import 'package:chat_app/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../models/chat.dart';
import '../models/message.dart';
import '../services/database_services.dart';

class ChatPage extends StatefulWidget {
  final UserProfile chatUser;

  const ChatPage({super.key, required this.chatUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ChatUser? currentUser, otherUser;
  GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late StorageService _storageService;
  late MediaService _mediaService;
  late DatabaseService _databaseService;
  bool _isUploading = false; // Track upload status

  @override
  void initState() {
    super.initState();
    _storageService = StorageService();
    _authService = _getIt.get<AuthService>();
    _mediaService = MediaService();
    _databaseService = DatabaseService();
    currentUser = ChatUser(
        id: _authService.user!.uid, firstName: _authService.user!.displayName);
    otherUser = ChatUser(
        id: widget.chatUser.uid!,
        firstName: widget.chatUser.name,
        profileImage: widget.chatUser.pfpURL);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatUser.name!),
      ),
      body: Stack(
        children: [
          _buildUi(),
          if (_isUploading) // Show loading indicator when uploading
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUi() {
    return StreamBuilder<DocumentSnapshot<Chat>>(
        stream: _databaseService.getChatData(currentUser!.id, otherUser!.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading chat data."));
          }

          Chat? chat = snapshot.data?.data();
          List<ChatMessage> messages = [];
          if (chat != null && chat.messages != null) {
            messages = _generateChatMessageList(chat.messages!);
          }

          return DashChat(
            messageOptions: const MessageOptions(
                showOtherUsersAvatar: true, showTime: true),
            inputOptions: InputOptions(alwaysShowSend: true, trailing: [
              _mediaMessageButton(),
            ]),
            currentUser: currentUser!,
            onSend: _sendMessage,
            messages: messages,
          );
        });
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    try {
      // Check if the message contains media
      if (chatMessage.medias?.isNotEmpty ?? false) {
        if (chatMessage.medias!.first.type == MediaType.image) {
          Message message = Message(
              senderID: chatMessage.user.id,
              content: chatMessage.medias!.first.url,
              messageType: MessageType.image,
              sentAt: Timestamp.fromDate(chatMessage.createdAt));
          await _databaseService.sendChatMessage(
              currentUser!.id, otherUser!.id, message);

          // Debug: Print the sent image message details
          print(
              "Sent Image Message: ${message.content} - Type: ${message.messageType}");
          return;
        }
      }
      // For text messages
      Message message = Message(
          senderID: currentUser!.id,
          content: chatMessage.text,
          messageType: MessageType.text,
          sentAt: Timestamp.fromDate(chatMessage.createdAt));
      await _databaseService.sendChatMessage(
          currentUser!.id, otherUser!.id, message);

      // Debug: Print the sent text message details
      print(
          "Sent Text Message: ${message.content} - Type: ${message.messageType}");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to send message")));
      print("Error sending message: $e");
    }
  }

  List<ChatMessage> _generateChatMessageList(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((m) {
      if (m.messageType == MessageType.image) {
        return ChatMessage(
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          createdAt: m.sentAt?.toDate() ?? DateTime.now(),
          medias: [
            ChatMedia(url: m.content!, fileName: '', type: MediaType.image)
          ],
        );
      }
      return ChatMessage(
        user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
        createdAt: m.sentAt?.toDate() ?? DateTime.now(),
        text: m.content ?? "",
      );
    }).toList();

    // Sort messages by creation date
    chatMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return chatMessages;
  }

  Widget _mediaMessageButton() {
    return IconButton(
        onPressed: () async {
          try {
            File? file = await _mediaService.getImageFromGallery();
            if (file != null) {
              setState(() => _isUploading = true); // Show loading indicator
              String chatId =
                  generateChatID(uid1: currentUser!.id, uid2: otherUser!.id);
              String? downloadURL = await _storageService.uploadImageToChat(
                  file: file, chatId: chatId);

              if (downloadURL != null) {
                ChatMessage chatMessage = ChatMessage(
                    user: currentUser!,
                    createdAt: DateTime.now(),
                    medias: [
                      ChatMedia(
                          url: downloadURL, fileName: '', type: MediaType.image)
                    ]);

                // Send the message
                await _sendMessage(chatMessage);
              } else {
                throw Exception("Download URL is null");
              }
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Failed to upload image")));
            print("Error uploading image: $e");
          } finally {
            setState(() => _isUploading = false); // Hide loading indicator
          }
        },
        icon: const Icon(
          Icons.image,
          color: Colors.blue,
        ));
  }
}
