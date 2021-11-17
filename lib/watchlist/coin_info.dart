import 'dart:async';
import 'dart:convert';

import 'package:coin_analyzer/utils/misc/credential_manager.dart';
import 'package:coin_analyzer/watchlist/coin_exchange.dart';
import 'package:coin_analyzer/widget/fiat_ramp_card.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:coin_analyzer/watchlist/price_text.dart';
import 'package:url_launcher/url_launcher.dart';

import 'all_cryptos.dart';
import 'simple_time_series_chart.dart';

class CoinInfo extends StatefulWidget {
  final String id;
  final String userAddress;
  final Map<String, dynamic> data;
  final String symbol;
  final num exchangeRate;

  CoinInfo(
      this.id, this.userAddress, this.data, this.symbol, this.exchangeRate);

  @override
  _CoinInfoState createState() => _CoinInfoState();
}

class _CoinInfoState extends State<CoinInfo> {
  String tokenAddress;
  String website;
  String address;

  @override
  void initState() {
    super.initState();
    getTokenDetails();
  }

  getTokenDetails() async {
    address = await CredentialManager.getAddress();

    Map<String, dynamic> responseData;
    http.Response response;

    response = await http.get(Uri.parse(
        "https://pro-api.coinmarketcap.com/v1/cryptocurrency/info?CMC_PRO_API_KEY=e6a0a002-3742-4c39-8faa-0c8800812346&symbol=${"${widget.data["symbol"]}".toLowerCase()}"));

    print("Response : ${response.body}");

    responseData = json.decode(response.body)["data"];

    print("responseData : $responseData");
    Map<String, dynamic> tokenData =
        responseData["${widget.data["symbol"]}".toUpperCase()];
    print("Token : $tokenData");

    Map<String, dynamic> urlData = tokenData['urls'];
    if (urlData != null && urlData["website"] != null) {
      website = (urlData["website"] as List)[0];
      print("Website : $website");
    }

    Map<String, dynamic> platformData = tokenData['platform'];
    print("platformData : $platformData");
    if (platformData != null) {
      tokenAddress = "${platformData["token_address"]}";
      print("Token : $tokenAddress");
    }

    if (tokenAddress == null || tokenAddress.isEmpty) {
      response = await http.get(Uri.parse(
          "https://api1.poocoin.app/tokens?search=${"${widget.data["symbol"]}".toLowerCase()}"));
      if (response != null && response.statusCode == 200) {
        responseData = (json.decode(response.body) as List)[0];
        print("responseData : $responseData");
        tokenAddress = "${responseData["address"]}";
        print("Token : $tokenAddress");
      }
    }
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    num change = widget.data["changePercent24Hr"];

    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Theme.of(context).primaryColorLight,
            title: Text(widget.data["name"]),
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
        body: ListView(physics: ClampingScrollPhysics(), children: [
          DefaultTabController(
            length: 5,
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50))),
              child: Column(
                children: [
                  Container(
                      height: size.height * 0.4,
                      child: TabBarView(
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            SimpleTimeSeriesChart(widget.id, 1, "m5"),
                            SimpleTimeSeriesChart(widget.id, 7, "m30"),
                            SimpleTimeSeriesChart(widget.id, 30, "h2"),
                            SimpleTimeSeriesChart(widget.id, 182, "h12"),
                            SimpleTimeSeriesChart(widget.id, 364, "d1")
                          ])),
                  Container(height: 8.0),
                  Container(
                      padding: EdgeInsets.only(left: 24, right: 24),
                      child: TabBar(
                          indicatorSize: TabBarIndicatorSize.label,
                          tabs: [
                            Tab(
                                icon: AutoSizeText("1D",
                                    maxFontSize: 20.0,
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                    minFontSize: 0.0)),
                            Tab(
                                icon: AutoSizeText("1W",
                                    maxFontSize: 20.0,
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                    minFontSize: 0.0)),
                            Tab(
                                icon: AutoSizeText("1M",
                                    maxFontSize: 20.0,
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                    minFontSize: 0.0)),
                            Tab(
                                icon: AutoSizeText("6M",
                                    maxFontSize: 20.0,
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                    minFontSize: 0.0)),
                            Tab(
                                icon: AutoSizeText("1Y",
                                    maxFontSize: 20.0,
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                    minFontSize: 0.0))
                          ])),
                ],
              ),
            ),
          ),
          Divider(height: 16, color: Colors.transparent),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: IconButton(
                    icon: Icon(
                      Icons.language,
                      size: 32,
                    ),
                    onPressed: () {
                      _launchUrl(website);
                    },
                  )),
                  Column(
                    children: [
                      PriceText(widget.id, widget.data, widget.symbol,
                          widget.exchangeRate,
                          fontSize: 32),
                      Divider(height: 8, color: Colors.transparent),
                      change != -1000000.0
                          ? Text(
                              ((change >= 0) ? "+" : "") +
                                  change.toStringAsFixed(3) +
                                  "\%",
                              style: TextStyle(
                                  color: ((change >= 0)
                                      ? Colors.green
                                      : Colors.red)))
                          : Text("N/A"),
                    ],
                  ),
                  Expanded(
                      child: IconButton(
                    icon: Icon(
                      Icons.sync_alt,
                      size: 32,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CoinExchanger(
                                  widget.id,
                                  widget.userAddress,
                                  widget.data,
                                  widget.symbol,
                                  widget.exchangeRate)));
                    },
                  ))
                ],
              ),
              Divider(
                  height: 8,
                  color: Theme.of(context).primaryColorLight,
                  thickness: 1),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Info("Total Supply", widget.id, "supply", widget.symbol,
                            widget.data),
                        Info("Market Cap", widget.id, "marketCapUsd",
                            widget.symbol, widget.data,
                            crossAxisAlignment: CrossAxisAlignment.end),
                      ],
                    ),
                  ),
                  // Info("Price", widget.id, "priceUsd")
                  // Info("24h Change", widget.id, "changePercent24Hr"),
                  Divider(
                      height: 8,
                      color: Theme.of(context).primaryColorLight,
                      thickness: 1),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Info("24h Volume", widget.id, "volumeUsd24Hr",
                            widget.symbol, widget.data),
                        Info("Max Supply", widget.id, "maxSupply",
                            widget.symbol, widget.data,
                            crossAxisAlignment: CrossAxisAlignment.end),
                      ],
                    ),
                  ),
                  Divider(
                      height: 8,
                      color: Theme.of(context).primaryColorLight,
                      thickness: 1),
                  InkWell(
                    onTap: () {
                      String url = "https://bscscan.com/token/$tokenAddress";
                      _launchUrl(url);
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Text("${widget.data["symbol"]} Transactions",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  Divider(
                      height: 8,
                      color: Theme.of(context).primaryColorLight,
                      thickness: 1),
                  InkWell(
                    onTap: () {
                      String url =
                          "https://bscscan.com/address/$tokenAddress#code";
                      _launchUrl(url);
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Text("${widget.data["symbol"]} Contracts",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  Divider(
                      height: 8,
                      color: Theme.of(context).primaryColorLight,
                      thickness: 1),
                  InkWell(
                    onTap: () {
                      String url =
                          "https://bscscan.com/token/$tokenAddress#balances";
                      _launchUrl(url);
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Text("${widget.data["symbol"]} Holders",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  Divider(
                      height: 8,
                      color: Theme.of(context).primaryColorLight,
                      thickness: 1),
                ],
              ),
            ],
          ),
          FiatOnRampCard(
              userAddress: address,
              crypto: widget.data["name"],
              symbol: widget.data["symbol"])
        ]));
  }

  _launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class Info extends StatefulWidget {
  final String title, ticker, id, symbol;
  final Map<String, dynamic> data;
  final CrossAxisAlignment crossAxisAlignment;

  Info(this.title, this.ticker, this.id, this.symbol, this.data,
      {this.crossAxisAlignment = CrossAxisAlignment.start});

  @override
  _InfoState createState() => _InfoState();
}

class _InfoState extends State<Info> {
  dynamic value;

  // ValueNotifier<num> coinNotif;

  Color textColor;

  Timer updateTimer;

  bool disp = false;

  // void update() {
  //   if (widget.data["priceUsd"].compareTo(coinNotif.value) > 0) {
  //     textColor = Colors.green;
  //   } else {
  //     textColor = Colors.red;
  //   }
  //   setState(() {});
  //   updateTimer?.cancel();
  //   updateTimer = Timer(Duration(milliseconds: 400), () {
  //     if (disp) {
  //       return;
  //     }
  //     setState(() {
  //       textColor = null;
  //     });
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // if (widget.id == "priceUsd") {
    //   coinNotif = valueNotifiers[widget.ticker];
    //   coinNotif.addListener(update);
    // } else {
    //   textColor = Colors.white;
    // }
  }

  @override
  void dispose() {
    super.dispose();
    // if (widget.id == "priceUsd") {
    //   disp = true;
    //   coinNotif.removeListener(update);
    // }
  }

  @override
  Widget build(BuildContext context) {
    dynamic value = widget.data[widget.id];
    String text;
    if ((widget.id == "changePercent24Hr" && value == -1000000) ||
        value == null ||
        value == -1) {
      text = "N/A";
    } else {
      NumberFormat formatter;
      if (widget.id == "priceUsd") {
        formatter = NumberFormat.currency(
            symbol: widget.symbol,
            decimalDigits: value > 1
                ? value < 100000
                    ? 2
                    : 0
                : value > .000001
                    ? 6
                    : 7);
      } else if (widget.id == "marketCapUsd") {
        formatter = NumberFormat.currency(
            symbol: widget.symbol, decimalDigits: value > 1 ? 0 : 2);
      } else if (widget.id == "changePercent24Hr") {
        formatter = NumberFormat.currency(symbol: "", decimalDigits: 3);
      } else {
        formatter = NumberFormat.currency(symbol: "", decimalDigits: 0);
      }
      text = formatter.format(value);
    }
    if (widget.id == "changePercent24Hr" && value != -1000000) {
      text += "%";
      text = (value > 0 ? "+" : "") + text;
      textColor = value < 0
          ? Colors.red
          : value > 0
              ? Colors.green
              : Theme.of(context).primaryColorLight;
    }
    return Container(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: widget.crossAxisAlignment,
          children: [
            Text("${widget.title}",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            SizedBox(width: 4),
            ConstrainedBox(
              child: AutoSizeText(text,
                  minFontSize: 0,
                  maxFontSize: 17,
                  style: TextStyle(
                      fontSize: 17,
                      color: textColor,
                      fontWeight: FontWeight.w300),
                  maxLines: 1),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 2 - 8),
            )
          ],
        ));
  }
}
