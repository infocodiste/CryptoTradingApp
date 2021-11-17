import 'dart:async';

import 'package:coin_analyzer/models/covalent_models/token_history.dart';
import 'package:coin_analyzer/state_management/covalent_states/covalent_token_list_cubit_ethereum.dart';
import 'package:coin_analyzer/state_management/send_token_state/send_token_cubit.dart';
import 'package:coin_analyzer/utils/api/covalent_api_wrapper.dart';
import 'package:coin_analyzer/utils/misc/credential_manager.dart';
import 'package:coin_analyzer/utils/web3_utils/eth_conversions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../constants.dart';
import '../../theme_data.dart';
import 'transaction_tile.dart';

class CoinTransactions extends StatefulWidget {
  @override
  _CoinTransactionsState createState() => _CoinTransactionsState();
}

class _CoinTransactionsState extends State<CoinTransactions> {
  String address = "";
  List<TransferInfo> txList;
  var future;
  var futureSet = false;

  @override
  void initState() {
    CredentialManager.getAddress().then((val) => address = val);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      var tokenListCubit = context.read<CovalentTokensListEthCubit>();
      _refreshLoop(tokenListCubit);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text("Token Profile"),
        // backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: BlocBuilder<SendTransactionCubit, SendTransactionState>(
        builder: (BuildContext context, state) {
          return BlocBuilder<CovalentTokensListEthCubit,
              CovalentTokensListEthState>(builder: (context, tokenState) {
            if (state is SendTransactionFinal &&
                tokenState is CovalentTokensListEthLoaded) {
              var token = tokenState.covalentTokenList.data.items
                  .where((element) =>
                      state.data.token.contractAddress ==
                      element.contractAddress)
                  .first;
              if (!futureSet) {
                future =
                    CovalentApiWrapper.tokenTransactions(token.contractAddress);
                futureSet = true;
              }

              var balance = EthConversions.weiToEth(
                  BigInt.parse(token.balance.toString()),
                  state.data.token.contractDecimals);
              return SingleChildScrollView(
                padding: EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            height: 256,
                            width: MediaQuery.of(context).size.width * 0.83,
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(AppTheme.cardRadius))),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: 265,
                          child: Card(
                            shape: AppTheme.cardShape,
                            // color: Theme.of(context).primaryColorLight,
                            elevation: AppTheme.cardElevations + 0.2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      child: FadeInImage.assetNetwork(
                                        placeholder: tokenIcon,
                                        image: token.logoUrl,
                                        width: AppTheme.tokenIconSizeBig,
                                        imageErrorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(tokenIcon,
                                              fit: BoxFit.fitWidth);
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 16, bottom: 0),
                                    child: Text(
                                      "$balance ${token.contractTickerSymbol}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "${token.quote.toStringAsFixed(2)} USD",
                                      // style: AppTheme.headline_grey,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5,
                                    ),
                                  ),
                                  // Divider(
                                  //   color: AppTheme.borderColorGreyish,
                                  // ),
                                  // Row(
                                  //   mainAxisAlignment:
                                  //       MainAxisAlignment.spaceEvenly,
                                  //   children: [
                                  //     SizedBox(
                                  //       width: 101,
                                  //       height: 44,
                                  //       child: TextButton(
                                  //         style: ButtonStyle(shape:
                                  //             MaterialStateProperty
                                  //                 .resolveWith<
                                  //                     OutlinedBorder>((_) {
                                  //           return RoundedRectangleBorder(
                                  //               borderRadius:
                                  //                   BorderRadius.circular(
                                  //                       100));
                                  //         }), backgroundColor:
                                  //             MaterialStateProperty
                                  //                 .resolveWith<Color>(
                                  //           (Set<MaterialState> states) {
                                  //             if (states.contains(
                                  //                 MaterialState.pressed))
                                  //               return AppTheme.primaryColor
                                  //                   .withOpacity(0.5);
                                  //             return AppTheme.primaryColor
                                  //                 .withOpacity(1);
                                  //             ; // Use the component's default.
                                  //           },
                                  //         )),
                                  //         onPressed: () {
                                  //           Navigator.pushNamed(
                                  //               context, enterAmountRoute);
                                  //         },
                                  //         child: Container(
                                  //             child: Center(
                                  //                 child: Text(
                                  //           "Send",
                                  //           style: AppTheme.buttonText,
                                  //         ))),
                                  //       ),
                                  //     ),
                                  //     SizedBox(
                                  //       width: 101,
                                  //       height: 44,
                                  //       child: TextButton(
                                  //         style: ButtonStyle(shape:
                                  //             MaterialStateProperty
                                  //                 .resolveWith<
                                  //                     OutlinedBorder>((_) {
                                  //           return RoundedRectangleBorder(
                                  //               borderRadius:
                                  //                   BorderRadius.circular(
                                  //                       100));
                                  //         }), backgroundColor:
                                  //             MaterialStateProperty
                                  //                 .resolveWith<Color>(
                                  //           (Set<MaterialState> states) {
                                  //             if (states.contains(
                                  //                 MaterialState.pressed))
                                  //               return AppTheme
                                  //                   .secondaryColor
                                  //                   .withOpacity(0.5);
                                  //             return AppTheme.secondaryColor
                                  //                 .withOpacity(1);
                                  //             // Use the component's default.
                                  //           },
                                  //         )),
                                  //         onPressed: () {
                                  //           Navigator.pushNamed(
                                  //               context, bridgeActionRoute);
                                  //         },
                                  //         child: Container(
                                  //             width: double.infinity,
                                  //             child: Center(
                                  //                 child: Text("Bridge",
                                  //                     style: AppTheme
                                  //                         .buttonTextSecondary))),
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    FutureBuilder(
                      future: future,
                      builder: (context, result) {
                        if (result.connectionState ==
                            ConnectionState.waiting) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SpinKitFadingFour(
                                  size: 50, color: AppTheme.primaryColor),
                              Text(
                                "Loading...",
                                style: AppTheme.subtitle,
                              )
                            ],
                          );
                        } else if (result.connectionState ==
                            ConnectionState.done) {
                          var tx = result.data.data.transferInfo;
                          return tx.length != 0
                              ? ListView.separated(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount:
                                      result.data.data.transferInfo.length,
                                  itemBuilder: (context, index) {
                                    TransferInfo info = tx[index];
                                    if (info != null &&
                                        info.transfers != null &&
                                        info.transfers.isNotEmpty) {
                                      return TransactionTile(
                                        data: info,
                                        address: result.data.data.address,
                                      );
                                    } else {
                                      return Container();
                                    }
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    TransferInfo info = tx[index];
                                    if (info != null &&
                                        info.transfers != null &&
                                        info.transfers.isNotEmpty) {
                                      return Divider(height: 2);
                                    } else {
                                      return Container();
                                    }
                                  },
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("No Transactions"),
                                );
                        } else {
                          return Center(
                            child: Text("Something went wrong"),
                          );
                        }
                      },
                    )
                  ],
                ),
              );
            } else {
              return Center(child: Text("Something went Wrong"));
            }
          });
        },
      ),
    );
  }

  _refreshLoop(CovalentTokensListEthCubit ethCubit) {
    new Timer.periodic(Duration(seconds: 30), (Timer t) {
      if (mounted) {
        ethCubit.refresh();
      }
    });
  }
}
