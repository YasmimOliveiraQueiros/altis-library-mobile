import 'dart:convert';

import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/modules/dashboard/models/dashboard.dart';
import 'package:altis_library_mobile/modules/dashboard/services/dashboard_service.dart';
import 'package:altis_library_mobile/modules/loans/models/loan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final _dashboardJson = <String, dynamic>{
  'totalUsers': 61,
  'totalBooks': 24,
  'totalPublishers': 8,
  'activeLoans': 12,
  'overdueLoans': 3,
  'returnedLoans': 21,
  'pendingLoans': 9,
  'latestLoans': [
    {
      'id': 31,
      'userId': 42,
      'bookId': 70,
      'bookTitle': 'A Biblioteca',
      'loanDate': '2026-03-10',
      'returnDate': '2026-03-20',
      'returnedAt': '2026-03-20T10:15:00',
      'status': 'RETURNED',
      'observations': 'Devolvido em mãos',
    },
  ],
  'loansByMonth': [
    {'year': 2026, 'month': 3, 'quantity': 7},
    {'year': 2026, 'month': 4, 'quantity': 4},
  ],
  'booksByStatus': {'available': 18, 'rented': 6},
};

void main() {
  test('dashboard model serializes nested response objects and lists', () {
    final dashboard = Dashboard.fromJson(_dashboardJson);

    expect(dashboard.latestLoans.single.status, LoanStatus.returned);
    expect(dashboard.latestLoans.single.returnedAt, '2026-03-20T10:15:00');
    expect(dashboard.loansByMonth.map((month) => month.quantity), [7, 4]);
    expect(dashboard.booksByStatus.available, 18);
    expect(dashboard.toJson(), _dashboardJson);
  });

  test('GET dashboard uses the authenticated API client', () async {
    final requests = <http.Request>[];
    final client = ApiClient(
      client: MockClient((request) async {
        requests.add(request);
        return http.Response.bytes(
          utf8.encode(jsonEncode(_dashboardJson)),
          200,
        );
      }),
    );
    client.setToken('test-token');
    final service = DashboardService(client);

    try {
      final dashboard = await service.getDashboard();

      expect(dashboard.totalUsers, 61);
      expect(dashboard.totalBooks, 24);
      expect(dashboard.totalPublishers, 8);
      expect(dashboard.activeLoans, 12);
      expect(requests, hasLength(1));
      expect(requests.single.method, 'GET');
      expect(requests.single.url.path, '/dashboard');
      expect(requests.single.headers['authorization'], 'Bearer test-token');
    } finally {
      client.dispose();
    }
  });

  test('dashboard request errors retain the HTTP status code', () async {
    final client = ApiClient(
      client: MockClient(
        (_) async => http.Response('backend detail not exposed', 403),
      ),
    );
    final service = DashboardService(client);

    try {
      await expectLater(
        service.getDashboard(),
        throwsA(
          isA<DashboardRequestException>().having(
            (error) => error.statusCode,
            'statusCode',
            403,
          ),
        ),
      );
    } finally {
      client.dispose();
    }
  });
}
