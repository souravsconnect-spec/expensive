import 'package:dio/dio.dart';
import '../models/remote_sync_models.dart';
import '../../../../core/network/dio_service.dart';
import '../../../../core/network/url_helper.dart';

class SyncRemoteDataSource {
  final DioService _dioService;

  SyncRemoteDataSource(this._dioService);

  Future<List<String>> addCategories(
    List<Map<String, dynamic>> categories,
  ) async {
    List<String> syncedIds = [];
    for (var category in categories) {
      try {
        final response = await _dioService.post(
          UrlHelper.addCategories,
          data: category,
        );
        final data = response.data;
        if (data is Map && data['status'] == 'success') {
          syncedIds.add(category['id']);
        }
      } catch (_) {}
    }
    return syncedIds;
  }

  Future<List<String>> addTransactions(
    List<Map<String, dynamic>> transactions,
  ) async {
    final response = await _dioService.post(
      UrlHelper.addTransactions,
      data: {"transactions": transactions},
    );
    final data = response.data;
    if (data is Map &&
        data['status'] == 'success' &&
        data['synced_ids'] != null) {
      return List<String>.from(data['synced_ids']);
    }
    return [];
  }

  Future<List<RemoteCategory>> getCategories(String userId) async {
    final response = await _dioService.get(
      UrlHelper.getCategories,
      queryParameters: {"user_id": userId},
    );
    final data = response.data;
    if (data is Map &&
        data['status'] == 'success' &&
        data['categories'] != null) {
      final list = data['categories'] as List;
      return list.map((json) => RemoteCategory.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<RemoteTransaction>> getTransactions(String userId) async {
    final response = await _dioService.get(
      UrlHelper.getTransactions,
      queryParameters: {"user_id": userId},
    );
    final data = response.data;
    if (data is Map &&
        data['status'] == 'success' &&
        data['transactions'] != null) {
      final list = data['transactions'] as List;
      final transactions = list
          .map((json) => RemoteTransaction.fromJson(json))
          .toList();

      return transactions;
    }
    return [];
  }

  Future<List<String>> deleteCategories(List<String> ids) async {
    List<String> deletedIds = [];
    for (var id in ids) {
      try {
        final response = await _dioService.delete(
          UrlHelper.deleteCategories,
          data: {"category_id": id},
        );
        final data = response.data;
        if (data is Map && data['status'] == 'success') {
          deletedIds.add(id);
        }
      } on DioException catch (e) {
        final data = e.response?.data;
        if (data is Map &&
            (data['message']?.toString().contains('not found') == true ||
                data['messege']?.toString().contains('not found') == true)) {
          deletedIds.add(id);
        }
      } catch (_) {}
    }
    return deletedIds;
  }

  Future<List<String>> deleteTransactions(List<String> ids) async {
    List<String> deletedIds = [];
    for (var id in ids) {
      try {
        final response = await _dioService.delete(
          UrlHelper.deleteTransactions,
          data: {"transaction_id": id},
        );
        final data = response.data;
        if (data is Map && data['status'] == 'success') {
          deletedIds.add(id);
        }
      } on DioException catch (e) {
        final data = e.response?.data;
        if (data is Map &&
            (data['message']?.toString().contains('not found') == true ||
                data['messege']?.toString().contains('not found') == true)) {
          deletedIds.add(id);
        }
      } catch (_) {}
    }
    return deletedIds;
  }
}
