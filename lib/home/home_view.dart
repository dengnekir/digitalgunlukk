import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:digitalgunluk/home/home_viewmodel.dart';
import 'package:digitalgunluk/core/widgets/colors.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        // Mesajlar yüklendiğinde veya yeni mesaj eklendiğinde aşağı kaydır
        _scrollToBottom();

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Dijital Günlük',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_forever),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Geçmişi Sil'),
                        content: const Text(
                            'Tüm mesajları silmek istediğinizden emin misiniz?'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('İptal'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Sil',
                                style: TextStyle(color: Colors.red)),
                            onPressed: () async {
                              final success =
                                  await viewModel.deleteAllMessages();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Yatay mod seçimi
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    _buildModeChip(
                        context, viewModel, 'Normal', Colors.blue.shade100),
                    const SizedBox(width: 8.0),
                    _buildModeChip(context, viewModel, 'Motivasyon',
                        Colors.green.shade100),
                    const SizedBox(width: 8.0),
                    _buildModeChip(context, viewModel, 'Psikiyatrist',
                        Colors.purple.shade100),
                    const SizedBox(width: 8.0),
                    _buildModeChip(
                        context, viewModel, 'Meditasyon', Colors.teal.shade100),
                    const SizedBox(width: 8.0),
                    _buildModeChip(
                        context, viewModel, 'Eğlence', Colors.orange.shade100),
                    const SizedBox(width: 8.0),
                    _buildModeChip(context, viewModel, 'Gelecek Planları',
                        Colors.grey.shade400),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: viewModel.messages.length,
                  itemBuilder: (context, index) {
                    final message = viewModel.messages[index];
                    final bool isUser = message.sender == 'user';
                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isUser
                              ? colorss.primaryColor.withOpacity(0.8)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20.0).copyWith(
                            bottomLeft: isUser
                                ? const Radius.circular(20.0)
                                : const Radius.circular(0),
                            bottomRight: isUser
                                ? const Radius.circular(0)
                                : const Radius.circular(20.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Mesajınızı yazın...',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide(
                                  color: colorss.primaryColor, width: 2.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 12.0),
                            prefixIcon:
                                const Icon(Icons.edit_note, color: Colors.grey),
                          ),
                          maxLines: null,
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                          style: const TextStyle(color: Colors.black),
                          cursorColor: colorss.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      decoration: BoxDecoration(
                        color: colorss.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorss.primaryColor.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () async {
                          if (_messageController.text.isNotEmpty) {
                            final String currentMessage =
                                _messageController.text;
                            _messageController.clear();
                            final success =
                                await viewModel.sendMessage(currentMessage);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModeChip(
      BuildContext context, HomeViewModel viewModel, String mode, Color color) {
    final bool isSelected = viewModel.selectedMode == mode;
    return GestureDetector(
      onTap: () {
        viewModel.setSelectedMode(mode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? colorss.primaryColor : Colors.transparent,
            width: isSelected ? 2.0 : 0.0,
          ),
        ),
        child: Text(
          mode,
          style: TextStyle(
            color: isSelected ? colorss.primaryColor : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// Mesaj sınıfı (HomeViewModel'da da tanımlanacak)
class Message {
  final String text;
  final String sender; // 'user' or 'ai'
  final DateTime timestamp;

  Message({required this.text, required this.sender, required this.timestamp});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'],
      sender: json['sender'],
      timestamp: (json['timestamp'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'sender': sender,
      'timestamp': timestamp,
    };
  }
}
