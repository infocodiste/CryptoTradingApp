import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'all_cryptos.dart';

class PriceText extends StatefulWidget {
  final String id;
  final double fontSize;
  final Map<String, dynamic> data;
  final String symbol;
  final num exchangeRate;

  PriceText(this.id, this.data, this.symbol, this.exchangeRate,
      {this.fontSize = 20});

  @override
  _PriceTextState createState() => _PriceTextState();
}

class _PriceTextState extends State<PriceText> {
  Color changeColor;
  Timer updateTimer;
  bool disp = false;
  ValueNotifier<num> coinNotif;

  void update() {
    if (widget.data["priceUsd"].compareTo(coinNotif.value) > 0) {
      changeColor = Colors.green;
    } else {
      changeColor = Colors.red;
    }
    setState(() {});
    updateTimer?.cancel();
    updateTimer = Timer(Duration(milliseconds: 400), () {
      if (disp) {
        return;
      }
      setState(() {
        changeColor = null;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    coinNotif = valueNotifiers[widget.id];
    coinNotif.addListener(update);
  }

  @override
  void dispose() {
    super.dispose();
    disp = true;
    coinNotif.removeListener(update);
  }

  @override
  Widget build(BuildContext context) {
    num price = widget.data["priceUsd"] * widget.exchangeRate;
    return Text(
        price >= 0
            ? NumberFormat.currency(
                    symbol: widget.symbol,
                    decimalDigits: price > 1
                        ? price < 100000
                            ? 2
                            : 0
                        : price > .000001
                            ? 6
                            : 7)
                .format(price)
            : "N/A",
        style: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: FontWeight.w500,
            color: changeColor));
  }
}
