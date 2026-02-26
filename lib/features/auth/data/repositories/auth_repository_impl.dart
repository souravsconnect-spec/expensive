import 'package:expensive/core/database/db_helper.dart';
import 'package:expensive/core/services/prefs_service.dart';

import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_models.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final PrefsService _prefsService;

  AuthRepositoryImpl(this._remoteDataSource, this._prefsService);

  @override
  Future<AuthResponseModel> sendOtp(String phone) {
    return _remoteDataSource.sendOtp(phone);
  }

  @override
  Future<CreateAccountResponseModel> createAccount(
    String phone,
    String nickname,
  ) {
    return _remoteDataSource.createAccount(phone, nickname);
  }

  @override
  Future<void> saveLocalData(String token, String nickname, String userId) {
    return _prefsService.saveAuthData(token, nickname, userId);
  }

  @override
  Future<String?> getToken() {
    return _prefsService.getToken();
  }

  @override
  Future<String?> getNickname() {
    return _prefsService.getNickname();
  }

  @override
  Future<String?> getUserId() {
    return _prefsService.getUserId();
  }

  @override
  Future<void> logout() async {
    await _prefsService.clearAllData();
    await DbHelper().clearDatabase();
  }
}
