import 'package:flutter/material.dart';
import 'package:live_cryptocurrency_streaming_app/main.dart';
import 'package:live_cryptocurrency_streaming_app/view/widgets/loading_container.dart';

import 'package:ably_flutter/ably_flutter.dart' as ably;

import '../provider/coin_provider.dart';
import '../service/ably_service.dart';
import 'widgets/coin_graph_item.dart';

class GraphList extends StatefulWidget {
  const GraphList({super.key});

  @override
  State<GraphList> createState() => _GraphListState();
}

class _GraphListState extends State<GraphList> {
  List<CoinUpdates> prices = [];

  @override
  void initState() {
    prices = getIt<AblyService>().getCoinUpdates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ably.ConnectionStateChange>(
      // As we are behind the FutureBuilder we can safely access AblyService
      stream: getIt<AblyService>().connection,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingContainer();
        } else if (snapshot.data?.event == ably.ConnectionEvent.connected) {
          // return the list of graphs,
          return SingleChildScrollView(
            child: Column(
              children: [
                for (CoinUpdates update in prices)
                  CoinGraphItem(coinUpdates: update),
              ],

              // see section below
            ),
          );
        } else if (snapshot.data?.event == ably.ConnectionEvent.failed) {
          return const Center(child: Text("No connection."));
        } else {
          // In a real app we would also add handling of possible errors
          return const LoadingContainer();
        }
      },
    );
  }
}
