import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/messaging/conversation.dart';
import '../../providers/messaging_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'chat_screen.dart';

class ConversationsListScreen extends StatefulWidget {
  const ConversationsListScreen({super.key});

  @override
  State<ConversationsListScreen> createState() => _ConversationsListScreenState();
}

class _ConversationsListScreenState extends State<ConversationsListScreen> {
  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessagingProvider>().loadConversations();
      context.read<MessagingProvider>().loadUnreadMessagesCount();
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final d = now.difference(date);
    if (d.inMinutes < 1) return 'À l\'instant';
    if (d.inMinutes < 60) return 'Il y a ${d.inMinutes} min';
    if (d.inHours < 24) return 'Il y a ${d.inHours}h';
    if (d.inDays < 7) return 'Il y a ${d.inDays} j';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Messagerie'),
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _showArchived = !_showArchived);
              if (_showArchived) {
                context.read<MessagingProvider>().loadArchivedConversations();
              }
            },
            child: Text(
              _showArchived ? 'Actives' : 'Archivées',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<MessagingProvider>(
        builder: (context, provider, _) {
          final list =
              _showArchived ? provider.archivedConversations : provider.conversations;

          if (provider.isLoading && list.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null && list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Réessayer',
                      onPressed: () {
                        provider.clearError();
                        provider.loadConversations();
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 80,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _showArchived
                          ? 'Aucune conversation archivée'
                          : 'Aucune conversation',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _showArchived
                          ? 'Vos conversations archivées apparaîtront ici.'
                          : 'Démarrez une conversation depuis une annonce (Contacter).',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              if (_showArchived) {
                await provider.loadArchivedConversations();
              } else {
                await provider.loadConversations();
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final conversation = list[index];
                return _buildConversationTile(
                    context, conversation, provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildConversationTile(
    BuildContext context,
    Conversation conversation,
    MessagingProvider provider,
  ) {
    final participantsLabel = conversation.participants
        .map((p) => p.name)
        .where((n) => n.isNotEmpty)
        .join(', ');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: () async {
          await provider.loadConversationDetails(conversation.id);
          if (!context.mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                conversationId: conversation.id,
                conversation: provider.currentConversation ?? conversation,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      conversation.subject,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatDate(conversation.lastMessageAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                ],
              ),
              if (participantsLabel.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  participantsLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (conversation.propertyTitle != null &&
                  conversation.propertyTitle!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.home_work_outlined,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        conversation.propertyTitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
