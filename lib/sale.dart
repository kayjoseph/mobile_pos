class SaleItem {
  final String productName;
  final int qtySold;

  final double sellingPrice;
  final double purchasePrice;

  final double total;
  final double profit;

  SaleItem({
    required this.productName,
    required this.qtySold,
    required this.sellingPrice,
    required this.purchasePrice,
    required this.total,
    required this.profit,
  });
}

class Sale {
  final List<SaleItem> items;
  final double total;
  final DateTime date;

  Sale({
    required this.items,
    required this.total,
    required this.date,
  });
}
