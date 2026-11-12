import 'dart:convert';

import 'package:altis_library_mobile/core/models/page_response.dart';
import 'package:altis_library_mobile/core/services/http/api_client.dart';

import '../models/loan.dart';

class LoanService {
  LoanService(this._apiClient);

  final ApiClient _apiClient;

  Future<PageResponse<Loan>> getLoans({
    String? name,
    LoanStatus? status,
    int page = 0,
    int size = 10,
    String sortBy = 'loanDate',
    String sortDirection = 'DESC',
  }) async {
    final queryParameters = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      'sortBy': sortBy,
      'sortDirection': sortDirection,
      if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      if (status != null) 'status': status.apiValue,
    };
    final endpoint = Uri(
      path: '/loans',
      queryParameters: queryParameters,
    ).toString();
    final response = await _apiClient.get(endpoint);

    if (response.statusCode != 200) {
      throw LoanRequestException(response.statusCode);
    }

    final json =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return PageResponse<Loan>.fromJson(json, Loan.fromJson);
  }

  Future<PageResponse<Loan>> getMyLoans({
    int page = 0,
    int size = 10,
    String sortBy = 'loanDate',
    String sortDirection = 'DESC',
  }) async {
    final endpoint = Uri(
      path: '/loans/my',
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
        'sortBy': sortBy,
        'sortDirection': sortDirection,
      },
    ).toString();
    final response = await _apiClient.get(endpoint);

    if (response.statusCode != 200) {
      throw LoanRequestException(response.statusCode);
    }

    final json =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return PageResponse<Loan>.fromJson(json, Loan.fromJson);
  }

  Future<void> createLoan(LoanData loan) async {
    final response = await _apiClient.post('/loans', body: loan.toJson());
    _checkWriteResponse(response.statusCode);
  }

  Future<void> updateLoan(int id, LoanData loan) async {
    final response = await _apiClient.put('/loans/$id', body: loan.toJson());
    _checkWriteResponse(response.statusCode);
  }

  Future<void> returnLoan(int id) async {
    final response = await _apiClient.patch('/loans/$id/return');
    _checkWriteResponse(response.statusCode);
  }

  void _checkWriteResponse(int statusCode) {
    if (statusCode < 200 || statusCode >= 300) {
      throw LoanRequestException(statusCode);
    }
  }
}

class LoanRequestException implements Exception {
  const LoanRequestException(this.statusCode);

  final int statusCode;
}
