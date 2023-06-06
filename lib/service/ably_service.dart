import 'package:ably_flutter/ably_flutter.dart' as ably;

import '../../../../../core/config.dart';
import '../../model/coin.dart';
import '../provider/coin_provider.dart';

const List<Map> _coinTypes = [
  {
    "name": "Bitcoin",
    "code": "btc",
  },
  {
    "name": "Ethereum",
    "code": "eth",
  },
  {
    "name": "Ripple",
    "code": "xrp",
  },
];

class AblyService {
  final ably.Realtime _realtime;
  AblyService._(this._realtime);

  static Future<AblyService> init() async {
    /// initialize client options for your Ably account using your private API
    /// key
    final ably.ClientOptions clientOptions =
        ably.ClientOptions(key: ablyAPIKey);

    /// initialize real-time object with the client options
    final realtime = ably.Realtime(options: clientOptions);

    /// connect the app to Ably's Realtime services supported by this SDK
    await realtime.connect();

    /// return the single instance of AblyService with the local _realtime
    /// instance to
    /// be set as the value of the service's _realtime property, so it can be
    /// used in all methods.
    return AblyService._(realtime);
  }

  final List<CoinUpdates> _coinUpdates = [];

  List<CoinUpdates> getCoinUpdates() {
    if (_coinUpdates.isEmpty) {
      for (int i = 0; i < _coinTypes.length; i++) {
        String coinName = _coinTypes[i]['name'];
        String coinCode = _coinTypes[i]['code'];

        _coinUpdates.add(CoinUpdates(name: coinName));

        //launch a channel for each coin type
        ably.RealtimeChannel channel = _realtime.channels
            .get('[product:ably-coindesk/crypto-pricing]$coinCode:usd');

        //subscribe to receive a Dart Stream that emits the channel messages
        final Stream<ably.Message> messageStream = channel.subscribe();

        //map each stream event to a Coin and listen to updates
        messageStream.where((event) => event.data != null).listen((message) {
          print(message);
          _coinUpdates[i].updateCoin(
            Coin(
              code: coinCode,
              price: double.parse('${message.data}'),
              dateTime: message.timestamp,
            ),
          );
        });
      }
    }
    return _coinUpdates;
  }

  Stream<ably.ConnectionStateChange> get connection =>
      _realtime.connection.on();
}
