import 'dart:convert';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:runex/models/user_account.dart';

class ProviderLine {
  Future<void> initLineSdk() async {
    return await LineSDK.instance.setup("Line_Channel_ID");
  }

  Future<User?> signIn() async {
    try {
      final userAuth =
          await LineSDK.instance.login(scopes: ["profile", "openid", "email"]);
      final String jwtStringToken = userAuth.accessToken.data["id_token"];
      final Map<String, dynamic> jwtToken = parseJwt(jwtStringToken);

      String uid = userAuth.userProfile!.userId;
      String diaplayName = userAuth.userProfile!.displayName;
      String email = jwtToken["email"];
      String? avatarUrl = userAuth.userProfile?.pictureUrl;

      User data;
      data = User(
        email: email,
        firstname: diaplayName,
        lastname: "",
        phoneNumber: "",
        avatar: avatarUrl,
        provider: "LINE",
        providerId: uid,
      );

      return data;
    } catch (error) {
      throw error;
    }
  }

  Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('invalid payload');
    }

    return payloadMap;
  }

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }
    return utf8.decode(base64Url.decode(output));
  }

  Future<void> signOut() => LineSDK.instance.logout();
}
