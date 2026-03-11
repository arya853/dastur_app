/// Represents a student's fee record with payment history.
class FeeRecord {
  final String id;
  final String studentId;
  final double totalFees;
  final double paidFees;
  final double pendingFees;
  final List<PaymentEntry> payments;

  FeeRecord({
    required this.id,
    required this.studentId,
    required this.totalFees,
    required this.paidFees,
    required this.pendingFees,
    required this.payments,
  });

  factory FeeRecord.fromMap(Map<String, dynamic> map, String id) {
    return FeeRecord(
      id: id,
      studentId: map['studentId'] ?? '',
      totalFees: (map['totalFees'] ?? 0).toDouble(),
      paidFees: (map['paidFees'] ?? 0).toDouble(),
      pendingFees: (map['pendingFees'] ?? 0).toDouble(),
      payments: (map['payments'] as List<dynamic>?)
              ?.map((p) => PaymentEntry.fromMap(p))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'totalFees': totalFees,
      'paidFees': paidFees,
      'pendingFees': pendingFees,
      'payments': payments.map((p) => p.toMap()).toList(),
    };
  }

  /// Percentage of fee completion
  double get paidPercentage =>
      totalFees > 0 ? (paidFees / totalFees * 100) : 0;
}

/// A single payment transaction entry.
class PaymentEntry {
  final double amount;
  final DateTime date;
  final String method; // 'online', 'cash', 'cheque'
  final String receiptId;

  PaymentEntry({
    required this.amount,
    required this.date,
    required this.method,
    required this.receiptId,
  });

  factory PaymentEntry.fromMap(Map<String, dynamic> map) {
    return PaymentEntry(
      amount: (map['amount'] ?? 0).toDouble(),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      method: map['method'] ?? 'online',
      receiptId: map['receiptId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'date': date.toIso8601String(),
      'method': method,
      'receiptId': receiptId,
    };
  }
}
