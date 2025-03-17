import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String? avatarUrl;
  final Function(ChatMessage)? onMessageSent;

  const ChatScreen({
    Key? key,
    required this.userId,
    required this.userName,
    this.avatarUrl,
    this.onMessageSent,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          Consumer<ChatProvider>(
            builder: (context, provider, child) {
              return Icon(
                provider.isConnected ? Icons.cloud_done : Icons.cloud_off,
                color: provider.isConnected ? Colors.green : Colors.red,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) {
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final message = provider.messages[index];
                    final isMe = message.senderId == widget.userId;
                    return _buildMessageBubble(message, isMe);
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              backgroundImage: message.senderId == widget.userId && widget.avatarUrl != null
                  ? NetworkImage(widget.avatarUrl!)
                  : null,
              child: widget.avatarUrl == null
                  ? Text(message.senderName[0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: ChatBubble(
              clipper: ChatBubbleClipper1(type: isMe ? BubbleType.sendBubble : BubbleType.receiverBubble),
              alignment: isMe ? Alignment.topRight : Alignment.topLeft,
              margin: EdgeInsets.zero,
              backGroundColor: isMe ? Colors.blue : Colors.grey[300],
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMe) ...[
                      Text(
                        message.senderName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (message.type == MessageType.image)
                      Image.network(
                        message.imageUrl!,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const CircularProgressIndicator();
                        },
                      )
                    else if (message.type == MessageType.file)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.attach_file),
                          const SizedBox(width: 8),
                          Text(message.fileName ?? 'File'),
                        ],
                      )
                    else
                      Text(
                        message.message,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('HH:mm').format(message.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _handleAttachment,
          ),
          IconButton(
            icon: const Icon(Icons.photo),
            onPressed: _handleImageSelection,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message',
                border: InputBorder.none,
              ),
              minLines: 1,
              maxLines: 5,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _handleAttachment() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      // Aquí implementarías la lógica para subir el archivo
      // y obtener la URL del archivo
      final fileName = result.files.first.name;
      final fileUrl = 'URL_DEL_ARCHIVO'; // Esto debería ser implementado
      
      final provider = context.read<ChatProvider>();
      provider.sendFile(fileUrl, fileName);
    }
  }

  void _handleImageSelection() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Aquí implementarías la lógica para subir la imagen
      // y obtener la URL de la imagen
      final imageUrl = 'URL_DE_LA_IMAGEN'; // Esto debería ser implementado
      
      final provider = context.read<ChatProvider>();
      provider.sendImage(imageUrl);
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      final provider = context.read<ChatProvider>();
      provider.sendMessage(message);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
} 