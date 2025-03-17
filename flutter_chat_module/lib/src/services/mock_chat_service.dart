import 'dart:async';
import 'dart:math';
import '../models/chat_message.dart';

class MockChatService {
  final StreamController<ChatMessage> _messageController = StreamController<ChatMessage>.broadcast();
  final String _botId = 'bot_assistant';
  final String _botName = 'Chat Assistant';
  final Random _random = Random();
  Timer? _typingTimer;

  Stream<ChatMessage> get messageStream => _messageController.stream;

  void dispose() {
    _messageController.close();
    _typingTimer?.cancel();
  }

  void sendMessage(ChatMessage message) {
    // Emitir el mensaje del usuario
    _messageController.add(message);

    // Simular que el bot está escribiendo
    _typingTimer?.cancel();
    _typingTimer = Timer(Duration(seconds: 1 + _random.nextInt(2)), () {
      // Generar respuesta del bot
      final botResponse = _generateBotResponse(message);
      _messageController.add(botResponse);
    });
  }

  ChatMessage _generateBotResponse(ChatMessage userMessage) {
    final responses = [
      'Entiendo lo que dices sobre "${userMessage.message}"',
      '¡Interesante punto de vista!',
      'Gracias por compartir eso conmigo',
      '¿Podrías elaborar más sobre ese tema?',
      'Me parece una idea muy interesante',
      'Estoy procesando lo que me dices...',
      '¿Qué te hace pensar eso?',
      'Cuéntame más al respecto',
    ];

    String response = responses[_random.nextInt(responses.length)];

    // Si el mensaje contiene una pregunta, usar respuestas específicas
    if (userMessage.message.contains('?')) {
      response = _generateQuestionResponse(userMessage.message);
    }

    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _botId,
      senderName: _botName,
      message: response,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );
  }

  String _generateQuestionResponse(String question) {
    final questionResponses = {
      RegExp(r'(?i)hola|hi|hey'): [
        '¡Hola! ¿Cómo estás?',
        '¡Hey! ¿En qué puedo ayudarte?',
        '¡Saludos! ¿Qué tal tu día?'
      ],
      RegExp(r'(?i)cómo estás|how are you'): [
        '¡Muy bien, gracias por preguntar! ¿Y tú?',
        'Excelente, listo para ayudarte',
        '¡Todo bien por aquí! ¿Qué tal tú?'
      ],
      RegExp(r'(?i)qué haces|what are you doing'): [
        'Aquí, charlando contigo y aprendiendo',
        'Procesando información y ayudando usuarios',
        'Estoy aquí para asistirte en lo que necesites'
      ],
      RegExp(r'(?i)nombre|name'): [
        'Me llamo Chat Assistant, ¡un placer conocerte!',
        'Soy Chat Assistant, tu asistente virtual',
        'Chat Assistant a tu servicio'
      ],
    };

    for (var entry in questionResponses.entries) {
      if (entry.key.hasMatch(question)) {
        return entry.value[_random.nextInt(entry.value.length)];
      }
    }

    return '¡Buena pregunta! Déjame pensar en eso...';
  }

  // Simular envío de imagen
  void sendImage(String imageUrl) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _botId,
      senderName: _botName,
      message: '¡Bonita imagen! Gracias por compartirla.',
      timestamp: DateTime.now(),
      type: MessageType.text,
    );

    Timer(const Duration(seconds: 1), () {
      _messageController.add(message);
    });
  }

  // Simular envío de archivo
  void sendFile(String fileUrl, String fileName) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _botId,
      senderName: _botName,
      message: 'He recibido tu archivo "$fileName". ¡Gracias!',
      timestamp: DateTime.now(),
      type: MessageType.text,
    );

    Timer(const Duration(seconds: 1), () {
      _messageController.add(message);
    });
  }
} 