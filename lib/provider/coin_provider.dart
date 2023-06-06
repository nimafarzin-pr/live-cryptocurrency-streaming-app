import 'package:flutter/material.dart';
import 'package:live_cryptocurrency_streaming_app/model/coin.dart';

class CoinUpdates extends ChangeNotifier {
  CoinUpdates({required this.name});
  final String name;

  Coin? _coin;

  Coin? get coin => _coin;
  updateCoin(value) {
    _coin = value;
    notifyListeners();
  }
}
