import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/position.dart';
import '../../../shared/services/position_service.dart';

// Service provider
final positionServiceProvider = Provider<PositionService>((ref) {
  return PositionService();
});

// Notifier exposing list of positions
class PositionsNotifier extends Notifier<List<Position>> {
  late final PositionService _service;

  @override
  List<Position> build() {
    _service = ref.watch(positionServiceProvider);
    return _service.getPositions();
  }

  Future<void> open(Position position) async {
    await _service.openPosition(position);
    state = _service.getPositions(); // Refresh state
  }

  Future<void> close(String id) async {
    await _service.closePosition(id);
    state = _service.getPositions(); // Refresh state
  }
}

final positionsProvider = NotifierProvider<PositionsNotifier, List<Position>>(
  PositionsNotifier.new,
);
