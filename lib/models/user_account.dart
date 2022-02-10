// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  User({
    this.email = "",
    this.firstname = "",
    this.lastname = "",
    this.phoneNumber = "",
    this.avatar = "",
    this.provider = "",
    this.providerId = "",
  });

  String email;
  String firstname;
  String lastname;
  String phoneNumber;
  String? avatar;
  String provider;
  String providerId;

  factory User.fromJson(Map<String, dynamic> json) => User(
        email: json["email"] == null ? null : json["email"],
        firstname: json["firstname"] == null ? null : json["firstname"],
        lastname: json["lastname"] == null ? null : json["lastname"],
        phoneNumber: json["phone_number"] == null ? null : json["phone_number"],
        avatar: json["avatar"] == null ? null : json["avatar"],
        provider: json["provider"] == null ? null : json["provider"],
        providerId: json["provider_id"] == null ? null : json["provider_id"],
      );

  Map<String, dynamic> toJson() => {
        "email": email == null ? null : email,
        "firstname": firstname == null ? null : firstname,
        "lastname": lastname == null ? null : lastname,
        "phone_number": phoneNumber == null ? null : phoneNumber,
        "avatar": avatar == null ? null : avatar,
        "provider": provider == null ? null : provider,
        "provider_id": providerId == null ? null : providerId,
      };
}
