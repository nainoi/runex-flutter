import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:runex/models/user_account.dart';

class ProviderFacebook {
  FacebookAuth fbAuth = FacebookAuth.instance;

  Future<User?> signIn() async {
    try {
      final LoginResult result =
          await fbAuth.login(permissions: ['public_profile', 'email']);
      if (result.status == LoginStatus.success) {
        final userData = await fbAuth.getUserData();
        final AccessToken accessToken = result.accessToken!;

        String uid = accessToken.userId;
        String diaplayName = userData['name'];
        String email = userData['email'];
        String avatarUrl = userData['picture']['data']['url'];

        User? data;
        data = User(
          email: email,
          firstname: diaplayName,
          lastname: "",
          phoneNumber: "",
          avatar: avatarUrl,
          provider: "GOOGLE",
          providerId: uid,
        );

        return data;
      } else {
        throw Exception();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signOut() => fbAuth.logOut();
}
