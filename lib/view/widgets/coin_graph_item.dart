import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:live_cryptocurrency_streaming_app/model/coin.dart';
// import 'package:live_cryptocurrency_streaming_app/features/liveCoinData/presentation/provider/coin_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// import '../../data/model/coin.dart';
import 'package:intl/intl.dart' as intl;

import '../../provider/coin_provider.dart';

class CoinGraphItem extends StatefulWidget {
  final CoinUpdates coinUpdates;

  const CoinGraphItem({super.key, required this.coinUpdates});

  @override
  State<CoinGraphItem> createState() => _CoinGraphItemState();
}

class _CoinGraphItemState extends State<CoinGraphItem> {
  Queue<Coin> queue = Queue();
  String coinName = '';

  VoidCallback _listener = () {};

  @override
  void initState() {
    widget.coinUpdates.addListener(
      _listener = () {
        setState(() {
          queue.add(widget.coinUpdates.coin!);
        });

        if (queue.length > 100) {
          queue.removeFirst();
        }
      },
    );

    if (coinName.isEmpty) coinName = widget.coinUpdates.name;

    super.initState();
  }

  @override
  void dispose() {
    widget.coinUpdates.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      height: 300,
      decoration: BoxDecoration(
          color: const Color(0xffEDEDED).withOpacity(0.05),
          borderRadius: BorderRadius.circular(8.0)),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: queue.isEmpty
            ? Center(
                key: UniqueKey(),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 24,
                    ),
                    Text('Waiting for coin data...')
                  ],
                ),
              )
            : Card(
                color: Colors.black,
                child: Column(
                  key: ValueKey(coinName),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        widget.coinUpdates.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              "\$${widget.coinUpdates.coin?.price?.toStringAsFixed(2)}",
                              key: ValueKey(widget.coinUpdates.coin?.price),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SfCartesianChart(
                        enableAxisAnimation: true,
                        primaryXAxis: DateTimeAxis(
                          dateFormat: intl.DateFormat.Hms(),
                          intervalType: DateTimeIntervalType.minutes,
                          desiredIntervals: 10,
                          axisLine:
                              const AxisLine(width: 2, color: Colors.white),
                          majorTickLines:
                              const MajorTickLines(color: Colors.transparent),
                        ),
                        primaryYAxis: NumericAxis(
                          numberFormat: intl.NumberFormat('##,###.00'),
                          desiredIntervals: 5,
                          decimalPlaces: 2,
                          axisLine:
                              const AxisLine(width: 2, color: Colors.white),
                          majorTickLines:
                              const MajorTickLines(color: Colors.red),
                        ),
                        plotAreaBorderColor: Colors.white.withOpacity(0.2),
                        plotAreaBorderWidth: 0.2,
                        series: <LineSeries<Coin, DateTime>>[
                          LineSeries<Coin, DateTime>(
                            animationDuration: 0.0,
                            width: 2,
                            color: Theme.of(context).primaryColor,
                            dataSource: queue.toList(),
                            xValueMapper: (Coin coin, _) => coin.dateTime,
                            yValueMapper: (Coin coin, _) => coin.price,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
