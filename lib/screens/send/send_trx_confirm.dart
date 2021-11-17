import 'dart:math';

import 'package:coin_analyzer/models/transaction_data/transaction_data.dart';
import 'package:coin_analyzer/utils/misc/box.dart';
import 'package:coin_analyzer/utils/web3_utils/eth_conversions.dart';
import 'package:coin_analyzer/utils/web3_utils/token_web3_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:slide_to_confirm/slide_to_confirm.dart';
import 'package:web3dart/web3dart.dart';

import '../../constants.dart';
import '../../loading_indicator.dart';
import '../../theme_data.dart';

class SendTransactionConfirm extends StatefulWidget {
  @override
  _SendTransactionConfirmState createState() => _SendTransactionConfirmState();
}

class _SendTransactionConfirmState extends State<SendTransactionConfirm> {
  TransactionData args;
  bool _loading = true;
  var gasPrice;
  int network;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      args = ModalRoute.of(context).settings.arguments;
      print(args.to);
      print(args.amount);
      print(args.type);
      BoxUtils.getActiveNetwork().then((network) {
        TokenWeb3Services.getGasPrice().then((value) {
          setState(() {
            gasPrice = value;
            _loading = false;
            this.network = network.testNet;
          });
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          title: Text("Send"),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        body: _loading
            ? SpinKitFadingFour(
                size: 50,
                color: AppTheme.primaryColor,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                  ),
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Container(
                              height: 243,
                              width: MediaQuery.of(context).size.width * 0.7,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColorDark,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12))),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12))),
                              color: Theme.of(context).primaryColorLight,
                              //elevation: AppTheme.cardElevations,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: 233,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    SizedBox(),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Text(
                                        //   "${args.amount} Token",
                                        //   style: TextStyle(
                                        //       fontWeight: FontWeight.w700,
                                        //       fontSize: 36,
                                        //       letterSpacing: -1 // was lightText
                                        //       ),
                                        // ),
                                        Text(
                                          double.tryParse(args.amount)
                                                  .toStringAsFixed(3) +
                                              " ${args.token.contractTickerSymbol}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 36,
                                              letterSpacing: -1 // was lightText
                                              ),
                                        ),
                                        Text(
                                          "  ${(args.token.quoteRate * double.parse(args.amount)).toStringAsFixed(3)}  USD",
                                        )
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Divider(color: Colors.grey),
                                        SizedBox(),
                                        Text(
                                          network == 1 ? "Testnet" : "Mainnet",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 8, 0, 0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Image.asset(boltIcon),
                                              ),
                                              Text(
                                                "${EthConversions.weiToGwei(gasPrice)} Gwei ${args.token.contractName} Gas Price",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1,
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            //left: MediaQuery.of(context).size.width * 0.25,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(40)),
                                    elevation: 0,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(0),
                                          child: Icon(
                                            Icons.account_circle_sharp,
                                            size: 35,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 2.0),
                                            child: Text(
                                              args.to,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  SafeArea(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SafeArea(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ConfirmationSlider(
                            backgroundShape:
                                BorderRadius.all(Radius.circular(12)),
                            foregroundShape:
                                BorderRadius.all(Radius.circular(12)),
                            foregroundColor: Theme.of(context).primaryColor,
                            onConfirmation: () => _sendTx()),
                      ))
                    ],
                  ))
                ],
              ));
  }

  _sendTx() async {
    final GlobalKey<State> _keyLoader = new GlobalKey<State>();
    Dialogs.showLoadingDialog(context, _keyLoader);

    // BigInt bigTransferAmount = BigInt.from(transferValue * pow(10, 18));

    // print("bigTransferAmount : $bigTransferAmount");

    // Transaction trx = await TokenTransactions.transferTejaToken(
    //   bigTransferAmount,
    //   recipient,
    // );

    String hash = await TokenWeb3Services.sendTransaction(
      args.trx,
      context,
    );
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    if (hash == null || hash == "failed") {
      Navigator.pop(context);
      return;
    }
    Navigator.pop(context);
    Navigator.popAndPushNamed(context, sendTrxStatusRoute,
        arguments: [hash, false]);
  }
}
