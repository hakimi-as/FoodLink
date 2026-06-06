import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/stats_service.dart';

class StatsProvider extends ChangeNotifier {
  final StatsService _service = StatsService();
  StreamSubscription<int>? _sub;

  int _mealsClaimed = 0;

  int get mealsClaimed => _mealsClaimed;
  int get kgSaved => (_mealsClaimed * 0.5).round();
  int get co2Saved => (_mealsClaimed * 1.25).round();

  void startListening() {
    _sub?.cancel();
    _sub = _service.listenMealsClaimed().listen((v) {
      _mealsClaimed = v;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
