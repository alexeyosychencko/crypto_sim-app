import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../../shared/models/kline_data.dart';

class CandlestickChart extends StatelessWidget {
  final List<KlineData> candles;
  final double height;
  final double candleWidth;
  final double candleGap;

  const CandlestickChart({
    super.key,
    required this.candles,
    this.height = 300,
    this.candleWidth = 8.0,
    this.candleGap = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    if (candles.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('No data')),
      );
    }

    // specific 100 limit is small enough to calculate min/max for all
    final double maxPrice = candles.map((e) => e.high).reduce(max);
    final double minPrice = candles.map((e) => e.low).reduce(min);

    // Add some padding to min/max so candles don't touch edges
    final double priceRange = maxPrice - minPrice;
    final double padding = priceRange * 0.1;
    final double top = maxPrice + padding;
    final double bottom = (minPrice - padding) > 0 ? (minPrice - padding) : 0;

    final double totalWidth = candles.length * (candleWidth + candleGap);

    return SizedBox(
      height: height,
      child: Row(
        children: [
          // Chart Area
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true, // Start showing the most recent (end)
              child: CustomPaint(
                size: Size(totalWidth, height),
                painter: _CandlePainter(
                  candles: candles,
                  minPrice: bottom,
                  maxPrice: top,
                  candleWidth: candleWidth,
                  candleGap: candleGap,
                ),
              ),
            ),
          ),
          // Price Axis (Right Side)
          Container(
            width: 60,
            color: Colors.transparent,
            child: CustomPaint(
              size: Size(60, height),
              painter: _PriceAxisPainter(minPrice: bottom, maxPrice: top),
            ),
          ),
        ],
      ),
    );
  }
}

class _CandlePainter extends CustomPainter {
  final List<KlineData> candles;
  final double minPrice;
  final double maxPrice;
  final double candleWidth;
  final double candleGap;

  _CandlePainter({
    required this.candles,
    required this.minPrice,
    required this.maxPrice,
    required this.candleWidth,
    required this.candleGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final wickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final double priceRange = maxPrice - minPrice;
    if (priceRange <= 0) return;

    // Helper to map price to Y coordinate
    // Y must be inverted (0 is top)
    double mapPriceToY(double price) {
      return size.height - ((price - minPrice) / priceRange) * size.height;
    }

    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final isBullish = candle.close >= candle.open;
      final color = isBullish ? Colors.green : Colors.red;

      paint.color = color;
      wickPaint.color = color;

      final double x = i * (candleWidth + candleGap);
      final double centerX = x + candleWidth / 2;

      final double openY = mapPriceToY(candle.open);
      final double closeY = mapPriceToY(candle.close);
      final double highY = mapPriceToY(candle.high);
      final double lowY = mapPriceToY(candle.low);

      // Draw Wick
      canvas.drawLine(Offset(centerX, highY), Offset(centerX, lowY), wickPaint);

      // Draw Body
      // rect (left, top, right, bottom)
      // Note: openY could be below or above closeY
      canvas.drawRect(
        Rect.fromLTRB(
          x,
          min(openY, closeY),
          x + candleWidth,
          max(openY, closeY),
        ),
        paint,
      );

      // Draw Time Labels periodically (e.g., every 10th candle)
      if (i % 10 == 0) {
        final date = DateTime.fromMillisecondsSinceEpoch(candle.openTime);
        final timeStr = intl.DateFormat('HH:mm').format(date);

        final textSpan = TextSpan(
          text: timeStr,
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        // Position text at bottom
        textPainter.paint(canvas, Offset(x, size.height - textPainter.height));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _PriceAxisPainter extends CustomPainter {
  final double minPrice;
  final double maxPrice;

  _PriceAxisPainter({required this.minPrice, required this.maxPrice});

  @override
  void paint(Canvas canvas, Size size) {
    final double priceRange = maxPrice - minPrice;
    if (priceRange <= 0) return;

    final int steps = 5;
    final double stepValue = priceRange / steps;

    for (int i = 0; i <= steps; i++) {
      final double price = minPrice + (stepValue * i);
      final double y =
          size.height - ((price - minPrice) / priceRange) * size.height;

      final textSpan = TextSpan(
        text: price.toStringAsFixed(2),
        style: const TextStyle(color: Colors.grey, fontSize: 10),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Ensure text stays within bounds
      double yPos = y - textPainter.height / 2;
      if (yPos < 0) {
        yPos = 0;
      }
      if (yPos + textPainter.height > size.height) {
        yPos = size.height - textPainter.height;
      }

      textPainter.paint(canvas, Offset(5, yPos));

      // Optional: Draw grid line tick
      // canvas.drawLine(Offset(0, y), Offset(5, y), Paint()..color = Colors.grey);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
