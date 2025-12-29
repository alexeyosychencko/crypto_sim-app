class KlineData {
  final int openTime;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final int closeTime;

  KlineData({
    required this.openTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.closeTime,
  });

  factory KlineData.fromJson(List<dynamic> json) {
    return KlineData(
      openTime: json[0] as int,
      open: double.parse(json[1] as String),
      high: double.parse(json[2] as String),
      low: double.parse(json[3] as String),
      close: double.parse(json[4] as String),
      volume: double.parse(json[5] as String),
      closeTime: json[6] as int,
    );
  }
}
