import 'dart:convert';

import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/modules/loans/models/loan.dart';
import 'package:altis_library_mobile/modules/loans/services/loan_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _loanJson = {
  'id': 31,
  'userId': 42,
  'bookId': 70,
  'bookTitle': 'A Biblioteca',
  'loanDate': '2026-03-10',
  'returnDate': '2026-03-20',
  'returnedAt': null,
  'status': 'PENDING',
  'observations': null,
};

Map<String, dynamic> _page({int total = 1, List<Object?>? content}) => {
  'content': content ?? [_loanJson],
  'totalElements': total,
  'totalPages': total == 0 ? 0 : 1,
  'number': 0,
  'size': 10,
  'first': true,
  'last': true,
  'empty': total == 0,
};

void main() {
  test('loan model and request payload match the documented fields', () {
    final loan = Loan.fromJson(_loanJson);
    const request = LoanData(
      userId: 42,
      bookId: 70,
      loanDate: '2026-03-10',
      returnDate: '2026-03-20',
      observations: null,
    );

    expect(loan.status, LoanStatus.pending);
    expect(loan.returnedAt, isNull);
    expect(loan.loanDate, '2026-03-10');
    expect(request.toJson(), {
      'userId': 42,
      'bookId': 70,
      'loanDate': '2026-03-10',
      'returnDate': '2026-03-20',
      'observations': null,
    });
    expect(request.toJson(), isNot(contains('status')));
    expect(request.toJson(), isNot(contains('returnedAt')));
  });

  test(
    'list filters, pagination, sorting, and my-loans use documented routes',
    () async {
      final requests = <http.Request>[];
      final client = ApiClient(
        client: MockClient((request) async {
          requests.add(request);
          return http.Response.bytes(
            utf8.encode(jsonEncode(_page(total: 17))),
            200,
          );
        }),
      );
      client.setToken('test-token');
      final service = LoanService(client);

      try {
        final page = await service.getLoans(
          name: ' Ana & Silva ',
          status: LoanStatus.overdue,
          page: 2,
          size: 20,
          sortBy: 'returnDate',
          sortDirection: 'ASC',
        );
        final myLoans = await service.getMyLoans(page: 1, size: 5);

        expect(page.totalElements, 17);
        expect(page.content.single.bookTitle, 'A Biblioteca');
        expect(myLoans.content.single.userId, 42);
        expect(requests[0].method, 'GET');
        expect(requests[0].url.path, '/loans');
        expect(requests[0].url.queryParameters, {
          'name': 'Ana & Silva',
          'status': 'OVERDUE',
          'page': '2',
          'size': '20',
          'sortBy': 'returnDate',
          'sortDirection': 'ASC',
        });
        expect(requests[1].url.path, '/loans/my');
        expect(requests[1].url.queryParameters, {
          'page': '1',
          'size': '5',
          'sortBy': 'loanDate',
          'sortDirection': 'DESC',
        });
        expect(requests.first.headers['authorization'], 'Bearer test-token');
      } finally {
        client.dispose();
      }
    },
  );

  test(
    'create, update, and return accept empty successful responses',
    () async {
      final requests = <http.Request>[];
      final client = ApiClient(
        client: MockClient((request) async {
          requests.add(request);
          final statusCode = switch (request.method) {
            'POST' => 201,
            'PUT' => 204,
            _ => 200,
          };
          return http.Response('', statusCode);
        }),
      );
      final service = LoanService(client);
      const data = LoanData(
        userId: 42,
        bookId: 70,
        loanDate: '2026-03-10',
        returnDate: '2026-03-20',
        observations: 'Sem observações',
      );

      try {
        await service.createLoan(data);
        await service.updateLoan(31, data);
        await service.returnLoan(31);

        expect(requests.map((request) => request.method), [
          'POST',
          'PUT',
          'PATCH',
        ]);
        expect(requests[0].url.path, '/loans');
        expect(requests[1].url.path, '/loans/31');
        expect(requests[2].url.path, '/loans/31/return');
        expect(requests[2].body, isEmpty);
        expect(jsonDecode(requests[0].body), data.toJson());
      } finally {
        client.dispose();
      }
    },
  );

  test('non-success responses retain status without exposing body', () async {
    final client = ApiClient(
      client: MockClient(
        (_) async => http.Response('private backend detail', 409),
      ),
    );
    final service = LoanService(client);

    try {
      await expectLater(
        service.returnLoan(31),
        throwsA(
          isA<LoanRequestException>().having(
            (error) => error.statusCode,
            'statusCode',
            409,
          ),
        ),
      );
    } finally {
      client.dispose();
    }
  });
}
