import 'dart:async';
import 'package:coin_analyzer/state_management/covalent_states/covalent_token_list_cubit_ethereum.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coin_analyzer/models/network/networks_model.dart';
import 'package:coin_analyzer/utils/misc/box.dart';
import 'package:coin_analyzer/utils/web3_utils/eth_conversions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

import '../../constants.dart';
import '../../theme_data.dart';

class SendTransactionStatusScreen extends StatefulWidget {
  @override
  _SendTransactionStatusScreenState createState() =>
      _SendTransactionStatusScreenState();
}

class _SendTransactionStatusScreenState
    extends State<SendTransactionStatusScreen> {
  String txHash;
  bool isEth;
  TransactionReceipt receipt;
  double value = 0;
  String from;
  String to;
  bool failed = false;

  String gas;
  bool loading = true;
  bool transactionPending = true;
  int index = 1;
  StreamSubscription streamSubscription;

  //int status = 0; //0=no status, 1= merged, 2= failed
  bool unmerged = false;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final List<dynamic> args = ModalRoute.of(context).settings.arguments;
      this.txHash = args[0].toString();
      this.isEth = args[1];
      isEth ? ethTxStatus(txHash) : txStatus(txHash);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              icon: Icon(
                Icons.close,
              ),
              onPressed: _closeFn)
        ],
        elevation: 0,
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 8),
        child: Container(
          child: Center(
            child: failed
                ? Lottie.asset(sentFailedLottieJson, repeat: false)
                : !transactionPending
                    ? Lottie.asset(sentLottieJson, repeat: false)
                    : Lottie.asset(sendingLottieJson),
          ),
        ),
      ),
      floatingActionButton: !transactionPending
          ? TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).backgroundColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.buttonRadius))),
              onPressed: _closeFn,
              child: Text(
                'Transaction has been Successful.',
                style: AppTheme.label_medium.copyWith(color: AppTheme.white),
              ),
            )
          : Container(
              margin: EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingHeight20 * 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).backgroundColor,
                  ),
                  Container(
                    child: Text(
                      'Please Wait',
                      style: Theme.of(context).textTheme.button,
                    ),
                  ),
                  SizedBox(
                    height: AppTheme.paddingHeight12,
                  ),
                  Container(
                    child: Text(
                      'Transaction may take a few sec to complete.',
                      maxLines: 10,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                  SizedBox(
                    height: AppTheme.paddingHeight12,
                  ),
                ],
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    try {
      streamSubscription.cancel();
    } catch (e) {}

    super.dispose();
  }

  void _closeFn() {
    // isEth
    //     ? Navigator.popAndPushNamed(context, ethereumTransactionStatusRoute,
    //         arguments: txHash)
    //     : Navigator.popAndPushNamed(context, transactionStatusMaticRoute,
    //         arguments: txHash);
    Navigator.pop(context);
  }

  Future<void> txStatus(String txHash) async {
    NetworksObject config = await BoxUtils.getActiveNetwork();
    String webSocketUrl = "wss://" +
        config.rpcUrl.replaceFirst("https://", "").replaceFirst("/", "/ws");

    print("Web Socket Url : $webSocketUrl");

    final client = Web3Client(config.rpcUrl,
        http.Client() /*, socketConnector: () {
      return IOWebSocketChannel.connect(webSocketUrl).cast<String>();
    }*/
        );
    print(txHash);

    final client2 = Web3Client(config.rpcUrl, http.Client());

    var txFuture = client2.getTransactionReceipt(txHash);
    TransactionInformation tbh;
    try {
      tbh = await client2.getTransactionByHash(txHash);
    } catch (e) {
      // BoxUtils.removePendingTx(txHash);
      setState(() {
        unmerged = true;
        loading = false;
      });
      return;
    }
    var tx;
    if (tbh != null) {
      setState(() {
        gas = EthConversions.weiToEthUnTrimmed(
                (tbh.gasPrice.getInWei * BigInt.from(tbh.gas)), 18)
            .toString();
        to = tbh.to.toString();
        from = tbh.from.toString();
        value = EthConversions.weiToEthUnTrimmed(tbh.value.getInWei, 18);
        loading = false;
      });
      tx = await txFuture;
    } else if (tx != null) {
      setState(() {
        to = tx.to.toString();
        from = tx.from.toString();
        gas = EthConversions.weiToEthUnTrimmed(tx.gasUsed, 18).toString();
        loading = false;
      });
    }
    tx = await txFuture;
    if (tx != null) {
      setState(() {
        if (tx.status) {
          transactionPending = false;
          index = 2;
          receipt = tx;
        } else {
          receipt = tx;
          index = 2;
          failed = true;
          transactionPending = true;
        }
      });
      return;
    }

    streamSubscription = client.addedBlocks().listen(null);
    streamSubscription.onData((data) async {
      var tx = await client2.getTransactionReceipt(txHash);
      print(tx);
      try {
        await client2.getTransactionByHash(txHash);
      } catch (e) {
        // BoxUtils.removePendingTx(txHash);
        setState(() {
          unmerged = true;
        });
      }
      if (tx != null) {
        context.read<CovalentTokensListEthCubit>().getTokensList();
        setState(() {
          if (tx.status) {
            receipt = tx;
            index = 2;
            transactionPending = false;
          } else {
            receipt = tx;
            failed = true;
            transactionPending = false;
          }
        });
        streamSubscription.cancel();
      }
    });
  }

  Future<void> ethTxStatus(String txHash) async {
    // NetworkConfigObject config = await NetworkManager.getNetworkObject();
    // final client =
    //     Web3Client(config.ethEndpoint, http.Client(), socketConnector: () {
    //   return IOWebSocketChannel.connect(config.ethWebsocket).cast<String>();
    // });
    NetworksObject config = await BoxUtils.getActiveNetwork();
    final client =
        Web3Client(config.rpcUrl, http.Client(), socketConnector: () {
      return IOWebSocketChannel.connect(
              config.rpcUrl.replaceFirst("https://", "wss://"))
          .cast<String>();
    });
    print(txHash);
    final client2 = Web3Client(config.rpcUrl, http.Client());
    var txFuture = client2.getTransactionReceipt(txHash);
    TransactionInformation tbh;
    try {
      tbh = await client2.getTransactionByHash(txHash);
    } catch (e) {
      // BoxUtils.removePendingTx(txHash);
      setState(() {
        unmerged = true;
        loading = false;
      });
      return;
    }
    var tx;
    if (tbh != null) {
      setState(() {
        gas = EthConversions.weiToEthUnTrimmed(
                (tbh.gasPrice.getInWei * BigInt.from(tbh.gas)), 18)
            .toString();
        to = tbh.to.toString();
        from = tbh.from.toString();
        value = EthConversions.weiToEthUnTrimmed(tbh.value.getInWei, 18);
        loading = false;
      });
      tx = await txFuture;
    } else if (tx != null) {
      setState(() {
        to = tx.to.toString();
        from = tx.from.toString();
        gas = EthConversions.weiToEthUnTrimmed(tx.gasUsed, 18).toString();
        loading = false;
      });
    }
    tx = await txFuture;
    print(tx);
    if (tx != null) {
      setState(() {
        if (tx.status) {
          transactionPending = false;
          index = 2;
          receipt = tx;
        } else {
          receipt = tx;
          index = 2;
          failed = true;
          transactionPending = true;
        }
      });
      return;
    }

    streamSubscription = client.addedBlocks().listen(null);
    streamSubscription.onData((data) async {
      var tx = await client2.getTransactionReceipt(txHash);
      print(tx);
      try {
        await client2.getTransactionByHash(txHash);
      } catch (e) {
        // BoxUtils.removePendingTx(txHash);
        setState(() {
          unmerged = true;
        });
      }
      if (tx != null) {
        setState(() {
          if (tx.status) {
            receipt = tx;
            index = 2;
            transactionPending = false;
          } else {
            receipt = tx;
            failed = true;
            transactionPending = false;
          }
        });
        streamSubscription.cancel();
      }
    });
  }
}
