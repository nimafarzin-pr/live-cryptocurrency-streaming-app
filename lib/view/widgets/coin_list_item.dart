import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:live_cryptocurrency_streaming_app/model/coin.dart';
import 'package:chart_sparkline/chart_sparkline.dart';

import '../../provider/coin_provider.dart';
import 'custom_text.dart';

class CoinListItem extends StatefulWidget {
  final CoinUpdates coinUpdates;

  final Function()? onTap;

  const CoinListItem({super.key, required this.coinUpdates, this.onTap});

  @override
  State<CoinListItem> createState() => _CoinListItemState();
}

class _CoinListItemState extends State<CoinListItem> {
  Queue<double> queue = Queue();
  Queue<Coin> coin = Queue();
  String coinName = '';

  VoidCallback _listener = () {};

  @override
  void initState() {
    widget.coinUpdates.addListener(
      _listener = () {
        setState(() {
          queue.add(widget.coinUpdates.coin!.price!);
          coin.add(widget.coinUpdates.coin!);
        });

        if (queue.length > 100) {
          queue.removeFirst();
          coin.removeFirst();
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
      padding: const EdgeInsets.symmetric(horizontal: 14),
      // height: 500,
      decoration: BoxDecoration(
          // color: const Color(0xffEDEDED).withOpacity(0.05),
          borderRadius: BorderRadius.circular(8.0)),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: queue.isEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 14.0),
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
            : Padding(
                padding: const EdgeInsets.only(top: 14.0),
                child: Item(
                  onTap: widget.onTap,
                  data: queue.toList(),
                  item: coin.toList().last,
                  name: widget.coinUpdates.name,
                  price: widget.coinUpdates.coin!.price!.toStringAsFixed(2),
                  preItem: coin.toList().first,
                ),
              ),
      ),
    );
  }
}

class Item extends StatelessWidget {
  const Item(
      {super.key,
      required this.item,
      required this.name,
      required this.preItem,
      required this.data,
      required this.price,
      this.onTap});
  final String name;

  final Coin item;
  final List<double> data;
  final Coin preItem;
  final String price;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final percentageChange = double.parse(
        (((item.price! - preItem.price!) / preItem.price!) * 100)
            .toStringAsFixed(2));

    final percentChangeColor =
        percentageChange.isNegative ? Colors.red : Colors.green;
    final changeIcon = percentageChange.isNegative
        ? Icons.arrow_drop_down
        : Icons.arrow_drop_up;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), //<-- SEE HERE
      ),
      color: const Color(0xff27374d),
      child: ListTile(
        onTap: () {
          if (onTap != null) {
            onTap!();
          }
        },
        title: Row(
          children: [
            CustomText(
              fontSize: 18,
              color: Colors.white,
              text: name,
            ),
            Row(
              children: [
                Icon(
                  changeIcon,
                  color: percentChangeColor,
                  size: 30,
                ),
                CustomText(
                  text: '$percentageChange %',
                  color: percentChangeColor,
                ),
              ],
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: price.toString(),
              fontSize: 12,
              color: Colors.white,
            ),
            const SizedBox(
              height: 10,
            ),
            CustomText(
              text: item.dateTime!.toLocal().toString(),
              color: Colors.grey,
            ),
          ],
        ),
        trailing: SizedBox(
          // width: ,
          height: 40,
          child: FittedBox(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Sparkline(
                  fillMode: FillMode.below,
                  fillColor: Colors.transparent,
                  data: data,
                ),
              ],
            ),
          ),
        ),
        // leading: CircleAvatar(
        //   radius: 30,
        //   backgroundColor: Colors.blue.withOpacity(0.5),
        //   child: Center(
        //     child: Padding(
        //       padding: const EdgeInsets.all(0.0),
        //       child: CustomText(
        //         fontSize: 20,
        //         enableCenter: true,
        //         fontWeight: FontWeight.bold,
        //         text: name.characters.first,
        //         color: Colors.white,
        //       ),
        //     ),
        //   ),
        // ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        titleAlignment: ListTileTitleAlignment.center,
        splashColor: Colors.white,
        isThreeLine: true,
        minLeadingWidth: 60,
        subtitleTextStyle: const TextStyle(fontSize: 10),
        contentPadding: const EdgeInsets.all(10),
        titleTextStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}
