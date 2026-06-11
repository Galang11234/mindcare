class PaymentModel {
  final String id;
  final String userId;
  final String orderId;
  final int amount;
  final String currency;
  final String paymentType;
  final String status;
  final String? description;
  final String? snapToken;
  final String? paymentUrl;
  final String? createdAt;
  final String? paidAt;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.paymentType,
    required this.status,
    this.description,
    this.snapToken,
    this.paymentUrl,
    this.createdAt,
    this.paidAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      orderId: json['order_id'] as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String? ?? 'IDR',
      paymentType: json['payment_type'] as String? ?? '',
      status: json['status'] as String,
      description: json['description'] as String?,
      snapToken: json['snap_token'] as String?,
      paymentUrl: json['payment_url'] as String?,
      createdAt: json['created_at'] as String?,
      paidAt: json['paid_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'order_id': orderId,
    'amount': amount,
    'currency': currency,
    'payment_type': paymentType,
    'status': status,
    'description': description,
    'snap_token': snapToken,
    'payment_url': paymentUrl,
    'created_at': createdAt,
    'paid_at': paidAt,
  };
}
