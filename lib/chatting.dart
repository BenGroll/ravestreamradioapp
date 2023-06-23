// ignore_for_file: prefer_interpolation_to_compose_strings

import "dart:convert";
import "package:beamer/beamer.dart";
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ravestreamradioapp/databaseclasses.dart' as dbc;
import 'package:ravestreamradioapp/extensions.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import "package:ravestreamradioapp/conv.dart";
import "package:ravestreamradioapp/database.dart";
import "package:ravestreamradioapp/filesystem.dart";
import 'dart:convert';
import 'dart:typed_data';
import 'package:ravestreamradioapp/extensions.dart' show Stringify, Prettify;
import 'package:flutter/material.dart';
import "package:ravestreamradioapp/realtimedb.dart";
import "package:ravestreamradioapp/screens/chatwindow.dart";
import "package:ravestreamradioapp/shared_state.dart";
import 'package:ravestreamradioapp/extensions.dart';
import 'package:ravestreamradioapp/colors.dart' as cl;
import 'package:ravestreamradioapp/commonwidgets.dart' as cw;
import 'package:firebase_database/firebase_database.dart';
/*
class Message {
  /// Contains full path to the Document
  final String sender;
  /// Unix Timestamp
  final Timestamp sentAt;
  /// the utf8 content of the message
  final String content;
  /// Unique ID
  String? id = generateDocumentID();
  Message(
      {required this.sender,
      required this.sentAt,
      required this.content,
      this.id});
  factory Message.fromMap(Map<dynamic, dynamic> map) {
    return Message(
        content: map["content"],
        sender: map["sender"],
        sentAt: Timestamp.fromMillisecondsSinceEpoch(map["sentAt"]),
        id: map["id"]);
  }
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sender': sender,
      'sentAt': sentAt.millisecondsSinceEpoch,
      'content': content,
      'id': id
    };
  }

  bool operator ==(covariant Message other) {
    if (identical(this, other)) return true;
    return other.content == content &&
        other.sentAt == sentAt &&
        other.id == id &&
        other.sender == sender;
  }

  @override
  String toString() {
    return "Message(sender: $sender, sentAt: $sentAt, content: $content, id: $id)";
  }
}

List<Message> dynamicListToMessageList(List<dynamic> da) {
  List<Message> list = [];
  da.forEach((element) {
    Map<String, dynamic> map = element as Map<String, dynamic>;
    list.add(Message.fromMap(map));
  });
  return list;
}

List<Message> chatFromDB(List<Map<String, dynamic>> map) {
  List<Message> buffer = [];
  map.forEach((element) {
    buffer.add(Message(
      sender: "dev.users/admin",
      sentAt: Timestamp.now(),
      content: "Hallo Welt",
    ));
  });
  return buffer;
}

List<Message> messagesFromDBSnapshot(List messagelist) {
  return messagelist
      .map((e) => Message(
          sender: e["sender"],
          sentAt: Timestamp.fromMillisecondsSinceEpoch(e["sentAt"]),
          content: e["content"]))
      .toList();
}

class Chat {
  final String id;
  List<Message>? messages;
  List<DocumentReference> members;
  String? pathToLogo;
  String? customName;
  Chat(
      {this.messages = const [],
      required this.members,
      this.pathToLogo,
      this.customName,
      required this.id});
  factory Chat.fromMap(Map map) {
    /*print("Members: ${map["members"]}");
    print("Members rtt: ${map["members"].runtimeType}");
    print("Member rtt; ${map["members"][0].runtimeType}");
    print(map["messages"][0].runtimeType);
    */
    List<String> memberstringList =
        forceStringType(map["members"]) as List<String>;
    /*List<Message>? messagelist = map["messages"].map((e) => Message.fromMap(forceStringDynamicMapFromObject(e))).toList();*/
    List<Message>? messagelist;
    if (map["messages"].length == 0 ||
        map["messages"][0].runtimeType == String) {
      messagelist = null;
    }
    return Chat(
        members: forceDocumentReferenceFromStringList(memberstringList),
        messages: map["messages"] == null ? <Message>[] : <Message>[],
        pathToLogo: map["pathToLogo"],
        id: map["id"],
        customName: map["customName"]);
  }
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'messages': messages?.toList() ?? [],
      'members': members.paths(),
      "pathToLogo": pathToLogo,
      "id": id,
      "customName": customName
    };
  }

  factory Chat.fromDBSnapshot(Map snap) {
    List<String> members =
        forceStringType(snap["members"].map((e) => e.toString()).toList());
    List<String> messageIDS = forceStringType(snap["messages"]);
    List<Message> messagelist = messagesFromDBSnapshot(snap["messages"]);
    return Chat(
        members: forceDocumentReferenceFromStringList(members),
        id: snap["id"],
        messages: messagelist,
        customName: snap["customName"]);
  }
  @override
  String toString() {
    return 'Chat(members: $members, id: $id, messages: $messages, customName: $customName)';
  }
}

/// DONT USE, REPLACED WITH RealtimeDB
String encodeChatAsJson(Chat chat) {
  return jsonEncode(chat.toMap());
}

/// DONT USE, REPLACED WITH RealtimeDB
Future uploadChatToDB(Chat chat) async {
  await firebasestorage
      .ref("chats/${chat.id}.json")
      .putString(encodeChatAsJson(chat));
}

/// DONT USE, REPLACED WITH RealtimeDB
Future<Chat> readChatFromDB(String id) async {
  dynamic pathReference = firebasestorage.ref("chats/$id.json");
  Uint8List? data = await pathReference.getData(100 * 1024 * 1024);
  Map map = json.decode(String.fromCharCodes(data ?? Uint8List.fromList([0])));
  return Chat.fromMap(map);
}

/// DONT USE, REPLACED WITH RealtimeDB
Future<List<Chat>> getUsersChats() async {
  if (currently_loggedin_as.value == null) {
    return [];
  } else {
    if (currently_loggedin_as.value!.chats == null) {
      return [];
    }
    List<String> joined_chats = currently_loggedin_as.value?.chats ?? [];
    List<Future<DataSnapshot>> futures = [];
    joined_chats.forEach((element) {
      futures.add(rtdb.ref("root/Chats/$element").get());
    });
    List<DataSnapshot> chats = await Future.wait(futures);
    List<Chat> newchats =
        chats.map((e) => Chat.fromMap(e.value as Map)).toList();
    return newchats;
  }
}

class ChatTile extends StatelessWidget {
  Chat chat;
  ChatTile({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Beamer.of(context).beamToNamed("/chat/${chat.id}");
        /* Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => ChatWindow(id: chat.id)));*/
      },
      leading: Icon(Icons.person, color: Colors.white),
      title: Text(getChatNameFromChat(chat),
          style: TextStyle(color: Colors.white)),
      subtitle: Text("Last Mess..."),
    );
  }
}

String getChatNameFromChat(Chat chat) {
  //return "TestChat";
  if (chat.customName != null && chat.customName!.isNotEmpty) {
    return chat.customName ?? "Empty ChatName";
  } else {
    String? path = getOtherPersonsPathInOoOChat(chat.members);
    if (path == null) {
      return "If this displays look at chatting.dart";
    } else {
      return path.split("/").last.toCapitalized();
    }
  }
}

/// Must never be called when not logged in
String? getOtherPersonsPathInOoOChat(List<DocumentReference> members) {
  String? personspath;
  members.forEach((element) {
    if (element.id != currently_loggedin_as.value!.username) {
      personspath = element.path;
    }
  });
  return personspath;
}

Future<Chat> startNewChat(List<DocumentReference> members) async {
  Chat newChatData = Chat(members: members, id: getRandString(20));
  await setChatData(newChatData);
  return newChatData;
}

class ChatsDrawer extends StatelessWidget {
  const ChatsDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: cl.darkerGrey,
        child: DISABLE_CHATWINDOW ? Center(child: Text("Chatting is disabled due to technical issues. Will be fixed soon.", maxLines: null, style: TextStyle(color: Colors.white),)) :  FutureBuilder(
            future: getUsersChats(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return ListView(
                  children:
                      snapshot.data!.map((e) => ChatTile(chat: e)).toList(),
                );
              } else {
                return cw.LoadingIndicator(color: Colors.white);
              }
            }));
  }
}

String? getChatIDbyMembers(Map<String, List> chats) {
  chats.keys.forEach((element) {});
}

Future<List<Message>> loadMessagesForChat(String chatID) async {
  List ids = await rtdb
      .ref("root/Chats/$chatID/messages")
      .get()
      .then((value) => value.value as List);
  List<Future> futures = [];
  List<Message> messages = [];
  ids.forEach((element) {
    Message? found_message = saved_messages.checkForIDMatch(element);
    if (found_message == null) {
      futures.add(rtdb.ref("root/Messages/$element").get().then((value) {
        Map? data = value.value as Map?;
        if (data != null) {
          data["id"] = element;
          return data;
        }
      }));
    } else {
      messages.add(found_message);
    }
  });
  List<dynamic> messageInfos = await Future.wait(futures);
  List<Map> data = messageInfos.map((e) => e as Map).toList();
  data.forEach((element) {
    messages.add(Message.fromMap(element));
  });
  return messages;
}*/

class ChatsDrawer extends StatelessWidget {
  const ChatsDrawer({super.key});

  List<Widget> buildChatOutlineListTiles(List<ChatOutline>? chatoutlines) {
    List<Widget> outL = [];
    if (chatoutlines == null || chatoutlines.isEmpty) {
      outL.add(Text("You don't have any chats at this moment",
          style: TextStyle(color: Colors.white)));
      return outL;
    }

    chatoutlines.forEach((ChatOutline outLine) {
      String sub = "";
      if (outLine.lastmessage == null) {
        sub = "This chat is empty...";
      } else {
        sub = "@" + outLine.lastmessage!.sentFrom.split("/").last;
        sub = sub + ": " + outLine.lastmessage!.content;
      }
      outL.add(ListTile(
        tileColor: cl.darkerGrey,
        title: Text(outLine.title ?? outLine.chatID,
            maxLines: 1,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
                child: Text(sub, style: TextStyle(color: Colors.white))),
            outLine.lastmessage == null
                ? SizedBox()
                : Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                      timestamp2readablestamp(
                          Timestamp.fromMillisecondsSinceEpoch(
                              outLine.lastmessage!.timestampinMilliseconds)),
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w300)),
                )
          ],
        ),
      ));
    });
    return outL;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: cl.darkerGrey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            tileColor: cl.lighterGrey,
            title: Center(child: Text("Your Chats", style: TextStyle(color: Colors.white, fontSize: DISPLAY_SHORT_SIDE(context) / 20))),
            
          ),
          Expanded(
            child: FutureBuilder(
                future: getChatOutlinesForUserObject(
                    currently_loggedin_as.value ?? dbc.demoUser),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return cw.LoadingIndicator(color: Colors.white);
                  } else {
                    if (snapshot.hasData) {
                      return ListView(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        children: buildChatOutlineListTiles(snapshot.data),
                      );
                    } else {
                      return Center(
                          child: Text("Couldn't load chats.",
                              style: TextStyle(color: Colors.white)));
                    }
                  }
                }),
          ),
        ],
      ),
    );
  }
}

class ChatWindow extends StatelessWidget {
  String id;
  ChatWindow({required this.id});
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class ChatOutline {
  String chatID;
  String? adminUserName;
  String? description;
  List<DocumentReference> members;
  String? title;
  Message? lastmessage;
  ChatOutline(
      {required this.chatID,
      this.adminUserName,
      this.description,
      required this.members,
      this.title,
      this.lastmessage});
  factory ChatOutline.fromMap(Map<String, dynamic> map) {
    return ChatOutline(
        chatID: map["chatID"],
        adminUserName:
            map.containsKey("adminUserName") ? map["adminUserName"] : null,
        description: map.containsKey("description") ? map["description"] : null,
        members: forceDocumentReferenceFromStringList(map["members"]),
        title: map.containsKey("title") ? map["title"] : null,
        lastmessage: map["lastmessage"] != null
            ? Message.fromMap(messageMapFromDynamic(map["lastmessage"]))
            : null);
  }
  Map<String, dynamic> toMap() {
    return {
      "chatID": chatID,
      "adminUserName": adminUserName,
      "description": description,
      "members": members.map((e) => e.path).toList(),
      "title": title,
      "lastmessage": lastmessage != null ? lastmessage!.toMap() : null
    };
  }

  String toString() {
    return "ChatOutline(chatID: $chatID, adminUserName: $adminUserName, description: $description, members: $members, title: $title, lastmessage: $lastmessage)";
  }
}

class Message {
  String sentFrom;
  String content;
  int timestampinMilliseconds;
  Message(
      {required this.sentFrom,
      required this.content,
      required this.timestampinMilliseconds});
  Map<String, dynamic> toMap() {
    return {
      "sentFrom": sentFrom,
      "content": content,
      "timestampinMilliseconds": timestampinMilliseconds
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
        content: map["content"],
        sentFrom: map["sentFrom"],
        timestampinMilliseconds: map["timestampinMilliseconds"]);
  }
}

Map<String, dynamic> chatOutlineMapFromDynamic(dynamic i) {
  Map<String, dynamic> map = {
    "chatID": i["chatID"],
    "members": forceStringType(i["members"]),
    "lastmessage": i.containsKey("lastmessage") ? i["lastmessage"] : null
  };
  return map;
}

Map<String, dynamic> messageMapFromDynamic(dynamic i) {
  return {
    "content": i["content"],
    "sentFrom": i["sentFrom"],
    "timestampinMilliseconds": i["timestampinMilliseconds"]
  };
}

Future writeChatOutline(ChatOutline chatOutline) async {
  DatabaseReference chats = rtdb.ref("root/ChatOutlines");
  await chats.child(chatOutline.chatID).set(chatOutline.toMap());
}

Future<ChatOutline?> readChatOutline(String chatOutlineID) async {
  DatabaseReference chat = rtdb.ref("root/ChatOutlines/${chatOutlineID}");
  DataSnapshot value = await chat.get();
  try {
    Map data = value.value as Map;
    Map<String, dynamic> dataMap = chatOutlineMapFromDynamic(data);
    ChatOutline outLine = ChatOutline.fromMap(dataMap);
    return outLine;
  } catch (e) {
    return null;
  }
}

Future writeLastMessage(String chatID, Message message) async {
  DatabaseReference chat = rtdb.ref("root/ChatOutlines/$chatID");
  DataSnapshot chatdata = await chat.get();
  if (chatdata.value == null) return;
  Map data = chatdata.value as Map;
  data["lastmessage"] = message.toMap();
  await chat.set(data);
  return;
}

Future<List<ChatOutline>?> getChatOutlinesForUserObject(dbc.User user) async {
  List<String> chatIDS = user.chats;
  if (chatIDS.isEmpty) return [];
  List<Future> futures = [];
  chatIDS.forEach((element) {
    futures.add(rtdb.ref("root/ChatOutlines").child(element).get());
  });
  Stopwatch watch = Stopwatch()..start();
  List<dynamic> datas = await Future.wait(futures);
  List<ChatOutline> chatOutlines = datas
      .map((e) => ChatOutline.fromMap(chatOutlineMapFromDynamic(e.value)))
      .toList();
  return chatOutlines;
}
