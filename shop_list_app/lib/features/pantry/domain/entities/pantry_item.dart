import 'package:equatable/equatable.dart';

class PantryItem extends Equatable {
  final int? id;
  final int? productId;
  final String name;
  final double quantity;
  final String unit;
  final int categoryId;
  final DateTime? expiryDate;
  final DateTime purchasedDate;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final bool isDeleted;

  const PantryItem({
    this.id,
    this.productId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.categoryId,
    this.expiryDate,
    required this.purchasedDate,
    this.location,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.isDeleted = false,
  });

  /// Check if the item has expired
  bool get isExpired =>
      expiryDate != null && expiryDate!.isBefore(DateTime.now());

  /// Get days until expiry (null if no expiry date)
  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry =
        DateTime(expiryDate!.year, expiryDate!.month, expiryDate!.day);
    return expiry.difference(today).inDays;
  }

  /// Get expiry status (fresh, expiringSoon, expired)
  String get expiryStatus {
    if (expiryDate == null) return 'no-expiry';
    if (isExpired) return 'expired';
    final days = daysUntilExpiry ?? 0;
    if (days < 3) return 'expiring-soon';
    return 'fresh';
  }

  /// Check if out of stock
  bool get isOutOfStock => quantity <= 0;

  factory PantryItem.fromMap(Map<String, dynamic> json) {
    return PantryItem(
      id: json['id'] as int?,
      productId: json['productId'] as int?,
      name: json['name'] as String,
      quantity: json['quantity'] as double,
      unit: json['unit'] as String,
      categoryId: json['categoryId'] as int,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      purchasedDate: DateTime.parse(json['purchasedDate'] as String),
      location: json['location'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSynced: json['isSynced'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'categoryId': categoryId,
      'expiryDate': expiryDate?.toIso8601String(),
      'purchasedDate': purchasedDate.toIso8601String(),
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'isDeleted': isDeleted,
    };
  }

  PantryItem copyWith({
    int? id,
    int? productId,
    String? name,
    double? quantity,
    String? unit,
    int? categoryId,
    DateTime? expiryDate,
    DateTime? purchasedDate,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return PantryItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      categoryId: categoryId ?? this.categoryId,
      expiryDate: expiryDate ?? this.expiryDate,
      purchasedDate: purchasedDate ?? this.purchasedDate,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        name,
        quantity,
        unit,
        categoryId,
        expiryDate,
        purchasedDate,
        location,
        createdAt,
        updatedAt,
        isSynced,
        isDeleted,
      ];
}
