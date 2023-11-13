import 'dart:convert';

List<Message> modelMessageFromJson(String messages) {
  return List<Message>.from(json.decode(messages).map((x) => Message.fromJson(x)));
}

class Message {
  Message({
    this.id,
    this.text,
    this.type,
    this.avatarUrl,
    this.sendStatus,
    this.senderName,
    this.operatorId,
    this.time,
    this.isEdited,
  });

  String? id;
  String? text;
  String? type;
  String? avatarUrl;
  String? sendStatus;
  String? senderName;
  String? operatorId;
  int? time;
  bool? isEdited;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json["id"],
    text: json["text"],
    type: json["type"],
    avatarUrl: json["avatarUrl"],
    sendStatus: json["sendStatus"],
    senderName: json["senderName"],
    operatorId: json["operatorId"],
    time: json["time"],
    isEdited: json["isEdited"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "text": text,
    "type": type,
    "avatarUrl": avatarUrl,
    "sendStatus": sendStatus,
    "senderName": senderName,
    "operatorId": operatorId,
    "time": time,
    "isEdited": isEdited,
  };
}