import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:live_cryptocurrency_streaming_app/model/coin.dart';
import 'package:live_cryptocurrency_streaming_app/view/widgets/custom_text.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:intl/intl.dart' as intl;

import '../../provider/coin_provider.dart';

class CoinGraph extends StatefulWidget {
  final CoinUpdates coinUpdates;

  const CoinGraph({super.key, required this.coinUpdates});

  @override
  State<CoinGraph> createState() => _CoinGraphState();
}

class _CoinGraphState extends State<CoinGraph> {
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
      padding: const EdgeInsets.all(14),
      // height: 500,
      decoration: BoxDecoration(
        // color: Colors.black,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: queue.isEmpty
            ? Material(
                color: Colors.transparent,
                child: Center(
                  key: UniqueKey(),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 24,
                      ),
                      CustomText(text: 'Waiting for coin data...')
                    ],
                  ),
                ),
              )
            : Card(
                color: Colors.black,
                child: Column(
                  key: ValueKey(coinName),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.coinUpdates.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
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
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SfCartesianChart(
                        borderColor: Colors.red,
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
