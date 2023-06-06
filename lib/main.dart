import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:live_cryptocurrency_streaming_app/service/ably_service.dart';
import 'package:live_cryptocurrency_streaming_app/view/dashboard.dart';

GetIt getIt = GetIt.instance;

void main() {
  getIt.registerSingletonAsync<AblyService>(() => AblyService.init());
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    ),
  );
}
