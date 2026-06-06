// import 'package:flutter/material.dart';
// import 'package:talcove/models/message.dart';

// class ChatBubble extends StatelessWidget {
//   final Message message;
//   final Animation<double>? animation;
//   final VoidCallback? onReply;
//   final VoidCallback? onEdit;
//   final VoidCallback? onDelete;
//   final VoidCallback? onCopy;
//   final VoidCallback? onReplyTap;

//   const ChatBubble({
//     super.key,
//     required this.message,
//     this.animation,
//     this.onReply,
//     this.onEdit,
//     this.onDelete,
//     this.onCopy,
//     this.onReplyTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isMe = message.isMe;
//     final colorScheme = Theme.of(context).colorScheme;

//     Widget bubbleContent = Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // صورة اذا كانت موجودى
//         if (message.image != null)
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: ConstrainedBox(
//               constraints: BoxConstraints(
//                 maxWidth: MediaQuery.of(context).size.width * 0.5,
//                 maxHeight: 250,
//               ),
//               child: message.image,
//             ),
//           ),

//         //  نص إذا وجد
//         if (message.text.isNotEmpty)
//           Padding(
//             padding: message.image != null
//                 ? const EdgeInsets.only(top: 8)
//                 : EdgeInsets.zero,
//             child: Text(
//               message.text,
//               style: TextStyle(
//                 color: isMe ? colorScheme.onPrimary : colorScheme.onSecondary,
//                 fontSize: 14,
//               ),
//             ),
//           ),

//         //  الوقت + حالة التعديل
//         const SizedBox(height: 4),
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             //  الوقت
//             Text(
//               _formatTime(message.timestamp),
//               style: TextStyle(
//                 fontSize: 10,
//                 color: isMe
//                     ? colorScheme.secondary.withValues(alpha: 0.6)
//                     : colorScheme.onSurfaceVariant,
//               ),
//             ),
//             const SizedBox(width: 6),

//             if (message.isEdited)
//               Text(
//                 'edited',
//                 style: TextStyle(
//                   fontSize: 9,
//                   color: isMe
//                       ? colorScheme.onPrimary.withValues(alpha: 0.6)
//                       : colorScheme.onSurfaceVariant,
//                 ),
//               ),
//           ],
//         ),
//       ],
//     );

//     if (message.replyTo != null) {
//       bubbleContent = Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           GestureDetector(
//             onTap: onReplyTap,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//               margin: const EdgeInsets.only(bottom: 6),
//               decoration: BoxDecoration(
//                 color: isMe
//                     ? colorScheme.primary.withValues(alpha: 0.2)
//                     : colorScheme.surfaceContainerHighest,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     Icons.reply,
//                     size: 12,
//                     color: isMe
//                         ? colorScheme.onPrimary
//                         : colorScheme.inverseSurface,
//                   ),
//                   const SizedBox(width: 6),
//                   Expanded(
//                     child: Text(
//                       message.replyTo!.text,
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: isMe
//                             ? colorScheme.onPrimary.withValues(alpha: 0.8)
//                             : colorScheme.onSurfaceVariant,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           bubbleContent,
//         ],
//       );
//     }

//     Widget messageBubble = Container(
//       margin: const EdgeInsets.symmetric(vertical: 4),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       constraints: BoxConstraints(
//         maxWidth: MediaQuery.of(context).size.width * 0.75,
//       ),
//       decoration: BoxDecoration(
//         color: isMe ? colorScheme.primary : colorScheme.inverseSurface,
//         borderRadius: BorderRadius.only(
//           topLeft: const Radius.circular(18),
//           topRight: const Radius.circular(18),
//           bottomLeft: isMe
//               ? const Radius.circular(18)
//               : const Radius.circular(4),
//           bottomRight: isMe
//               ? const Radius.circular(4)
//               : const Radius.circular(18),
//         ),
//       ),
//       child: bubbleContent,
//     );

//     if (animation != null) {
//       messageBubble = SizeTransition(
//         sizeFactor: animation!,
//         child: messageBubble,
//       );
//     }

//     return GestureDetector(
//       onLongPress: () => _showContextMenu(context),
//       child: Align(
//         alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//         child: Stack(clipBehavior: Clip.none, children: [messageBubble]),
//       ),
//     );
//   }

//   void _showContextMenu(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) => SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (onReply != null)
//               ListTile(
//                 leading: const Icon(Icons.reply, color: Colors.blue),
//                 title: const Text('Reply'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   onReply?.call();
//                 },
//               ),
//             if (onEdit != null && message.isMe)
//               ListTile(
//                 leading: const Icon(Icons.edit, color: Colors.orange),
//                 title: const Text('Edit'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   onEdit?.call();
//                 },
//               ),
//             if (onCopy != null)
//               ListTile(
//                 leading: const Icon(Icons.copy, color: Colors.green),
//                 title: const Text('Copy'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   onCopy?.call();
//                 },
//               ),
//             if (onDelete != null && message.isMe)
//               ListTile(
//                 leading: const Icon(Icons.delete, color: Colors.red),
//                 title: const Text('Delete'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   onDelete?.call();
//                 },
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatTime(DateTime time) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final msgDate = DateTime(time.year, time.month, time.day);

//     if (msgDate == today) {
//       return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
//     } else if (msgDate == today.subtract(const Duration(days: 1))) {
//       return 'Yesterday';
//     } else {
//       return '${time.day}/${time.month}/${time.year}';
//     }
//   }
// }
