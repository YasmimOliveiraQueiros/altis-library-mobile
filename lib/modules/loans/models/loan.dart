enum LoanStatus { pending, overdue, returned, returnedLate }

extension LoanStatusApiValue on LoanStatus {
  String get apiValue => switch (this) {
    LoanStatus.pending => 'PENDING',
    LoanStatus.overdue => 'OVERDUE',
    LoanStatus.returned => 'RETURNED',
    LoanStatus.returnedLate => 'RETURNED_LATE',
  };

  static LoanStatus fromApiValue(String value) => switch (value) {
    'PENDING' => LoanStatus.pending,
    'OVERDUE' => LoanStatus.overdue,
    'RETURNED' => LoanStatus.returned,
    'RETURNED_LATE' => LoanStatus.returnedLate,
    _ => throw FormatException('Status de aluguel inválido: $value'),
  };
}

class Loan {
  const Loan({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.bookTitle,
    required this.loanDate,
    required this.returnDate,
    required this.returnedAt,
    required this.status,
    required this.observations,
  });

  final int id;
  final int userId;
  final int bookId;
  final String bookTitle;
  final String loanDate;
  final String returnDate;
  final String? returnedAt;
  final LoanStatus status;
  final String? observations;

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'] as int,
      userId: json['userId'] as int,
      bookId: json['bookId'] as int,
      bookTitle: json['bookTitle'] as String,
      loanDate: json['loanDate'] as String,
      returnDate: json['returnDate'] as String,
      returnedAt: json['returnedAt'] as String?,
      status: LoanStatusApiValue.fromApiValue(json['status'] as String),
      observations: json['observations'] as String?,
    );
  }
}

class LoanData {
  const LoanData({
    required this.userId,
    required this.bookId,
    required this.loanDate,
    required this.returnDate,
    required this.observations,
  });

  final int userId;
  final int bookId;
  final String loanDate;
  final String returnDate;
  final String? observations;

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'bookId': bookId,
    'loanDate': loanDate,
    'returnDate': returnDate,
    'observations': observations,
  };
}
