// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_fullstack/common/enums/enums.dart';
import 'package:whatsapp_fullstack/common/widgets/loader.dart';
import 'package:whatsapp_fullstack/common/widgets/mymessage_card.dart';
import 'package:whatsapp_fullstack/common/widgets/sender_message_card.dart';
import 'package:whatsapp_fullstack/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_fullstack/models/message_model.dart';
import 'package:whatsapp_fullstack/provider/mesage_reply_provider.dart';

class ChatList extends ConsumerStatefulWidget {
  final String receiverUserId;
  const ChatList({
    Key? key,
    required this.receiverUserId,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final messageController = ScrollController();

  void messageSwipe(
    String message,
    bool isMe,
    MessageEnum messageEnum,
  ) {
    ref.read(messageReplyProvider.state).update(
          (state) => MessageReply(message, isMe, messageEnum),
        );
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream:
          ref.read(chatControllerProvider).getMessages(widget.receiverUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }

        SchedulerBinding.instance.addPostFrameCallback(
          (_) {
            messageController
                .jumpTo(messageController.position.maxScrollExtent);
          },
        );

        return ListView.builder(
          controller: messageController,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final messageData = snapshot.data![index];
            if (messageData.senderId ==
                FirebaseAuth.instance.currentUser!.uid) {
              return MyMessageCard(
                message: messageData.text,
                date: DateFormat.Hm().format(messageData.timesent),
                type: messageData.type,
                repliedMessagetype: messageData.repliedMessageType,
                repliedtext: messageData.repliedMessage,
                username: messageData.repliedTo,
                onleftSwipe: () => messageSwipe(
                  messageData.text,
                  true,
                  messageData.type,
                ),
              );
            }
            return SenderMessageCard(
              message: messageData.text,
              date: DateFormat.Hm().format(messageData.timesent),
              type: messageData.type,
              repliedMessagetype: messageData.repliedMessageType,
              repliedtext: messageData.repliedMessage,
              username: messageData.repliedTo,
              onRightSwipe: () {},
            );
          },
        );
      },
    );
  }
}
