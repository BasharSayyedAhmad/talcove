import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talcove/features/providers/chat_provider.dart';
import 'package:talcove/models/message.dart';

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
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  final List<Message> _messages = [];

  final ValueNotifier<Message?> _replyNotifier = ValueNotifier(null);
  final ValueNotifier<int?> _editIndexNotifier = ValueNotifier(null);
  final ValueNotifier<String?> _inputEditTextNotifier = ValueNotifier(null);

  //  ValueNotifier لعدد الرسائل — بدل setState لتبديل placeholder/list
  final ValueNotifier<int> _messageCountNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

  void _listenForIncomingMessages() {
    ref.listenManual(messageNotifierProvider, (previous, next) {
      if (!mounted) return;
      final prevLen = previous?.length ?? 0;
      final nextLen = next.length;
      if (nextLen > prevLen) {
        final newMsg = next[nextLen - 1];
        final index = _messages.length;
        _messages.add(newMsg);
        _listKey.currentState?.insertItem(index);
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
      _messages[editIdx] = _messages[editIdx].copyWith(
        text: text.trim(),
        isEdited: true,
      );
      _editIndexNotifier.value = null;
      // نحدث الـ count لإجبار الـ AnimatedList على إعادة رسم العنصر المعدّل
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

    final messageIndex = _messages.length;
    _messages.add(newMessage);

    //  نحدث الـ count أولاً حتى يختفي الـ placeholder ويظهر الـ AnimatedList
    _messageCountNotifier.value = _messages.length;

    //  ننتظر frame واحد حتى يتبنى الـ AnimatedList في الـ tree
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listKey.currentState?.insertItem(messageIndex);
      _scrollToBottom();
    });

    chatNotifier.sendMessageToSocket(text.trim(), widget.otherUserId);
    _replyNotifier.value = null;
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
  }

  void _deleteMessage(int index) {
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
        _messageCountNotifier.value = _messages.length;
      }
    });
  }

  Widget _buildBubble(Message msg, int index, {bool isRemoving = false}) {
    final colorScheme = Theme.of(context).colorScheme;
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
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      msg.replyTo!.text,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
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
                  color: msg.isMe ? colorScheme.onPrimary : colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.isMe
                            ? colorScheme.onSurface
                            : colorScheme.onPrimary,
                      ),
                    ),
                    if (msg.isEdited == true)
                      const Text(
                        'edited',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
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
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(30, 100, 30, 30),
      items: [
        const PopupMenuItem(
          value: 'reply',
          child: Row(
            children: [
              Icon(Icons.reply, color: Colors.blue),
              SizedBox(width: 10),
              Text('الرد'),
            ],
          ),
        ),
        if (msg.isMe)
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, color: Colors.orange),
                SizedBox(width: 10),
                Text('تعديل'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              Icon(Icons.copy, color: Colors.green),
              SizedBox(width: 10),
              Text('نسخ'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 10),
              Text('حذف'),
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم نسخ الرسالة')));
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
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.onPrimary,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(fontSize: 18, color: Colors.black),
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
                const Text(
                  'Online',
                  style: TextStyle(fontSize: 11, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
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
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        replyMsg.text,
                        style: const TextStyle(color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
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
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        editIdx < _messages.length
                            ? _messages[editIdx].text
                            : '',
                        style: const TextStyle(color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
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

          //  الـ Stack: placeholder فوق الـ AnimatedList
          // الـ AnimatedList موجود دايماً في الـ tree حتى يكون الـ listKey صالح
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: _messageCountNotifier,
              builder: (_, count, __) {
                return Stack(
                  children: [
                    AnimatedList(
                      key: _listKey,
                      controller: _scrollController,
                      initialItemCount: _messages.length,
                      itemBuilder: (context, index, animation) {
                        if (index >= _messages.length) {
                          return const SizedBox.shrink();
                        }
                        final message = _messages[index];
                        return SlideTransition(
                          position: animation.drive(
                            Tween<Offset>(
                              begin: const Offset(0, 1),
                              end: Offset.zero,
                            ).chain(CurveTween(curve: Curves.easeOut)),
                          ),
                          child: _buildBubble(message, index),
                        );
                      },
                    ),

                    //  Placeholder يظهر فقط لما ما في رسائل
                    if (count == 0)
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: colorScheme.primary,
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.attach_file, color: Colors.green),
            style: IconButton.styleFrom(backgroundColor: Colors.black),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              cursorColor: Colors.blue,
              decoration: const InputDecoration(
                hintText: 'اكتب رسالة...',
                border: InputBorder.none,
              ),
              minLines: 1,
              maxLines: 5,
            ),
          ),
          !_hasText
              ? IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.mic, color: Colors.green),
                  style: IconButton.styleFrom(backgroundColor: Colors.black),
                )
              : IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  style: IconButton.styleFrom(backgroundColor: Colors.black),
                  onPressed: _handleSend,
                ),
        ],
      ),
    );
  }
}
