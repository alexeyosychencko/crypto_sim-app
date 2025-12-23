class TickerData {
  final String symbol;
  final double lastPrice;
  final double priceChangePercent;
  final double volume;

  TickerData({
    required this.symbol,
    required this.lastPrice,
    required this.priceChangePercent,
    required this.volume,
  });

  factory TickerData.fromJson(Map<String, dynamic> json) {
    return TickerData(
      symbol: json['s'] as String,
      lastPrice: double.parse(json['c'] as String),
      priceChangePercent: double.parse(json['P'] as String),
      volume: double.parse(json['v'] as String),
    );
  }
}
