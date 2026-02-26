import 'package:dio/dio.dart';
import '../../../../core/network/dio_service.dart';
import '../../../../core/network/url_helper.dart';
import '../models/auth_models.dart';

class AuthRemoteDataSource {
  final DioService _dioService;

  AuthRemoteDataSource(this._dioService);

  Future<AuthResponseModel> sendOtp(String phone) async {
    final response = await _dioService.post(
      UrlHelper.sendOtp,
      data: {"phone": phone},
    );
    return AuthResponseModel.fromJson(response.data);
  }

  Future<CreateAccountResponseModel> createAccount(
    String phone,
    String nickname,
  ) async {
    final response = await _dioService.post(
      UrlHelper.createAccount,
      data: {"phone": phone, "nickname": nickname},
    );
    return CreateAccountResponseModel.fromJson(response.data);
  }
}
