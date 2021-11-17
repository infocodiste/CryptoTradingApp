import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:coin_analyzer/screens/settings/add_network.dart';
import 'package:coin_analyzer/screens/transactions/coin_transactions.dart';
import 'package:coin_analyzer/state_management/covalent_states/covalent_token_list_cubit_ethereum.dart';
import 'package:coin_analyzer/state_management/send_token_state/send_token_cubit.dart';
import 'package:coin_analyzer/screens/send/send_trx_confirm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat/chat_coins.dart';
import 'chat/chat_on_coin.dart';
import 'constants.dart';
import 'screens/landing/app_landing.dart';
import 'screens/landing/create_wallet.dart';
import 'screens/landing/import_wallet.dart';
import 'screens/landing/landing_set_pin.dart';
import 'screens/pin_widget.dart';
import 'screens/send/enter_token_amount.dart';
import 'screens/send/select_token.dart';
import 'screens/send/send_trx_status.dart';
import 'screens/settings/network.dart';
import 'screens/settings/settings_page.dart';
import 'screens/wallet/wallet.dart';
import 'state_management/network_list_state/network_list_cubit.dart';
import 'theme_data.dart';
import 'utils/misc/box.dart';
import 'watchlist/all_cryptos.dart';

const double appBarHeight = 48.0;
const double appBarElevation = 1.0;

bool shortenOn = false;

List marketListData;
Map portfolioMap;
List portfolioDisplay;
Map totalPortfolioStats;

bool isIOS;
String upArrow = "⬆";
String downArrow = "⬇";

int lastUpdate;

Future<Null> getMarketData() async {
  int pages = 5;
  List tempMarketListData = [];

  Future<Null> _pullData(page) async {
    var response = await http.get(
        Uri.parse(
            "https://min-api.cryptocompare.com/data/top/mktcapfull?tsym=USD&limit=100" +
                "&page=" +
                page.toString()),
        headers: {"Accept": "application/json"});

    List rawMarketListData = new JsonDecoder().convert(response.body)["Data"];
    tempMarketListData.addAll(rawMarketListData);
  }

  List<Future> futures = [];
  for (int i = 0; i < pages; i++) {
    futures.add(_pullData(i));
  }
  await Future.wait(futures);

  marketListData = [];
  // Filter out lack of financial data
  for (Map coin in tempMarketListData) {
    if (coin.containsKey("RAW") && coin.containsKey("CoinInfo")) {
      marketListData.add(coin);
    }
  }

  getApplicationDocumentsDirectory().then((Directory directory) async {
    File jsonFile = new File(directory.path + "/marketData.json");
    jsonFile.writeAsStringSync(json.encode(marketListData));
  });
  print("Got new market data.");

  lastUpdate = DateTime.now().millisecondsSinceEpoch;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await getApplicationDocumentsDirectory().then((Directory directory) async {
    File jsonFile = new File(directory.path + "/portfolio.json");
    if (jsonFile.existsSync()) {
      portfolioMap = json.decode(jsonFile.readAsStringSync());
    } else {
      jsonFile.createSync();
      jsonFile.writeAsStringSync("{}");
      portfolioMap = {};
    }
    if (portfolioMap == null) {
      portfolioMap = {};
    }
    jsonFile = new File(directory.path + "/marketData.json");
    if (jsonFile.existsSync()) {
      marketListData = json.decode(jsonFile.readAsStringSync());
    } else {
      jsonFile.createSync();
      jsonFile.writeAsStringSync("[]");
      marketListData = [];
      // getMarketData(); ?does this work?
    }
  });

  String themeMode = "Dark";
  bool darkOLED = false;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool("shortenOn") != null &&
      prefs.getString("themeMode") != null) {
    shortenOn = prefs.getBool("shortenOn");
    themeMode = prefs.getString("themeMode");
    darkOLED = prefs.getBool("darkOLED");
  }

  runApp(new TraceApp(themeMode, darkOLED));
}

numCommaParse(numString) {
  if (shortenOn) {
    String str = num.parse(numString ?? "0")
        .round()
        .toString()
        .replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => "${m[1]},");
    List<String> strList = str.split(",");

    if (strList.length > 3) {
      return strList[0] +
          "." +
          strList[1].substring(0, 4 - strList[0].length) +
          "B";
    } else if (strList.length > 2) {
      return strList[0] +
          "." +
          strList[1].substring(0, 4 - strList[0].length) +
          "M";
    } else {
      return num.parse(numString ?? "0").toString().replaceAllMapped(
          new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},");
    }
  }

  return num.parse(numString ?? "0").toString().replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},");
}

normalizeNum(num input) {
  if (input == null) {
    input = 0;
  }
  if (input >= 100000) {
    return numCommaParse(input.round().toString());
  } else if (input >= 1000) {
    return numCommaParse(input.toStringAsFixed(2));
  } else {
    return input.toStringAsFixed(6 - input.round().toString().length);
  }
}

normalizeNumNoCommas(num input) {
  if (input == null) {
    input = 0;
  }
  if (input >= 1000) {
    return input.toStringAsFixed(2);
  } else {
    return input.toStringAsFixed(6 - input.round().toString().length);
  }
}

class TraceApp extends StatefulWidget {
  TraceApp(this.themeMode, this.darkOLED);

  final themeMode;
  final darkOLED;

  @override
  TraceAppState createState() => new TraceAppState();
}

class TraceAppState extends State<TraceApp> {
  bool darkEnabled;
  String themeMode;
  bool darkOLED;

  void savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("themeMode", themeMode);
    prefs.setBool("shortenOn", shortenOn);
    prefs.setBool("darkOLED", darkOLED);
  }

  toggleTheme() {
    switch (themeMode) {
      case "Automatic":
        themeMode = "Dark";
        break;
      case "Dark":
        themeMode = "Light";
        break;
      case "Light":
        themeMode = "Automatic";
        break;
    }
    handleUpdate();
    savePreferences();
  }

  setDarkEnabled() {
    switch (themeMode) {
      case "Automatic":
        int nowHour = new DateTime.now().hour;
        if (nowHour > 6 && nowHour < 20) {
          darkEnabled = false;
        } else {
          darkEnabled = true;
        }
        break;
      case "Dark":
        darkEnabled = true;
        break;
      case "Light":
        darkEnabled = false;
        break;
    }
    setNavBarColor();
  }

  handleUpdate() {
    setState(() {
      setDarkEnabled();
    });
  }

  switchOLED({state}) {
    setState(() {
      darkOLED = state ?? !darkOLED;
    });
    setNavBarColor();
    savePreferences();
  }

  setNavBarColor() async {
    if (darkEnabled) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarIconBrightness: Brightness.light,
          systemNavigationBarColor: darkOLED
              ? AppTheme.darkThemeOLED.primaryColor
              : AppTheme.darkTheme.primaryColor));
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: AppTheme.lightTheme.primaryColor));
    }
  }

  // Widget current = Splash();

  @override
  void initState() {
    super.initState();
    themeMode = widget.themeMode ?? "Automatic";
    darkOLED = widget.darkOLED ?? false;
    setDarkEnabled();
    BoxUtils.initializeHive().then((value) {
      BoxUtils.addNetwork(
          "BSC Mainnet", "https://bsc-dataseed1.binance.org", 56, 0);
      BoxUtils.addNetwork("BSC Testnet",
          "https://data-seed-prebsc-1-s1.binance.org:8545", 97, 1);
      BoxUtils.setNetwork(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS) {
      upArrow = "↑";
      downArrow = "↓";
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<CovalentTokensListEthCubit>(
            create: (BuildContext context) => CovalentTokensListEthCubit()),
        BlocProvider<NetworkListCubit>(
            create: (BuildContext context) => NetworkListCubit()),
        BlocProvider<SendTransactionCubit>(
            create: (BuildContext context) => SendTransactionCubit()),
      ],
      child: new MaterialApp(
        debugShowCheckedModeBanner: false,
        color: darkEnabled
            ? darkOLED
                ? AppTheme.darkThemeOLED.primaryColor
                : AppTheme.darkTheme.primaryColor
            : AppTheme.lightTheme.primaryColor,
        title: "CoinAnalyzer",
        // home: new Tabs(
        //   savePreferences: savePreferences,
        //   toggleTheme: toggleTheme,
        //   handleUpdate: handleUpdate,
        //   darkEnabled: darkEnabled,
        //   themeMode: themeMode,
        //   switchOLED: switchOLED,
        //   darkOLED: darkOLED,
        // ),
        // home: current,
        initialRoute: homeRoute,
        theme: darkEnabled
            ? darkOLED
                ? AppTheme.darkThemeOLED
                : AppTheme.darkTheme
            : AppTheme.lightTheme,
        routes: <String, WidgetBuilder>{
          myWalletRoute: (BuildContext context) => Wallet(),
          homeRoute: (context) => AllCrypto(true),
          appLandingRoute: (context) => AppLandingScreen(),
          landingSetPinRoute: (context) => LandingSetPinScreen(),
          createWalletRoute: (context) => CreateWalletScreen(),
          importWalletRoute: (context) => ImportWalletScreen(),
          pinWidgetRoute: (context) => PinWidget(),
          networkSettingRoute: (context) => NetworkSetting(),
          addNetworkSettingRoute: (context) => AddNetworkSetting(),
          settingsRoute: (BuildContext context) => new SettingsPage(
                savePreferences: savePreferences,
                toggleTheme: toggleTheme,
                darkEnabled: darkEnabled,
                themeMode: themeMode,
                switchOLED: switchOLED,
                darkOLED: darkOLED,
              ),
          chatGroupsRoute: (context) => ChatCoins(),
          chatRoute: (context) => ChatOnCoin(),
          selectTokenRoute: (context) => SelectTokenList(),
          enterAmountRoute: (context) => EnterTokenAmount(),
          confirmTokenTransactionRoute: (BuildContext context) =>
              new SendTransactionConfirm(),
          sendTrxStatusRoute: (context) => SendTransactionStatusScreen(),
          coinTransactionsRoute: (context) => CoinTransactions(),
        },
      ),
    );
  }
}
