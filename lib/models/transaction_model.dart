class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final int date;
  final int? categoryId;
  final String? bankName;
  final String? notificationContent;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.categoryId,
    this.bankName,
    this.notificationContent,
  });

  bool get isUnclassified => categoryId == null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date,
      'categoryId': categoryId,
      'bankName': bankName,
      'notificationContent': notificationContent,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: map['date'],
      categoryId: map['categoryId'],
      bankName: map['bankName'],
      notificationContent: map['notificationContent'],
    );
  }
}