import 'package:dio/dio.dart';
import '../models/kline_data.dart';

class KlineService {
  final Dio _dio;

  KlineService([Dio? dio]) : _dio = dio ?? Dio();

  Future<List<KlineData>> getKlines(
    String symbol, {
    String interval = '1m',
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get(
        'https://api.binance.com/api/v3/klines',
        queryParameters: {
          'symbol': symbol.toUpperCase(),
          'interval': interval,
          'limit': limit,
        },
      );

      final List<dynamic> data = response.data;
      return data.map((e) => KlineData.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load klines: $e');
    }
  }
}
