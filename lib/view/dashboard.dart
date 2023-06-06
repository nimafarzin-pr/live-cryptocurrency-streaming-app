import 'package:flutter/material.dart';
import 'package:live_cryptocurrency_streaming_app/view/widgets/loading_container.dart';

import '../main.dart';
import 'graph_list.dart';
// import 'package:live_cryptocurrency_streaming_app/features/liveCoinData/presentation/graph_list.dart';
// import 'package:live_cryptocurrency_streaming_app/features/liveCoinData/presentation/widgets/loading_container.dart';

// import '../../../injector.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text(
          "Live cryptocurrency",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.white,
            height: 1.0,
          ),
        ),
      ),
      body: FutureBuilder(
        future: getIt.allReady(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingContainer();
          } else {
            return const GraphList();
          }
        },
      ),
    );
  }
}
