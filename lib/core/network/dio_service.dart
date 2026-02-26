import 'package:dio/dio.dart';
import 'package:expensive/core/services/prefs_service.dart';
import 'url_helper.dart';

class DioService {
  final Dio _dio;
  final PrefsService _prefsService = PrefsService();

  DioService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: UrlHelper.baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _prefsService.getToken();
          print("--- DIO REQUEST START ---");
          print("URL: ${options.baseUrl}${options.path}");
          print("Method: ${options.method}");
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            print("Token: Bearer ${token.substring(0, 10)}...");
          } else {
            print("Token: NOT FOUND");
          }
          print("Headers: ${options.headers}");
          print("--- DIO REQUEST END ---");
          return handler.next(options);
        },
      ),
    );
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      print("GET Success [$path]: ${response.data}");
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      print("POST Success [$path]: ${response.data}");
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      print("PUT Success [$path]: ${response.data}");
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      print("DELETE Success [$path]: ${response.data}");
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      final status = e.response?.statusCode;
      print("Dio Error [$status]: $data");

      if (data is Map) {
        return data['message'] ??
            data['messege'] ??
            'Error: ${data.toString()}';
      }
      return data?.toString() ?? 'Something went wrong (Status: $status)';
    } else {
      print("Dio Network Error: ${e.message}");
      return 'Network error: ${e.message}';
    }
  }
}
