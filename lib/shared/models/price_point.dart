class PricePoint {
  final DateTime timestamp;
  final double price;

  PricePoint({required this.timestamp, required this.price});

  @override
  String toString() {
    return 'PricePoint(timestamp: $timestamp, price: $price)';
  }
}
