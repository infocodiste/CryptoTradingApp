import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coin_analyzer/constants.dart';
import 'package:coin_analyzer/models/covalent_models/covalent_token_list.dart';
import 'package:coin_analyzer/utils/misc/chat_encryption.dart';
import 'package:coin_analyzer/utils/misc/credential_manager.dart';
import 'package:coin_analyzer/utils/misc/encryptions.dart';
import 'package:coin_analyzer/utils/misc/file_handler.dart';
import 'package:coin_analyzer/utils/misc/image_handler.dart';
import 'package:coin_analyzer/widget/custom_progress_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme_data.dart';
import 'message_tile.dart';

class ChatOnCoin extends StatelessWidget {
  ChatOnCoin({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CovalentToken token = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
          elevation: 3,
          backgroundColor: Theme.of(context).backgroundColor,
          title: Text(token.contractName),
          centerTitle: true,
          actions: [
            Row(children: [
              FadeInImage(
                image: NetworkImage(token.logoUrl),
                placeholder: AssetImage("assets/icon.png"),
                fadeInDuration: const Duration(milliseconds: 100),
                height: 32.0,
                width: 32.0,
                imageErrorBuilder: (context, error, stackTrace) {
                  return Image.asset(tokenIcon, height: 32);
                },
              ),
              Text(" ${token.contractTickerSymbol}"),
              Container(width: 8.0)
            ])
          ]),
      body: ChatScreen(
        token: token,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final CovalentToken token;

  ChatScreen({Key key, @required this.token}) : super(key: key);

  @override
  State createState() => ChatScreenState(token: token);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({Key key, @required this.token});

  final CovalentToken token;

  // UserDetails user;

  var listMessage;
  String userAddress;
  String groupChatId;
  SharedPreferences prefs;

  File imageFile;
  bool isLoading = false;
  String imageUrl;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    userAddress = '';
    groupChatId = '';
    imageUrl = '';
    getMessages();
  }

  List<Message> messages = [];

  getMessages() async {
    userAddress = await CredentialManager.getAddress();
    groupChatId = token.contractAddress;
    setState(() {});
    // messages.clear();
    // FirebaseFirestore.instance
    //     .collection('messages')
    //     .doc(groupChatId)
    //     .collection(groupChatId)
    //     .orderBy('timestamp', descending: true)
    //     .snapshots()
    //     .listen((event) {
    //   event.docs.forEach((element) {
    //     messages.add(Message.fromJson(element.data()));
    //   });
    //   setState(() {});
    // });
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();

      String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(timeStamp);

      FirebaseFirestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': userAddress,
            'idTo': token.contractAddress,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            // 'content': await ChatEncryption.get().encryptMessage(content),
            'content': content,
            'type': type
            // 'content':
            //     'https://firebasestorage.googleapis.com/v0/b/crypto-fce6b.appspot.com/o/gifs%2Fanimated-happy-birthday-image-0024.gif?alt=media&token=94f960c9-9596-44e8-86a0-a1b34310225e',
            // 'type': 1
          },
        );
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Nothing to send")));
    }
  }

  File image;
  double progress;

  void onSendAttachment() async {
    // type: 0 = text, 1 = image, 2 = sticker

    image = await ImageHandler.get().pickImageGifFile();
    if (image.existsSync()) {
      isLoading = true;
      progress = 0.1;
      setState(() {});
      Message message = Message(
          idFrom: userAddress,
          idTo: token.contractAddress,
          timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
          content: image.path,
          type: 1,
          isLocal: 1);
      messages.add(message);
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      FileHandler.get().uploadFileToFirebase(image, (value) {
        print("Uploading Progress $value");
        progress = value;
        setState(() {});
      }).then((file) {
        isLoading = false;
        progress = null;
        setState(() {});
        print("File Path : $file");
        String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

        var documentReference = FirebaseFirestore.instance
            .collection('messages')
            .doc(groupChatId)
            .collection(groupChatId)
            .doc(timeStamp);

        message.isLocal = 0;

        FirebaseFirestore.instance.runTransaction((transaction) async {
          await transaction.set(
            documentReference,
            {
              'idFrom': message.idFrom,
              'idTo': message.idTo,
              'timestamp': message.timestamp,
              'content': file,
              'type': message.type
            },
          );
        });
        listScrollController.animateTo(0.0,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please select image.")));
    }
  }

  Widget buildItem(QueryDocumentSnapshot document) {
    var start = document['idFrom'].substring(0, 8);
    var end = document['idFrom'].substring(userAddress.length - 4);
    String sender = start + "..." + end;
    var content = document['content'];
    var type = document['type'];

    return MessageTile(
        sender: sender,
        message: content ?? "",
        sentByMe: document['idFrom'] == userAddress,
        type: type);

    // return FutureBuilder(
    //   builder: (context, projectSnap) {
    //     if (projectSnap.connectionState == ConnectionState.none &&
    //         projectSnap.hasData == null) {
    //       return Container();
    //     }
    //     return MessageTile(
    //         sender: sender,
    //         message: projectSnap?.data ?? "",
    //         sentByMe: document['idFrom'] == userAddress,
    //         type: type);
    //   },
    //   future: (type == 0) ? getDecryptMessages(content) : Future
    //       .value(content),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return CustomProgressView(
      inAsyncCall: isLoading,
      progressValue: progress,
      child: Column(
        children: <Widget>[
          // List of messages
          buildListMessage(),
          // Input content
          buildInput(),
        ],
      ),
    );
  }

  Widget buildInput() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 8),
              child: Row(
                children: <Widget>[
                  // Edit text
                  Flexible(
                    child: TextField(
                      style: Theme.of(context).textTheme.bodyText1,
                      controller: textEditingController,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Type your message...',
                      ),
                      minLines: 1,
                      maxLines: 5,
                    ),
                  ),

                  // Button send message
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () =>
                        onSendMessage(textEditingController.text, 0),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).accentColor, width: 0.5),
                borderRadius: BorderRadius.all(Radius.circular(16)),
                color: Theme.of(context).backgroundColor,
              ),
            ),
          ),
          MaterialButton(
            color: Theme.of(context).accentColor,
            child: Icon(Icons.attachment),
            onPressed: () => onSendAttachment(),
            shape: CircleBorder(),
            padding: EdgeInsets.zero,
            minWidth: 36,
          ),
        ],
      ),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.purpleSelected)))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(groupChatId)
                  .collection(groupChatId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.purpleSelected)));
                } else {
                  listMessage = snapshot.data.docs;
                  return ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    itemBuilder: (context, index) {
                      return buildItem(listMessage[index]);
                    },
                    itemCount: listMessage.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            )
      /*ListView.builder(
              key: UniqueKey(),
              padding: EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (context, index) {
                return MessageTile(
                  key: new Key(messages[index].timestamp),
                  sender: messages[index].idFrom,
                  message: messages[index].content ?? "",
                  sentByMe: messages[index].idFrom == userAddress,
                  type: messages[index].type,
                  isLocal: messages[index].isLocal == 1,
                );
              },
              itemCount: messages.length,
              controller: listScrollController,
            )*/
      ,
    );
  }

  Future getDecryptMessages(String content) async {
    return await Encryptions.decryptMessage(content);
  }
}

class Message {
  String idFrom;
  String idTo;
  String timestamp;
  String content;
  int type;
  int isLocal;

  Message(
      {this.idFrom,
      this.idTo,
      this.timestamp,
      this.content,
      this.type,
      this.isLocal});

  Message.fromJson(Map<String, dynamic> json) {
    idFrom = json['idFrom'];
    idTo = json['idTo'];
    timestamp = json['timestamp'];
    content = json['content'];
    type = json['type'];
    isLocal = 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['idFrom'] = this.idFrom;
    data['idTo'] = this.idTo;
    data['timestamp'] = this.timestamp;
    data['content'] = this.content;
    data['type'] = this.type;
    return data;
  }
}
