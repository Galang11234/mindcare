class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String avatarEmoji;
  final String? avatarUrl;
  final String? phone;
  final String? city;
  final String? occupation;
  final String plan; // free | premium | institution
  final DateTime? planExpiresAt;
  final String? institutionId;
  final bool onboarded;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarEmoji = '😊',
    this.avatarUrl,
    this.phone,
    this.city,
    this.occupation,
    this.plan = 'free',
    this.planExpiresAt,
    this.institutionId,
    this.onboarded = false,
    required this.createdAt,
  });

  bool get isPremium =>
      (plan == 'premium' || plan == 'institution') &&
      (planExpiresAt == null || planExpiresAt!.isAfter(DateTime.now()));

  bool get isInstitution => plan == 'institution';

  String get planLabel {
    switch (plan) {
      case 'premium': return 'Premium';
      case 'institution': return 'Institusi';
      default: return 'Gratis';
    }
  }

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: j['id'] ?? '',
    email: j['email'] ?? '',
    fullName: j['full_name'] ?? '',
    avatarEmoji: j['avatar_emoji'] ?? '😊',
    avatarUrl: j['avatar_url'],
    phone: j['phone'],
    city: j['city'],
    occupation: j['occupation'],
    plan: j['plan'] ?? 'free',
    planExpiresAt: j['plan_expires_at'] != null
        ? DateTime.tryParse(j['plan_expires_at']) : null,
    institutionId: j['institution_id'],
    onboarded: j['onboarded'] ?? false,
    createdAt: DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'email': email, 'full_name': fullName,
    'avatar_emoji': avatarEmoji, 'avatar_url': avatarUrl,
    'phone': phone, 'city': city, 'occupation': occupation,
    'plan': plan,
    'plan_expires_at': planExpiresAt?.toIso8601String(),
    'institution_id': institutionId,
    'onboarded': onboarded,
    'created_at': createdAt.toIso8601String(),
  };

  UserModel copyWith({
    String? fullName, String? avatarEmoji, String? phone,
    String? city, String? occupation, String? plan,
    DateTime? planExpiresAt, bool? onboarded,
  }) => UserModel(
    id: id, email: email, createdAt: createdAt,
    fullName: fullName ?? this.fullName,
    avatarEmoji: avatarEmoji ?? this.avatarEmoji,
    avatarUrl: avatarUrl, institutionId: institutionId,
    phone: phone ?? this.phone,
    city: city ?? this.city,
    occupation: occupation ?? this.occupation,
    plan: plan ?? this.plan,
    planExpiresAt: planExpiresAt ?? this.planExpiresAt,
    onboarded: onboarded ?? this.onboarded,
  );
}

class PaymentModel {
  final String id;
  final String orderId;
  final int amount;
  final String status;
  final String? paymentMethod;
  final String? description;
  final DateTime createdAt;
  final DateTime? paidAt;

  const PaymentModel({
    required this.id, required this.orderId, required this.amount,
    required this.status, this.paymentMethod, this.description,
    required this.createdAt, this.paidAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> j) => PaymentModel(
    id: j['id'] ?? '',
    orderId: j['order_id'] ?? '',
    amount: j['amount'] ?? 0,
    status: j['status'] ?? 'pending',
    paymentMethod: j['payment_method'],
    description: j['description'],
    createdAt: DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
    paidAt: j['paid_at'] != null ? DateTime.tryParse(j['paid_at']) : null,
  );

  String get formattedAmount =>
      'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  String get statusLabel {
    switch (status) {
      case 'paid': return 'Berhasil';
      case 'pending': return 'Menunggu';
      case 'failed': return 'Gagal';
      case 'expired': return 'Kedaluwarsa';
      case 'refunded': return 'Dikembalikan';
      default: return status;
    }
  }
}