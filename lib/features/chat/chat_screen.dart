import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talcove/features/providers/chat_list_provider.dart';
import 'package:talcove/features/providers/chat_provider.dart';
import 'package:talcove/models/message.dart';

//تشات سكرين مع لظلظة وحركات
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
  //  FIX: مش final — لازم نستبدله بعد تحميل الرسائل
  // لأن initialItemCount بيُقرأ مرة وحدة عند بناء AnimatedList
  // ولو كان 0 بالبداية، تغيير _messages وحده ما يكفي لعرضها
  GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  // القائمة المحلية هي مصدر الحقيقة للـ AnimatedList
  final List<Message> _messages = [];

  final ValueNotifier<Message?> _replyNotifier = ValueNotifier(null);
  final ValueNotifier<int?> _editIndexNotifier = ValueNotifier(null);
  final ValueNotifier<String?> _inputEditTextNotifier = ValueNotifier(null);
  final ValueNotifier<int> _messageCountNotifier = ValueNotifier(0);

  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;

  //  FIX: تتبع عدد الرسائل اللي زبطنا الـ AnimatedList عليها
  // بنستخدمه لنعرف الرسائل الجديدة الواردة من الـ socket
  int _syncedMessageCount = 0;

  @override
  void initState() {
    super.initState();

    // مراقبة السكرول للـ pagination — لما يوصل للأعلى نجيب صفحة أقدم
    _scrollController.addListener(() {
      if (_scrollController.position.pixels <= 80 && !_isLoading && _hasMore) {
        _loadMoreMessages();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(messageNotifierProvider.notifier).clearMessages();
      await _loadInitialMessages();
      _listenForIncomingMessages();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _replyNotifier.dispose();
    _editIndexNotifier.dispose();
    _inputEditTextNotifier.dispose();
    _messageCountNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadInitialMessages() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final chatNotifier = ref.read(messageNotifierProvider.notifier);
    await chatNotifier.fetchMessagesWithUser(
      otherUserId: widget.otherUserId,
      limit: 20,
      page: 1,
    );

    //  FIX: بعد الـ fetch، زامن _messages مع الـ provider state
    // وحدّث الـ AnimatedList بشكل صحيح
    if (!mounted) return;

    final fetchedMessages = ref.read(messageNotifierProvider);
    _messages.clear();
    _messages.addAll(fetchedMessages);
    _syncedMessageCount = _messages.length;
    _messageCountNotifier.value = _messages.length;

    //  FIX: استبدل الـ GlobalKey بواحد جديد داخل setState
    // هيك Flutter يهدم AnimatedList ويبنيه من صفر
    // بـ initialItemCount = _messages.length الصح (مش 0)
    setState(() {
      _listKey = GlobalKey();
      _isLoading = false;
    });

    _scrollToBottom();
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoading || !_hasMore || !mounted) return;
    setState(() => _isLoading = true);

    // احفظ موقع السكرول الحالي قبل إضافة رسائل قديمة
    final previousExtent = _scrollController.position.maxScrollExtent;

    final nextPage = _currentPage + 1;
    final chatNotifier = ref.read(messageNotifierProvider.notifier);
    await chatNotifier.fetchMessagesWithUser(
      otherUserId: widget.otherUserId,
      limit: 20,
      page: nextPage,
    );

    if (!mounted) return;

    final allMessages = ref.read(messageNotifierProvider);
    final currentMessagesCount = _messages.length;
    final totalMessagesCount = allMessages.length;
    if (allMessages.length == _messages.length) {
      // ما في رسائل جديدة = وصلنا للنهاية
      _hasMore = false;
      setState(() => _isLoading = false);
      return;
    }
    final diff = totalMessagesCount - currentMessagesCount;
    // الرسائل الجديدة القديمة هي الفرق في البداية
    final oldMessages = allMessages.sublist(0, diff);

    // أضف للأعلى في _messages و AnimatedList
    for (int i = oldMessages.length - 1; i >= 0; i--) {
      _messages.insert(0, oldMessages[i]);
      _listKey.currentState?.insertItem(0);
      _syncedMessageCount++;
    }

    _currentPage = nextPage;
    _messageCountNotifier.value = _messages.length;

    setState(() => _isLoading = false);

    // ابقَ في نفس موقع السكرول بعد إضافة الرسائل القديمة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final newExtent = _scrollController.position.maxScrollExtent;
        _scrollController.jumpTo(newExtent - previousExtent);
      }
    });
  }

  void _listenForIncomingMessages() {
    //  FIX: بس نراقب الرسائل الجديدة الواردة من الـ socket
    // الرسائل المحملة من الـ API تمت مزامنتها في _loadInitialMessages
    ref.listenManual(messageNotifierProvider, (previous, next) {
      if (!mounted) return;

      // عدد الرسائل في الـ provider بعد آخر مزامنة
      if (next.length > _syncedMessageCount) {
        final newMessages = next.sublist(_syncedMessageCount);

        for (final msg in newMessages) {
          // تحقق إنو الرسالة ما موجودة أصلاً (تجنب التكرار)
          final alreadyExists = _messages.any((m) => m.id == msg.id);
          if (alreadyExists) continue;

          final insertIndex = _messages.length;
          _messages.add(msg);
          _listKey.currentState?.insertItem(insertIndex);
        }

        _syncedMessageCount = next.length;
        _messageCountNotifier.value = _messages.length;
        _scrollToBottom();
      }
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    final chatNotifier = ref.read(messageNotifierProvider.notifier);

    final editIdx = _editIndexNotifier.value;
    if (editIdx != null) {
      setState(() {
        _messages[editIdx] = _messages[editIdx].copyWith(
          text: text.trim(),
          isEdited: true,
        );
      });
      _editIndexNotifier.value = null;
      _inputEditTextNotifier.value = null;
      _messageCountNotifier.value = _messages.length;
      return;
    }

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      senderId: chatNotifier.currentUserId ?? '',
      receiverId: widget.otherUserId,
      isMe: true,
      timestamp: DateTime.now(),
      replyTo: _replyNotifier.value,
      isSent: true,
    );

    //  FIX: insertItem لازم يصير بنفس اللحظة اللي نضيف فيها للـ _messages
    // addPostFrameCallback كان يسبب race condition لأن الـ frame التالي
    // ممكن يكون فيه تغيير ثاني على القائمة قبل ما insertItem يتنفذ
    final insertIndex = _messages.length;
    _messages.add(newMessage);
    _syncedMessageCount++;
    _messageCountNotifier.value = _messages.length;
    _listKey.currentState?.insertItem(insertIndex);
    _scrollToBottom();

    chatNotifier.sendMessageToSocket(text.trim(), widget.otherUserId);
    _replyNotifier.value = null;

    //  حدّث قائمة المحادثات فوراً بالرسالة المبعوتة
    ref
        .read(chatListNotifierProvider.notifier)
        .updateLastMessage(contactId: widget.otherUserId, message: newMessage);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
  }

  void _deleteMessage(int index) {
    if (index < 0 || index >= _messages.length) return;
    final removedMsg = _messages[index];

    _listKey.currentState?.removeItem(
      index,
      (context, animation) => FadeTransition(
        opacity: animation,
        child: _buildBubble(removedMsg, index, isRemoving: true),
      ),
      duration: const Duration(milliseconds: 250),
    );

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        _messages.removeAt(index);
        _syncedMessageCount = _messages.length;
        _messageCountNotifier.value = _messages.length;
      }
    });
  }

  Widget _buildBubble(Message msg, int index, {bool isRemoving = false}) {
    final colorScheme = Theme.of(context).colorScheme;

    final bubbleColor = msg.isMe
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest;
    final bubbleTextColor = msg.isMe
        ? colorScheme.onPrimary
        : colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: GestureDetector(
        onLongPress: isRemoving ? null : () => _showMessageMenu(msg, index),
        child: Align(
          alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: msg.isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (msg.replyTo != null)
                GestureDetector(
                  onTap: () => _scrollController.animateTo(
                    _scrollController.position.minScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color:
                          colorScheme.tertiaryContainer ??
                          colorScheme.tertiary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border(
                        left: BorderSide(color: colorScheme.tertiary, width: 3),
                      ),
                    ),
                    child: Text(
                      msg.replyTo!.text,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(12),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(msg.text, style: TextStyle(color: bubbleTextColor)),
                    if (msg.isEdited == true)
                      Text(
                        'edited',
                        style: TextStyle(
                          fontSize: 10,
                          color: bubbleTextColor.withOpacity(0.6),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessageMenu(Message msg, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(30, 100, 30, 30),
      items: [
        PopupMenuItem(
          value: 'reply',
          child: Row(
            children: [
              Icon(Icons.reply, color: colorScheme.primary),
              const SizedBox(width: 10),
              const Text('الرد'),
            ],
          ),
        ),
        if (msg.isMe)
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, color: colorScheme.secondary),
                const SizedBox(width: 10),
                const Text('تعديل'),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              Icon(Icons.copy, color: colorScheme.tertiary),
              const SizedBox(width: 10),
              const Text('نسخ'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: colorScheme.error),
              const SizedBox(width: 10),
              const Text('حذف'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (!mounted) return;
      switch (value) {
        case 'reply':
          _replyNotifier.value = msg;
          break;
        case 'edit':
          _editIndexNotifier.value = index;
          _inputEditTextNotifier.value = msg.text;
          break;
        case 'copy':
          Clipboard.setData(ClipboardData(text: msg.text));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم نسخ الرسالة'),
              backgroundColor: colorScheme.inverseSurface,
            ),
          );
          break;
        case 'delete':
          _deleteMessage(index);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // FIX keyboard: يخلي الـ scaffold يتقلص لما الكيبورد يطلع
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
            Column(
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
                  'Online',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.tertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Loading indicator
          if (_isLoading)
            LinearProgressIndicator(
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: colorScheme.primary,
            ),

          // Reply preview
          ValueListenableBuilder<Message?>(
            valueListenable: _replyNotifier,
            builder: (_, replyMsg, __) {
              if (replyMsg == null) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      colorScheme.surfaceContainerHighest ??
                      colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border(
                    left: BorderSide(color: colorScheme.primary, width: 3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        replyMsg.text,
                        style: TextStyle(color: colorScheme.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () => _replyNotifier.value = null,
                    ),
                  ],
                ),
              );
            },
          ),

          // Edit preview
          ValueListenableBuilder<int?>(
            valueListenable: _editIndexNotifier,
            builder: (_, editIdx, __) {
              if (editIdx == null) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      colorScheme.secondaryContainer ??
                      colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.secondary.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit, color: colorScheme.secondary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        editIdx < _messages.length
                            ? _messages[editIdx].text
                            : '',
                        style: TextStyle(color: colorScheme.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        _editIndexNotifier.value = null;
                        _inputEditTextNotifier.value = null;
                      },
                    ),
                  ],
                ),
              );
            },
          ),

          // Message list
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: _messageCountNotifier,
              builder: (_, count, __) {
                return Stack(
                  children: [
                    AnimatedList(
                      key: _listKey,
                      controller: _scrollController,
                      //  FIX: initialItemCount = _messages.length
                      // بعد _loadInitialMessages يخزّن الرسائل قبل ما الـ widget يُبنى
                      initialItemCount: _messages.length,
                      itemBuilder: (context, index, animation) {
                        if (index >= _messages.length) {
                          return const SizedBox.shrink();
                        }
                        final message = _messages[index];
                        return SlideTransition(
                          position: animation.drive(
                            Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).chain(CurveTween(curve: Curves.easeOut)),
                          ),
                          child: _buildBubble(message, index),
                        );
                      },
                    ),
                    if (count == 0 && !_isLoading)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: colorScheme.onSurface.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
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
            top: BorderSide(
              color:
                  colorScheme.outlineVariant ??
                  colorScheme.onSurface.withOpacity(0.12),
              width: 1,
            ),
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
                backgroundColor:
                    colorScheme.surfaceContainerHighest ??
                    colorScheme.onSurface.withOpacity(0.08),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                cursorColor: colorScheme.primary,
                decoration: InputDecoration(
                  hintText: 'اكتب رسالة...',
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
