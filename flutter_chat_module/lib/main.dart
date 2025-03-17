import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:js' as js;
import 'src/providers/chat_provider.dart';
import 'src/screens/chat_screen.dart';

// This is a basic example of how to use the FlutterChatModule
void main() {
  // Exponer la función de inicialización al JavaScript
  js.context['initializeFlutterChat'] = (dynamic params) {
    final userId = params['userId'] as String;
    final userName = params['userName'] as String;
    final avatarUrl = params['avatarUrl'] as String?;

    runApp(FlutterChatDemo(
      userId: userId,
      userName: userName,
      avatarUrl: avatarUrl,
    ));
  };

  // Iniciar con valores por defecto
  runApp(const FlutterChatDemo(
    userId: 'user123',
    userName: 'Usuario',
    avatarUrl: null,
  ));
}

class FlutterChatDemo extends StatelessWidget {
  final String userId;
  final String userName;
  final String? avatarUrl;

  const FlutterChatDemo({
    Key? key,
    required this.userId,
    required this.userName,
    this.avatarUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChangeNotifierProvider(
        create: (_) => ChatProvider(
          userId: userId,
          userName: userName,
          onError: (error) {
            js.context.callMethod('onChatError', [error]);
          },
        ),
        child: ChatScreen(
          userId: userId,
          userName: userName,
          avatarUrl: avatarUrl,
          onMessageSent: (message) {
            js.context.callMethod('onMessageSent', [message.toJson()]);
          },
        ),
      ),
    );
  }
}
