import 'package:google_sign_in/google_sign_in.dart';
import 'package:runex/models/user_account.dart';

class ProviderGoogle {
  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile',
      'openid',
    ],
  );

  Future<User?> signIn() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      String uid = googleUser!.id;
      String diaplayName = googleUser.displayName!;
      String email = googleUser.email;
      String? avatarUrl = googleUser.photoUrl;

      User data;
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
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signOut() => googleSignIn.signOut();
}
