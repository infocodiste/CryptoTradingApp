import "dart:async";
import "dart:collection";
import "dart:convert";

import "package:auto_size_text/auto_size_text.dart";
import 'package:coin_analyzer/utils/misc/box.dart';
import 'package:coin_analyzer/utils/misc/credential_manager.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import "package:flutter_svg/flutter_svg.dart";
import "package:http/http.dart" as http;
import "package:local_database/local_database.dart";
import "package:path_provider/path_provider.dart";
import "package:web_socket_channel/io.dart";

import '../constants.dart';
import 'coin_info.dart';
import "key.dart";
import 'price_text.dart';

String api = "https://api.coincap.io/v2/";
HashMap<String, Map<String, dynamic>> _coinData;
HashMap<String, Map<String, dynamic>> _searchCoinData;
HashMap<String, ValueNotifier<num>> valueNotifiers =
    HashMap<String, ValueNotifier<num>>();
List<String> _savedCoins = [];
Database _userData;
Map<String, dynamic> _settings;
String _symbol;

LinkedHashSet<String> _supportedCurrencies = LinkedHashSet.from([
  "USD",
  "AUD",
  "BGN",
  "BRL",
  "CAD",
  "CHF",
  "CNY",
  "CZK",
  "DKK",
  "EUR",
  "GBP",
  "HKD",
  "HRK",
  "HUF",
  "IDR",
  "ILS",
  "INR",
  "ISK",
  "JPY",
  "KRW",
  "MXN",
  "MYR",
  "NOK",
  "NZD",
  "PHP",
  "PLN",
  "RON",
  "RUB",
  "SEK",
  "SGD",
  "THB",
  "TRY",
  "ZAR"
]);

Map<String, dynamic> _conversionMap;
num _exchangeRate;

bool _loading = false;

Future<dynamic> _apiGet(String link) async {
  return json.decode((await http.get(Uri.parse("$api$link"))).body);
}

void _changeCurrency(String currency) {
  var conversionData = _conversionMap[_settings["currency"]];
  _exchangeRate = conversionData["rate"];
  _symbol = conversionData["symbol"];
  _userData["exchangeRate"] = _exchangeRate;
  _userData["symbol"] = _symbol;
}

String sortingBy;

class AllCrypto extends StatefulWidget {
  final bool savedPage;

  AllCrypto(this.savedPage) : super(key: ValueKey(savedPage));

  @override
  _AllCryptoState createState() => _AllCryptoState();
}

typedef SortType(String s1, String s2);

SortType sortBy(String s) {
  String sortVal = s.substring(0, s.length - 1);
  bool ascending = s.substring(s.length - 1).toLowerCase() == "a";
  return (s1, s2) {
    if (s == "custom") {
      return _savedCoins.indexOf(s1) - _savedCoins.indexOf(s2);
    }
    Map<String, Comparable> m1 = _coinData[ascending ? s1 : s2],
        m2 = _coinData[ascending ? s2 : s1];
    dynamic v1 = m1[sortVal], v2 = m2[sortVal];
    if (sortVal == "name") {
      v1 = v1.toUpperCase();
      v2 = v2.toUpperCase();
    }
    int comp = v1.compareTo(v2);
    if (comp == 0) {
      return sortBy("nameA")(s1, s2) as int;
    }
    return comp;
  };
}

class _AllCryptoState extends State<AllCrypto> {
  bool searching = false;

  List<String> sortedKeys;

  void reset() {
    if (widget.savedPage) {
      sortedKeys = List.from(_savedCoins)..sort(sortBy(sortingBy));
    } else {
      sortedKeys = List.from(_coinData.keys)..sort(sortBy(sortingBy));
    }
    setState(() {});
  }

  void search(String s) async {
    scrollController.jumpTo(0.0);
    reset();
    moving = false;
    moveWith = null;
    for (int i = 0; i < sortedKeys.length; i++) {
      String key = sortedKeys[i];
      String name = _coinData[key]["name"];
      String ticker = _coinData[key]["symbol"];
      if (![name, ticker]
          .any((w) => w.toLowerCase().contains(s.toLowerCase()))) {
        sortedKeys.removeAt(i--);
      }
    }
    if (sortedKeys.length > 0) {
      setState(() {});
    } else if (!widget.savedPage) {
      //search from server
      // https://api.coincap.io/v2/assets?search=ETH
      _loading = true;
      setState(() {});
      _searchCoinData = HashMap<String, Map<String, Comparable>>();
      var searchToken = s;
      if (s != null && s.isNotEmpty && s.startsWith("0x") && s.length == 42) {
        var response = await http
            .get(Uri.parse("https://api1.poocoin.app/tokens?search=$s"));
        if (response != null && response.statusCode == 200) {
          var responseData = (json.decode(response.body) as List)[0];
          print("responseData : $responseData");
          searchToken = "${responseData["symbol"]}";
          print("Token : $searchToken");
        }
      }

      var data = (await _apiGet("assets?search=$searchToken"))["data"];
      data.forEach((e) {
        String id = e["id"];
        _searchCoinData[id] = e.cast<String, Comparable>();
        valueNotifiers[id] = ValueNotifier(0);
        for (String s in e.keys) {
          if (e[s] == null) {
            e[s] = (s == "changePercent24Hr" ? -1000000 : -1);
          } else if (!["id", "symbol", "name"].contains(s)) {
            e[s] = num.parse(e[s], (e) => null);
          }
        }
      });
      sortedKeys = List.from(_searchCoinData.keys)..sort(sortBy(sortingBy));
      _loading = false;
      setState(() {});
    }
  }

  void sort(String s) {
    scrollController.jumpTo(0.0);
    moving = false;
    moveWith = null;
    sortingBy = s;
    setState(() {
      sortedKeys.sort(sortBy(s));
    });
  }

  @override
  void initState() {
    super.initState();
    sortingBy = widget.savedPage ? "custom" : "marketCapUsdD";
    setUpData();
  }

  IOWebSocketChannel socket;

  Future<void> setUpData() async {
    _coinData = HashMap<String, Map<String, Comparable>>();
    _loading = true;
    setState(() {});

    _userData = Database((await getApplicationDocumentsDirectory()).path);
    _savedCoins = (await _userData["saved"])?.cast<String>() ?? [];
    _settings = await _userData["settings"];
    if (_settings == null) {
      _settings = {"disableGraphs": false, "currency": "USD"};
      _userData["settings"] = _settings;
    }
    var exchangeData = json.decode(
        (await http.get(Uri.parse("https://api.coincap.io/v2/rates")))
            .body)["data"];

    _conversionMap = HashMap();

    for (dynamic data in exchangeData) {
      String symbol = data["symbol"];
      if (_supportedCurrencies.contains(symbol)) {
        _conversionMap[symbol] = {
          "symbol": data["currencySymbol"] ?? "",
          "rate": 1 / num.parse(data["rateUsd"])
        };
      }
    }
    _userData["conversionMap"] = _conversionMap;
    _changeCurrency(_settings["currency"]);
    _coinData = HashMap<String, Map<String, Comparable>>();

    if (widget.savedPage && (_savedCoins == null || _savedCoins.isEmpty)) {
      var data = (await _apiGet("assets?limit=10"))["data"];
      data.forEach((e) {
        String id = e["id"];
        _coinData[id] = e.cast<String, Comparable>();
        valueNotifiers[id] = ValueNotifier(0);
        for (String s in e.keys) {
          if (e[s] == null) {
            e[s] = (s == "changePercent24Hr" ? -1000000 : -1);
          } else if (!["id", "symbol", "name"].contains(s)) {
            e[s] = num.parse(e[s], (e) => null);
          }
        }
        _savedCoins.add(id);
      });
      _userData["saved"] = _savedCoins;
    } else {
      var data = (await _apiGet("assets?limit=2000"))["data"];
      data.forEach((e) {
        String id = e["id"];
        _coinData[id] = e.cast<String, Comparable>();
        valueNotifiers[id] = ValueNotifier(0);
        for (String s in e.keys) {
          if (e[s] == null) {
            e[s] = (s == "changePercent24Hr" ? -1000000 : -1);
          } else if (!["id", "symbol", "name"].contains(s)) {
            e[s] = num.parse(e[s], (e) => null);
          }
        }
      });
    }

    _loading = false;
    setState(() {});
    socket?.sink?.close();
    socket =
        IOWebSocketChannel.connect("wss://ws.coincap.io/prices?assets=ALL");
    socket.stream.listen((message) {
      Map<String, dynamic> data = json.decode(message);
      data.forEach((s, v) {
        if (_coinData[s] != null) {
          num old = _coinData[s]["priceUsd"];
          _coinData[s]["priceUsd"] = num.parse(v) ?? -1;
          valueNotifiers[s].value = old;
        }
      });
    });
    reset();
  }

  Timer searchTimer;
  ScrollController scrollController = ScrollController();

  final TextEditingController searchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String userAddress = ModalRoute.of(context).settings.arguments;

    List<PopupMenuItem> l = [
      PopupMenuItem<String>(
          child: const Text("Name Ascending"), value: "nameA"),
      PopupMenuItem<String>(
          child: const Text("Name Descending"), value: "nameD"),
      PopupMenuItem<String>(
          child: const Text("Price Ascending"), value: "priceUsdA"),
      PopupMenuItem<String>(
          child: const Text("Price Descending"), value: "priceUsdD"),
      PopupMenuItem<String>(
          child: const Text("Market Cap Ascending"), value: "marketCapUsdA"),
      PopupMenuItem<String>(
          child: const Text("Market Cap Descending"), value: "marketCapUsdD"),
      PopupMenuItem<String>(
          child: const Text("24H Change Ascending"),
          value: "changePercent24HrA"),
      PopupMenuItem<String>(
          child: const Text("24H Change Descending"),
          value: "changePercent24HrD")
    ];

    Widget ret = Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        drawer: widget.savedPage
            ? Drawer(
                child: ListView(children: [
                  ListTile(
                      leading: Icon(Icons.account_balance_wallet),
                      title: Text("My Wallet",
                          style: Theme.of(context).textTheme.headline6),
                      onTap: () {
                        // Navigator.pop(context);
                        BoxUtils.checkLogin().then((bool status) {
                          if (status) {
                            Navigator.pushNamed(context, myWalletRoute);
                          } else {
                            Navigator.pushNamed(context, appLandingRoute);
                          }
                        });
                      }),
                  ListTile(
                      leading: Icon(Icons.chat),
                      title: Text("Chat on Coins/Tokens",
                          style: Theme.of(context).textTheme.headline6),
                      onTap: () {
                        Navigator.pop(context);
                        BoxUtils.checkLogin().then((bool status) {
                          if (status) {
                            Navigator.pushNamed(context, chatGroupsRoute);
                          } else {
                            Navigator.pushNamed(context, appLandingRoute);
                          }
                        });
                      }),
                  ListTile(
                      leading: Icon(Icons.settings),
                      title: Text("Settings",
                          style: Theme.of(context).textTheme.headline6),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, settingsRoute);
                      }),
                  ListTile(
                    leading: Icon(Icons.mail),
                    title: Text("Contact Us",
                        style: Theme.of(context).textTheme.headline6),
                  ),
                  ListTile(
                    leading: Icon(Icons.star),
                    title: Text("Rate Us",
                        style: Theme.of(context).textTheme.headline6),
                  )
                ]),
              )
            : null,
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          centerTitle: true,
          bottom: _loading
              ? PreferredSize(
                  preferredSize: Size(double.infinity, 3.0),
                  child:
                      Container(height: 3.0, child: LinearProgressIndicator()))
              : null,
          title: searching
              ? TextField(
                  autocorrect: false,
                  autofocus: true,
                  controller: searchTextController,
                  decoration: InputDecoration(
                      hintText: "Search", border: InputBorder.none),
                  onChanged: (s) {
                    searchTimer?.cancel();
                    searchTimer = Timer(Duration(milliseconds: 500), () {
                      search(s);
                    });
                  },
                  onSubmitted: (s) {
                    search(s);
                  })
              : Text(widget.savedPage ? "My Watch List" : "All Coins"),
          actions: [
            IconButton(
                icon: Icon(searching ? Icons.close : Icons.search),
                onPressed: () {
                  if (_loading) {
                    return;
                  }
                  setState(() {
                    if (searching) {
                      searching = false;
                      reset();
                    } else {
                      searching = true;
                    }
                  });
                }),
            // Container(
            //     width: 35.0,
            //     child: PopupMenuButton(
            //         itemBuilder: (BuildContext context) => l,
            //         child: Icon(Icons.sort),
            //         onSelected: (s) {
            //           if (_loading) {
            //             return;
            //           }
            //           sort(s);
            //         })),
            (widget.savedPage)
                ? IconButton(
                    icon: Icon(Icons.account_balance_wallet),
                    onPressed: () async {
                      BoxUtils.checkLogin().then((bool status) {
                        if (status) {
                          Navigator.pushNamed(context, myWalletRoute);
                        } else {
                          Navigator.pushNamed(context, appLandingRoute);
                        }
                      });
                    })
                : IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () async {
                      if (_loading) {
                        return;
                      }
                      searching = false;
                      sortingBy = widget.savedPage ? "custom" : "marketCapUsdD";
                      await context
                          .findAncestorStateOfType<_AllCryptoState>()
                          .setUpData();
                      reset();
                    })
          ],
          elevation: 0,
        ),
        body: !_loading
            ? Scrollbar(
                child: (widget.savedPage)
                    ? ReorderableListView.builder(
                        itemBuilder: (context, i) => Crypto(
                            sortedKeys[i], userAddress, widget.savedPage),
                        itemCount: sortedKeys.length,
                        scrollController: scrollController,
                        physics: BouncingScrollPhysics(),
                        clipBehavior: Clip.none,
                        onReorder: (int oldIndex, int newIndex) {
                          setState(() {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            final String oldID = sortedKeys.removeAt(oldIndex);
                            sortedKeys.insert(newIndex, oldID);
                            _userData["saved"] = sortedKeys;
                          });
                        },
                      )
                    : ListView.builder(
                        itemBuilder: (context, i) => Crypto(
                            sortedKeys[i], userAddress, widget.savedPage),
                        itemCount: sortedKeys.length,
                        controller: scrollController))
            : Container(),
        floatingActionButton: widget.savedPage
            ? !_loading
                ? FloatingActionButton(
                    onPressed: () {
                      moving = false;
                      moveWith = null;
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AllCrypto(false)))
                          .then((d) {
                        sortingBy = "custom";
                        searching = false;
                        reset();
                        scrollController.jumpTo(0.0);
                      });
                    },
                    child: Icon(Icons.add),
                    heroTag: "newPage")
                : null
            : FloatingActionButton(
                onPressed: () {
                  scrollController.jumpTo(0.0);
                },
                child: Icon(Icons.arrow_upward),
                heroTag: "jump"));
    if (!widget.savedPage) {
      ret = WillPopScope(
          child: ret, onWillPop: () => Future<bool>(() => !_loading));
    }
    return ret;
  }
}

bool _didImport = false;

class ImpExpPage extends StatefulWidget {
  @override
  ImpExpPageState createState() => ImpExpPageState();
}

class ImpExpPageState extends State<ImpExpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Import/Export")),
        body: Builder(
            builder: (context) => Container(
                child: Padding(
                    padding: EdgeInsets.only(top: 20.0, right: 15, left: 15),
                    child:
                        ListView(physics: ClampingScrollPhysics(), children: [
                      Card(
                        color: Colors.black12,
                        child: ListTile(
                            title: Text("Export Favorites"),
                            subtitle: Text("To your clipboard"),
                            trailing: Icon(Icons.file_upload),
                            onTap: () async {
                              await Clipboard.setData(ClipboardData(
                                  text: json.encode(_savedCoins)));
                              Scaffold.of(context).removeCurrentSnackBar();
                              Scaffold.of(context).showSnackBar(SnackBar(
                                  duration: Duration(milliseconds: 1000),
                                  content: Text("Copied to clipboard",
                                      style: TextStyle(color: Colors.white)),
                                  backgroundColor: Colors.grey[800]));
                            }),
                        margin: EdgeInsets.zero,
                      ),
                      Container(height: 20),
                      Card(
                        color: Colors.black12,
                        child: ListTile(
                            title: Text("Import Favorites"),
                            subtitle: Text("From your clipboard"),
                            trailing: Icon(Icons.file_download),
                            onTap: () async {
                              String str =
                                  (await Clipboard.getData("text/plain")).text;
                              try {
                                List<String> data =
                                    json.decode(str).cast<String>();
                                for (int i = 0; i < data.length; i++) {
                                  if (_coinData[data[i]] == null) {
                                    data.removeAt(i--);
                                  }
                                }
                                _savedCoins = data;
                                _userData["saved"] = data;
                                _didImport = true;
                                Scaffold.of(context).removeCurrentSnackBar();
                                Scaffold.of(context).showSnackBar(SnackBar(
                                    duration: Duration(milliseconds: 1000),
                                    content: Text("Imported",
                                        style: TextStyle(color: Colors.white)),
                                    backgroundColor: Colors.grey[800]));
                              } catch (e) {
                                Scaffold.of(context).removeCurrentSnackBar();
                                Scaffold.of(context).showSnackBar(SnackBar(
                                    duration: Duration(milliseconds: 1000),
                                    content: Text("Invalid data",
                                        style: TextStyle(color: Colors.white)),
                                    backgroundColor: Colors.grey[800]));
                              }
                            }),
                        margin: EdgeInsets.zero,
                      ),
                    ])))));
  }
}

class Settings extends StatefulWidget {
  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Settings",
                style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.black54),
        body: Padding(
            padding: EdgeInsets.only(top: 20.0, right: 15, left: 15),
            child: ListView(physics: ClampingScrollPhysics(), children: [
              Card(
                color: Colors.black12,
                child: ListTile(
                    title: Text("Disable 7 day graphs"),
                    subtitle: Text("More compact cards"),
                    trailing: Switch(
                        value: _settings["disableGraphs"],
                        onChanged: (disp) {
                          context
                              .findAncestorStateOfType<_AllCryptoState>()
                              .setState(() {
                            _settings["disableGraphs"] =
                                !_settings["disableGraphs"];
                          });
                          _userData["settings/disableGraphs"] =
                              _settings["disableGraphs"];
                        }),
                    onTap: () {
                      context
                          .findAncestorStateOfType<_AllCryptoState>()
                          .setState(() {
                        _settings["disableGraphs"] =
                            !_settings["disableGraphs"];
                      });
                      _userData["settings/disableGraphs"] =
                          _settings["disableGraphs"];
                    }),
                margin: EdgeInsets.zero,
              ),
              Container(height: 20),
              Card(
                color: Colors.black12,
                child: ListTile(
                    title: Text("Change Currency"),
                    subtitle: Text("33 fiat currency options"),
                    trailing: Padding(
                        child: Container(
                            color: Colors.white12,
                            padding: EdgeInsets.only(right: 7.0, left: 7.0),
                            child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                    value: _settings["currency"],
                                    onChanged: (s) {
                                      _settings["currency"] = s;
                                      _changeCurrency(s);
                                      _userData["settings/currency"] = s;
                                      context
                                          .findAncestorStateOfType<
                                              _AllCryptoState>()
                                          .setState(() {});
                                    },
                                    items: _supportedCurrencies
                                        .map((s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(
                                                "$s ${_conversionMap[s]["symbol"]}")))
                                        .toList()))),
                        padding: EdgeInsets.only(right: 10.0))),
                margin: EdgeInsets.zero,
              )
            ])));
  }
}

bool moving = false;
String moveWith;

class Crypto extends StatefulWidget {
  final String id;
  final String userAddress;
  final bool savedPage;

  Crypto(this.id, this.userAddress, this.savedPage)
      : super(key: ValueKey(id + savedPage.toString()));

  @override
  _CryptoState createState() => _CryptoState();
}

class _CryptoState extends State<Crypto> {
  bool saved;
  Map<String, dynamic> data;

  @override
  void initState() {
    super.initState();
    data = _coinData[widget.id];
    saved = _savedCoins.contains(widget.id);
  }

  void move(List<String> coins) {
    int moveTo = coins.indexOf(widget.id);
    int moveFrom = coins.indexOf(moveWith);
    coins.removeAt(moveFrom);
    coins.insert(moveTo, moveWith);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    num mCap = data["marketCapUsd"];
    mCap *= _exchangeRate;
    num change = data["changePercent24Hr"];
    String shortName = data["symbol"];
    return Container(
      margin: EdgeInsets.only(top: 6, bottom: 6, right: 16.0),
      padding: EdgeInsets.only(left: 8, top: 8, bottom: 8, right: 8),
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColorLight,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(50), bottomRight: Radius.circular(50))),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        horizontalTitleGap: 10,
        onTap: () {
          if (widget.savedPage) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CoinInfo(
                        widget.id,
                        widget.userAddress,
                        _coinData[widget.id],
                        _symbol,
                        _exchangeRate)));
          } else {
            setState(() {
              if (saved) {
                saved = false;
                _savedCoins.remove(widget.id);
                _userData["saved"] = _savedCoins;
              } else {
                saved = true;
                _savedCoins.add(widget.id);
                _userData["saved"] = _savedCoins;
              }
            });
          }
        },
        leading: FadeInImage(
            image: !blacklist.contains(widget.id)
                ? NetworkImage(
                    "https://static.coincap.io/assets/icons/${shortName.toLowerCase()}@2x.png")
                : AssetImage(tokenIcon),
            placeholder: AssetImage(tokenIcon),
            fadeInDuration: const Duration(milliseconds: 100),
            imageErrorBuilder: (context, error, stackTrace) {
              return Image.asset(tokenIcon, fit: BoxFit.fitWidth);
            },
            height: 56.0,
            width: 56.0),
        subtitle: Row(
          children: [
            Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: width / 3),
                        child: AutoSizeText(data["name"],
                            maxLines: 2,
                            minFontSize: 0.0,
                            maxFontSize: 18.0,
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w600))),
                    Container(height: 8.0),
                    ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: width / 3 - 40),
                        child: AutoSizeText(shortName,
                            maxLines: 1,
                            style: TextStyle(color: Colors.white))),
                    Container(height: 8.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        PriceText(widget.id, _coinData[widget.id], _symbol,
                            _exchangeRate),
                        VerticalDivider(width: 8),
                        change != -1000000.0
                            ? Text(
                                ((change >= 0) ? "+" : "") +
                                    change.toStringAsFixed(3) +
                                    "\%",
                                style: TextStyle(
                                    color: ((change >= 0)
                                        ? Colors.green
                                        : Colors.red),fontSize: 12))
                            : Text("N/A")
                      ],
                    )
                  ]),
            ),
            Column(
              children: [
                !_settings["disableGraphs"]
                    ? linkMap[shortName] != null &&
                            !blacklist.contains(widget.id)
                        ? SvgPicture.network(
                            "https://www.coingecko.com/coins/${linkMap[shortName] ?? linkMap[widget.id]}/sparkline",
                            color: Colors.white,
                            width: 88,
                          )
                        : Container(height: 35.0)
                    : Container(),
              ],
            ),
            VerticalDivider(width: 8),
            !widget.savedPage
                ? Icon(saved ? Icons.check : Icons.add, color: Colors.white)
                : Container()
          ],
        ),
        // onPress: () {
        //   if (moving) {
        //     move(_savedCoins);
        //     move(context
        //         .findAncestorStateOfType<_AllCryptoState>()
        //         .sortedKeys);
        //     setState(() {
        //       moveWith = null;
        //       moving = false;
        //     });
        //     context
        //         .findAncestorStateOfType<_AllCryptoState>()
        //         .setState(() {});
        //     _userData["saved"] = _savedCoins;
        //   } else {
        //     Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //             builder: (context) =>
        //                 ItemInfo(widget.id, widget.address)));
        //   }
        // },
        // padding: EdgeInsets.only(
        //     top: 12.0, bottom: 12.0, left: 12.0, right: 12.0),
        // // color:
        // //     moveWith != widget.id ? Colors.black45 : Colors.black26,
        // color: Theme
        //     .of(context)
        //     .primaryColorLight,
        // child: Row(
        //   children: [
        //     Column(
        //         crossAxisAlignment: CrossAxisAlignment.center,
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: [
        //           PriceText(widget.id),
        //           Padding(
        //               padding: EdgeInsets.all(4),
        //               child: Text(
        //                   (mCap >= 0
        //                       ? mCap > 1
        //                       ? _symbol +
        //                       NumberFormat.currency(
        //                           symbol: "",
        //                           decimalDigits: 0)
        //                           .format(mCap)
        //                       : _symbol + mCap.toStringAsFixed(2)
        //                       : "N/A"),
        //                   style: TextStyle(
        //                       color: Colors.grey, fontSize: 12.0))),
        //         ]),
        //   ],
        // ),
      ),
    );
  }
}
