import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/models/chat_message.dart';
import 'src/providers/chat_provider.dart';
import 'src/screens/chat_screen.dart';

class FlutterChatModule extends StatelessWidget {
  final String userId;
  final String userName;
  final String? avatarUrl;
  final Function(ChatMessage)? onMessageSent;
  final Function(String)? onError;

  const FlutterChatModule({
    Key? key,
    required this.userId,
    required this.userName,
    this.avatarUrl,
    this.onMessageSent,
    this.onError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(
        userId: userId,
        userName: userName,
        onError: onError,
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: ChatScreen(
          userId: userId,
          userName: userName,
          avatarUrl: avatarUrl,
          onMessageSent: onMessageSent,
        ),
      ),
    );
  }
} 