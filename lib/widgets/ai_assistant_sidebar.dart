import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/ai_assistant_service.dart';
import '../utils/constants.dart';

class AiAssistantSidebar extends StatefulWidget {
  final String title;
  final String? contextData;

  const AiAssistantSidebar({super.key, this.title = 'AI Assistant', this.contextData});

  @override
  State<AiAssistantSidebar> createState() => _AiAssistantSidebarState();
}

class _AiAssistantSidebarState extends State<AiAssistantSidebar> {
  final AiAssistantService _assistantService = AiAssistantService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isSending = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_messages.isEmpty) {
      final authProvider = context.read<AuthProvider>();
      _messages.add(
        _ChatMessage(
          text: widget.contextData != null 
            ? 'I see you are looking at this package. How can I help with your planning?'
            : 'Ask me about packages, bookings, destinations, or travel planning.',
          isUser: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isSending) return;

    final authProvider = context.read<AuthProvider>();
    setState(() {
      _messages.add(_ChatMessage(text: message, isUser: true));
      _isSending = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final reply = await _assistantService.sendMessage(
        message: widget.contextData != null 
          ? '[CONTEXT: ${widget.contextData}] $message'
          : message,
        role: authProvider.userRole,
        userName: authProvider.userName,
        history: _messages
            .map(
              (entry) => {
                'role': entry.isUser ? 'user' : 'assistant',
                'message': entry.text,
              },
            )
            .toList(),
      );

      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(text: reply, isUser: false));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            text: 'AI request failed: $e',
            isUser: false,
            isError: true,
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Drawer(
      width: 380,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        widget.title,
                        style: AppTextStyles.title.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hey ${authProvider.userName}, I\'m your personal travel expert.',
                    style: AppTextStyles.body.copyWith(color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message.isUser;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isUser) ...[
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.accent.withOpacity(0.1),
                            child: const Icon(Icons.smart_toy, size: 16, color: AppColors.accent),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isUser ? AppColors.accent : (message.isError ? Colors.red.shade50 : Colors.grey.shade100),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isUser ? 16 : 4),
                                bottomRight: Radius.circular(isUser ? 4 : 16),
                              ),
                            ),
                            child: Text(
                              message.text,
                              style: AppTextStyles.body.copyWith(
                                color: isUser ? Colors.white : AppColors.textMain,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (_isSending)
              const LinearProgressIndicator(minHeight: 2, backgroundColor: Colors.transparent),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: AppDecorations.inputDecoration('Type a message...').copyWith(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: AppColors.accent,
                    child: IconButton(
                      onPressed: _isSending ? null : _sendMessage,
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
  });
}
