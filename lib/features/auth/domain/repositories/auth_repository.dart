import 'package:expensive/features/auth/data/models/auth_models.dart';

abstract class AuthRepository {
  Future<AuthResponseModel> sendOtp(String phone);
  Future<CreateAccountResponseModel> createAccount(
    String phone,
    String nickname,
  );
  Future<void> saveLocalData(String token, String nickname, String userId);
  Future<String?> getToken();
  Future<String?> getNickname();
  Future<String?> getUserId();
  Future<void> logout();
}
