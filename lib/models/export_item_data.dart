class ExportItemData {
  final String productId;
  final String productName;
  final double priceAtExport;
  final int quantity;

  ExportItemData({
    required this.productId,
    required this.productName,
    required this.priceAtExport,
    required this.quantity,
  });

  factory ExportItemData.fromJson(Map<String, dynamic> json) {
    return ExportItemData(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      priceAtExport: json['priceAtExport'] as double,
      quantity: json['quantity'] as int,
    );
  }
}
