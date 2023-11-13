import 'dart:convert';

Operator operatorModelFromJson(String str) {
  return Operator.fromJson(json.decode(str));
}

class Operator {
  Operator({
    this.id,
    this.name,
    this.avatarUrl,
  });

  String? id;
  String? name;
  String? avatarUrl;

  factory Operator.fromJson(Map<String, dynamic> json) => Operator(
    id: json["id"],
    name: json["name"],
    avatarUrl: json["avatarUrl"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "avatarUrl": avatarUrl,
  };
}