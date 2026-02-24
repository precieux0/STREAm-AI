import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../widgets/message_bubble.dart';
import '../widgets/mode_selector.dart';
import '../widgets/typing_indicator.dart';

class ChatView extends ConsumerStatefulWidget {
  const ChatView({super.key});

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    await ref.read(chatViewModelProvider.notifier).sendMessage(message);

    // Scroll vers le bas après l'envoi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatViewModelProvider);
    final chatViewModel = ref.read(chatViewModelProvider.notifier);

    // Scroll vers le bas quand de nouveaux messages arrivent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return Column(
      children: [
        // Sélecteur de mode
        ModeSelector(
          currentMode: chatState.currentMode,
          onModeChanged: (mode) => chatViewModel.setMode(mode),
        ),

        // Zone de messages
        Expanded(
          child: chatState.messages.isEmpty
              ? _buildEmptyState()
              : _buildMessageList(chatState),
        ),

        // Indicateur de frappe
        if (chatState.isTyping)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TypingIndicator(),
          ),

        // Zone de saisie
        _buildInputArea(chatState),
      ],
    );
  }

  Widget _buildEmptyState() {
    final isAskMode = ref.watch(chatViewModelProvider).currentMode == AppConstants.modeAsk;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: isAskMode ? AppTheme.askModeGradient : AppTheme.agentModeGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isAskMode ? Icons.chat_bubble : Icons.code,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isAskMode ? 'Mode Conversation' : 'Mode Agent',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              isAskMode
                  ? 'Posez-moi des questions sur n\'importe quel sujet. Je suis là pour vous aider !'
                  : 'Je peux générer du code, créer des projets complets et analyser votre code.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          if (!isAskMode)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSuggestionChip('Créer un site web'),
                _buildSuggestionChip('Générer une API REST'),
                _buildSuggestionChip('Analyser mon code'),
                _buildSuggestionChip('Créer une app Flutter'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _messageController.text = label;
      },
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
      side: BorderSide.none,
    );
  }

  Widget _buildMessageList(ChatState chatState) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: chatState.messages.length,
      itemBuilder: (context, index) {
        final message = chatState.messages[index];
        final isLastMessage = index == chatState.messages.length - 1;

        return MessageBubble(
          message: message,
          isLastMessage: isLastMessage,
        )
            .animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildInputArea(ChatState chatState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Bouton effacer
            IconButton(
              onPressed: chatState.messages.isEmpty
                  ? null
                  : () => _showClearDialog(),
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Effacer la conversation',
            ),

            // Champ de saisie
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: chatState.currentMode == AppConstants.modeAsk
                      ? 'Écrivez votre message...'
                      : 'Décrivez ce que vous voulez créer...',
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),

            const SizedBox(width: 8),

            // Bouton envoyer
            Container(
              decoration: BoxDecoration(
                gradient: chatState.currentMode == AppConstants.modeAsk
                    ? AppTheme.askModeGradient
                    : AppTheme.agentModeGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                onPressed: chatState.isLoading ? null : _sendMessage,
                icon: chatState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effacer la conversation ?'),
        content: const Text(
          'Cette action supprimera tous les messages de cette conversation. Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(chatViewModelProvider.notifier).clearConversation();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
  }
}
