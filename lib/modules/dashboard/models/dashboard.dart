import '../../loans/models/loan.dart';

class Dashboard {
  const Dashboard({
    required this.totalUsers,
    required this.totalBooks,
    required this.totalPublishers,
    required this.activeLoans,
    required this.overdueLoans,
    required this.returnedLoans,
    required this.pendingLoans,
    required this.latestLoans,
    required this.loansByMonth,
    required this.booksByStatus,
  });

  final int totalUsers;
  final int totalBooks;
  final int totalPublishers;
  final int activeLoans;
  final int overdueLoans;
  final int returnedLoans;
  final int pendingLoans;
  final List<Loan> latestLoans;
  final List<LoansByMonth> loansByMonth;
  final BooksByStatus booksByStatus;

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      totalUsers: json['totalUsers'] as int,
      totalBooks: json['totalBooks'] as int,
      totalPublishers: json['totalPublishers'] as int,
      activeLoans: json['activeLoans'] as int,
      overdueLoans: json['overdueLoans'] as int,
      returnedLoans: json['returnedLoans'] as int,
      pendingLoans: json['pendingLoans'] as int,
      latestLoans: List<Loan>.unmodifiable(
        (json['latestLoans'] as List<dynamic>).map(
          (loan) => Loan.fromJson(loan as Map<String, dynamic>),
        ),
      ),
      loansByMonth: List<LoansByMonth>.unmodifiable(
        (json['loansByMonth'] as List<dynamic>).map(
          (month) => LoansByMonth.fromJson(month as Map<String, dynamic>),
        ),
      ),
      booksByStatus: BooksByStatus.fromJson(
        json['booksByStatus'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'totalUsers': totalUsers,
    'totalBooks': totalBooks,
    'totalPublishers': totalPublishers,
    'activeLoans': activeLoans,
    'overdueLoans': overdueLoans,
    'returnedLoans': returnedLoans,
    'pendingLoans': pendingLoans,
    'latestLoans': latestLoans.map((loan) => loan.toJson()).toList(),
    'loansByMonth': loansByMonth.map((month) => month.toJson()).toList(),
    'booksByStatus': booksByStatus.toJson(),
  };
}

class LoansByMonth {
  const LoansByMonth({
    required this.year,
    required this.month,
    required this.quantity,
  });

  final int year;
  final int month;
  final int quantity;

  factory LoansByMonth.fromJson(Map<String, dynamic> json) => LoansByMonth(
    year: json['year'] as int,
    month: json['month'] as int,
    quantity: json['quantity'] as int,
  );

  Map<String, dynamic> toJson() => {
    'year': year,
    'month': month,
    'quantity': quantity,
  };
}

class BooksByStatus {
  const BooksByStatus({required this.available, required this.rented});

  final int available;
  final int rented;

  factory BooksByStatus.fromJson(Map<String, dynamic> json) => BooksByStatus(
    available: json['available'] as int,
    rented: json['rented'] as int,
  );

  Map<String, dynamic> toJson() => {'available': available, 'rented': rented};
}
