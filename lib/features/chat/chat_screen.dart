import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talcove/features/people/user_profile_screen.dart';
import 'package:talcove/features/providers/chat_provider.dart';
import 'package:talcove/generated/l10n.dart';
import 'package:talcove/models/message.dart';
import 'package:talcove/models/user.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhoto;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhoto,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<Message?> _replyNotifier = ValueNotifier(null);
  final ValueNotifier<int?> _editIndexNotifier = ValueNotifier(null);
  final ValueNotifier<String?> _inputEditTextNotifier = ValueNotifier(null);
  late MessageNotifier _chatNotifier;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _chatNotifier = ref.read(messageNotifierProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _chatNotifier.setActiveChatUser(widget.otherUserId);
      _chatNotifier.setupSocketListeners();
      _chatNotifier.clearMessages();
      _loadInitialMessages();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _chatNotifier.detachListeners();
    _chatNotifier.setActiveChatUser(null);

    _scrollController.dispose();
    _replyNotifier.dispose();
    _editIndexNotifier.dispose();
    _inputEditTextNotifier.dispose();

    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels <= 80 && !_isLoading && _hasMore) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadInitialMessages() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    await ref
        .read(messageNotifierProvider.notifier)
        .fetchMessagesWithUser(
          otherUserId: widget.otherUserId,
          limit: 20,
          page: 1,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);
    _scrollToBottom();
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoading || !_hasMore || !mounted) return;
    setState(() => _isLoading = true);

    final nextPage = _currentPage + 1;
    final previousCount = ref.read(messageNotifierProvider).length;

    await ref
        .read(messageNotifierProvider.notifier)
        .fetchMessagesWithUser(
          otherUserId: widget.otherUserId,
          limit: 15,
          page: nextPage,
        );

    if (!mounted) return;

    final newCount = ref.read(messageNotifierProvider).length;

    if (newCount == previousCount) {
      _hasMore = false;
    }

    _currentPage = nextPage;
    setState(() => _isLoading = false);
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    ref
        .read(messageNotifierProvider.notifier)
        .sendMessageToSocket(text.trim(), widget.otherUserId);

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildBubble(Message msg) {
    final colorScheme = Theme.of(context).colorScheme;

    final bubbleColor = msg.isMe
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest;
    final bubbleTextColor = msg.isMe
        ? colorScheme.onPrimary
        : colorScheme.onSurface;

    final isPending = msg.id.startsWith('temp_');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: msg.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!msg.isMe) ...[
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: widget.otherUserPhoto != null
                    ? NetworkImage(widget.otherUserPhoto!)
                    : null,
                child: widget.otherUserPhoto == null
                    ? Text(
                        widget.otherUserName.isNotEmpty
                            ? widget.otherUserName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: msg.isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (!msg.isMe)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 2),
                  child: Text(
                    widget.otherUserName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                    ),
                  ),
                ),
              Opacity(
                opacity: isPending ? 0.65 : 1.0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.65,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(msg.isMe ? 12 : 0),
                      bottomRight: Radius.circular(msg.isMe ? 0 : 12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(msg.text, style: TextStyle(color: bubbleTextColor)),
                      if (msg.isEdited) ...[
                        const SizedBox(height: 2),
                        Text(
                          'edited',
                          style: TextStyle(
                            fontSize: 10,
                            color: bubbleTextColor.withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (msg.isMe)
                Padding(
                  padding: const EdgeInsets.only(top: 2, right: 4),
                  child: Icon(
                    isPending
                        ? Icons.access_time_rounded
                        : msg.isRead
                        ? Icons.done_all
                        : msg.isDelivered
                        ? Icons.done_all
                        : Icons.done,
                    size: 13,
                    color: msg.isRead
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<Message>>(messageNotifierProvider, (previous, next) {
      if (previous != null && next.length > previous.length) {
        _scrollToBottom();
      }
    });

    final messages = ref.watch(messageNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          children: [
            if (widget.otherUserPhoto != null) ...[
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(widget.otherUserPhoto!),
              ),
              const SizedBox(width: 8),
            ],
            InkWell(
              onTap: () {
                final targerUser = User(
                  id: widget.otherUserId,
                  userName: widget.otherUserName,
                  photoUrl: widget.otherUserPhoto,
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => UserProfileScreen(user: targerUser),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    S.of(context).online,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.tertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_isLoading)
            LinearProgressIndicator(
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: colorScheme.primary,
            ),
          Expanded(
            child: messages.isEmpty && !_isLoading
                ? Center(
                    child: Text(
                      S.of(context).noMessagesYet,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) =>
                        _buildBubble(messages[index]),
                  ),
          ),
          _ChatInputField(
            editTextNotifier: _inputEditTextNotifier,
            onSend: _sendMessage,
            onCancelEdit: () {
              _editIndexNotifier.value = null;
              _inputEditTextNotifier.value = null;
            },
          ),
        ],
      ),
    );
  }
}

class _ChatInputField extends StatefulWidget {
  final ValueNotifier<String?> editTextNotifier;
  final void Function(String) onSend;
  final VoidCallback onCancelEdit;

  const _ChatInputField({
    required this.editTextNotifier,
    required this.onSend,
    required this.onCancelEdit,
  });

  @override
  State<_ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<_ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    widget.editTextNotifier.addListener(_onEditRequested);
  }

  void _onTextChanged() {
    final has = _controller.text.isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  void _onEditRequested() {
    final text = widget.editTextNotifier.value;
    if (text != null) {
      _controller.text = text;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: text.length),
      );
    } else {
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    widget.editTextNotifier.removeListener(_onEditRequested);
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(color: colorScheme.outlineVariant, width: 1),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.attach_file,
                color: colorScheme.onSurfaceVariant,
              ),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                cursorColor: colorScheme.primary,
                decoration: InputDecoration(
                  hintText: S.of(context).typeMessage,
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                style: TextStyle(color: colorScheme.onSurface),
                minLines: 1,
                maxLines: 5,
              ),
            ),
            !_hasText
                ? IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.mic, color: colorScheme.onPrimary),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                    ),
                  )
                : IconButton(
                    icon: Icon(Icons.send, color: colorScheme.onPrimary),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                    ),
                    onPressed: _handleSend,
                  ),
          ],
        ),
      ),
    );
  }
}
