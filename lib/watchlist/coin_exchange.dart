import "dart:async";
import "dart:collection";
import "dart:convert";
import 'package:coin_analyzer/watchlist/coin_markets_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'all_cryptos.dart';

class CoinExchanger extends StatefulWidget {
  final String id;
  final String address;
  final Map<String, dynamic> data;
  final String symbol;
  final num exchangeRate;

  CoinExchanger(
      this.id, this.address, this.data, this.symbol, this.exchangeRate);

  @override
  _CoinExchangerState createState() => _CoinExchangerState();
}

class _CoinExchangerState extends State<CoinExchanger> {
  bool _loading = false;
  List<Data> marketData;

  Future<dynamic> _apiGet(String link) async {
    return json.decode((await http.get(Uri.parse("$api$link"))).body);
  }

  getExchangeValues() async {
    _loading = true;
    setState(() {});
    var data = (await _apiGet("assets/${widget.data["id"]}/markets"));
    var response = CoinMarketsResponse.fromJson(data);
    marketData = response.data;
    _loading = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getExchangeValues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).backgroundColor,
          title: Text("Exchangers"),
          centerTitle: true,
          actions: [
            Row(children: [
              FadeInImage(
                image: NetworkImage(
                    "https://static.coincap.io/assets/icons/${widget.data["symbol"].toLowerCase()}@2x.png"),
                placeholder: AssetImage("assets/icon.png"),
                fadeInDuration: const Duration(milliseconds: 100),
                height: 32.0,
                width: 32.0,
              ),
              Text(" " + widget.data["symbol"]),
              Container(width: 5.0)
            ])
          ]),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                      padding: EdgeInsets.all(4),
                      alignment: Alignment.center,
                      child: Text(
                        "Source (Market)",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )),
                ),
                Expanded(
                  child: Container(
                      padding: EdgeInsets.only(right: 16),
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Price",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Divider(height: 4, color: Colors.transparent),
                          Text(
                            "Volume(%)",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.normal),
                          )
                        ],
                      )),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white),
          Expanded(
              child: !_loading
                  ? Scrollbar(
                      child: marketData != null && marketData.length > 0
                          ? ListView.separated(
                              separatorBuilder: (context, i) {
                                return Divider(color: Colors.transparent);
                              },
                              itemBuilder: (context, i) => Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                        color:
                                            Theme.of(context).primaryColorLight,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(24),
                                            bottomRight: Radius.circular(24))),
                                    child: ListTile(
                                        contentPadding: EdgeInsets.only(
                                            left: 16,
                                            right: 16,
                                            top: 8,
                                            bottom: 8),
                                        title: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    marketData[i].exchangeId,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Divider(
                                                      height: 8,
                                                      color:
                                                          Colors.transparent),
                                                  Text(
                                                      "${marketData[i].baseSymbol} / ${marketData[i].quoteSymbol}"),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                      "${getNumberFormatter("price", marketData[i].priceUsd)}"),
                                                  // Text(
                                                  //     "\$${getNumberFormatter("volume24Hr", marketData[i].volumeUsd24Hr)}"),
                                                  Divider(
                                                      height: 8,
                                                      color:
                                                          Colors.transparent),
                                                  Text(
                                                      "${getNumberFormatter("volumePercent24Hr", marketData[i].volumePercent)} %"),
                                                ],
                                              ),
                                            )
                                          ],
                                        )),
                                  ),
                              itemCount: marketData.length)
                          : Container())
                  : Container())
        ],
      ),
    );
  }

  String getNumberFormatter(String type, String valuee) {
    NumberFormat formatter;
    double value = double.parse(valuee);
    if (type == "price") {
      formatter = NumberFormat.currency(
          symbol: widget.symbol,
          decimalDigits: value > 1
              ? value < 100000
                  ? 2
                  : 0
              : value > .000001
                  ? 6
                  : 7);
    } else if (type == "volume24Hr") {
      formatter = NumberFormat.currency(
          symbol: widget.symbol, decimalDigits: value > 1 ? 0 : 2);
    } else if (type == "volumePercent24Hr") {
      formatter = NumberFormat.currency(symbol: "", decimalDigits: 3);
    } else {
      formatter = NumberFormat.currency(symbol: "", decimalDigits: 0);
    }
    return formatter.format(value);
  }
}
