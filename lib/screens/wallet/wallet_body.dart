import 'package:coin_analyzer/state_management/covalent_states/covalent_token_list_cubit_ethereum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../constants.dart';
import 'coin_list_card.dart';
import 'nft_list.dart';
import 'top_balance.dart';

class WalletBody extends StatefulWidget {
  @override
  _WalletBodyState createState() => _WalletBodyState();
}

class _WalletBodyState extends State<WalletBody> {
  int counter = 0;
  bool verified = true;
  var pushed = false;
  var amount = 0.0;
  CovalentTokensListEthState state;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final ethCubit = context.read<CovalentTokensListEthCubit>();
      ethCubit.getTokensList();
    });

    // getTokenBalance();
  }

  // getBalance() async {
  //   EtherAmount balance = await TokenTransactions.getEthBalance();
  //   amount = EthAmountFormatter(balance.getInWei).format();
  //   print("Amount : $amount");
  //   setState(() {});
  // }
  //
  // getTokenBalance() async {
  //   BigInt balance = await TokenTransactions.tokenBalance();
  //   amount = EthAmountFormatter(balance).format();
  //   print("Amount : $amount");
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    // return Padding(
    //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
    //   child: RefreshIndicator(
    //     onRefresh: () async {},
    //     child: ListView(children: [
    //       Padding(
    //         padding: const EdgeInsets.only(top: 30, bottom: 50),
    //         child: TopBalance(amount),
    //       ),
    //     ]),
    //   ),
    // );
    return BlocBuilder<CovalentTokensListEthCubit, CovalentTokensListEthState>(
      builder: (context, state) {
        if (state is CovalentTokensListEthInitial) {
          return SpinKitFadingFour(
            size: 40,
            color: Theme.of(context).accentColor,
          );
        } else if (state is CovalentTokensListEthLoading) {
          return SpinKitFadingFour(
            size: 40,
            color: Theme.of(context).accentColor,
          );
        } else if (state is CovalentTokensListEthLoaded) {
          this.state = state;
          var amt = 0.0;
          if (state.covalentTokenList.data.items.length > 0) {
            state.covalentTokenList.data.items.forEach((element) {
              amt += element.quote == null ? 0 : element.quote;
            });
          }
          amount = amt;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  child: TopBalance(amt.toStringAsFixed(2)),
                ),
                CoinListCard(
                  tokens: state.covalentTokenList.data.items,
                ),
                state.covalentTokenList.data.items
                            .where((element) => element.nftData != null)
                            .length !=
                        0
                    ? NftListCard(
                        tokens: state.covalentTokenList.data.items,
                      )
                    : Container(),
                SizedBox(
                  height: 120,
                )
              ]),
            ),
          );
        } else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Something went wrong"),
                RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    color: sendButtonColor.withOpacity(0.6),
                    child: Text("Refresh"),
                    onPressed: _initializeAgain),
              ],
            ),
          );
        }
      },
    );
  }

  _initializeAgain() {
    final ethCubit = context.read<CovalentTokensListEthCubit>();
    ethCubit.getTokensList();
  }

  Future<void> _refresh() async {
    final ethCubit = context.read<CovalentTokensListEthCubit>();
    Future ethTokenListFuture = ethCubit.refresh();
    await ethTokenListFuture;
    setState(() {});
  }
}
