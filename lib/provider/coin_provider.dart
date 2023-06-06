import 'package:flutter/material.dart';
import 'package:live_cryptocurrency_streaming_app/model/coin.dart';

// import 'package:live_cryptocurrency_streaming_app/injector.dart';

// import '../../domain/usecases/liva_data_usecase.dart';

class CoinUpdates extends ChangeNotifier {
  // final req = getIt<LiveDataUseCase>();

  CoinUpdates({required this.name});
  final String name;

  Coin? _coin;

  Coin? get coin => _coin;
  updateCoin(value) {
    _coin = value;
    notifyListeners();
  }
}
