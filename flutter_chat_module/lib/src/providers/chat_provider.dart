import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/chat_message.dart';
import '../services/mock_chat_service.dart';

class ChatProvider with ChangeNotifier {
  final String userId;
  final String userName;
  final Function(String)? onError;
  
  final MockChatService _chatService = MockChatService();
  final List<ChatMessage> _messages = [];
  bool _isConnected = true;
  
  ChatProvider({
    required this.userId,
    required this.userName,
    this.onError,
  }) {
    // Suscribirse al stream de mensajes
    _chatService.messageStream.listen(
      (message) {
        _messages.add(message);
        notifyListeners();
      },
      onError: (error) {
        _isConnected = false;
        onError?.call('Error en el chat: $error');
        notifyListeners();
      },
    );

    // Enviar mensaje de bienvenida
    _sendSystemMessage('¡Bienvenido al chat! Soy tu asistente virtual.');
  }

  List<ChatMessage> get messages => _messages;
  bool get isConnected => _isConnected;

  void sendMessage(String message) {
    if (!_isConnected) {
      onError?.call('No conectado al chat');
      return;
    }

    final chatMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: userId,
      senderName: userName,
      message: message,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );

    _chatService.sendMessage(chatMessage);
  }

  void sendImage(String imageUrl) {
    if (!_isConnected) {
      onError?.call('No conectado al chat');
      return;
    }

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: userId,
      senderName: userName,
      message: 'Envió una imagen',
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
      type: MessageType.image,
    );

    _messages.add(message);
    notifyListeners();
    _chatService.sendImage(imageUrl);
  }

  void sendFile(String fileUrl, String fileName) {
    if (!_isConnected) {
      onError?.call('No conectado al chat');
      return;
    }

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: userId,
      senderName: userName,
      message: 'Envió un archivo',
      fileUrl: fileUrl,
      fileName: fileName,
      timestamp: DateTime.now(),
      type: MessageType.file,
    );

    _messages.add(message);
    notifyListeners();
    _chatService.sendFile(fileUrl, fileName);
  }

  void _sendSystemMessage(String message) {
    final systemMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'system',
      senderName: 'Sistema',
      message: message,
      timestamp: DateTime.now(),
      type: MessageType.system,
    );

    _messages.add(systemMessage);
    notifyListeners();
  }

  @override
  void dispose() {
    _chatService.dispose();
    super.dispose();
  }
} 