import 'package:hive_flutter/hive_flutter.dart';
import '../models/position.dart';

class PositionService {
  final Box<Position> _box = Hive.box<Position>('positions');

  List<Position> getPositions() {
    return _box.values.toList();
  }

  Future<void> openPosition(Position position) async {
    await _box.put(position.id, position);
  }

  Future<void> closePosition(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAllPositions() async {
    await _box.clear();
  }

  Position? getPositionById(String id) {
    return _box.get(id);
  }
}
