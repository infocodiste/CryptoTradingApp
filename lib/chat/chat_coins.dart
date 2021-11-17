import 'package:coin_analyzer/models/covalent_models/covalent_token_list.dart';
import 'package:coin_analyzer/state_management/covalent_states/covalent_token_list_cubit_ethereum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../constants.dart';
import 'coin_group_tile.dart';

class ChatCoins extends StatefulWidget {
  @override
  _ChatCoinsState createState() => _ChatCoinsState();
}

class _ChatCoinsState extends State<ChatCoins> {
  CovalentTokensListEthState state;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final ethCubit = context.read<CovalentTokensListEthCubit>();
      ethCubit.getTokensList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        elevation: 3,
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text("Coins/Tokens"),
        centerTitle: true,
      ),
      body: BlocBuilder<CovalentTokensListEthCubit, CovalentTokensListEthState>(
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
            List<String> tokenAddress = List.from(state
                .covalentTokenList.data.items
                .map((e) => e.contractAddress)
                .toList());

            print("Token Address : ${tokenAddress.join(", ").toString()}");
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: RefreshIndicator(
                onRefresh: _refresh,
                // child: StreamBuilder<QuerySnapshot>(
                //   stream: FirebaseFirestore.instance
                //       .collection("messages")
                //       .where("idTo", whereIn: tokenAddress)
                //       .snapshots(),
                //   builder: (context, snapshot) {
                //     if (!snapshot.hasData) {
                //       return Center(
                //           child: CircularProgressIndicator(
                //               valueColor: AlwaysStoppedAnimation<Color>(
                //                   AppTheme.purpleSelected)));
                //     } else {
                //       snapshot.data.docs.forEach((element) {
                //         print('Element: ${element['idTo']}');
                //       });
                //       List<String> chatTokens = List.from(
                //           snapshot.data.docs.map((e) => e['idTo']).toList());
                //       print(
                //           "Chat Tokens : ${chatTokens.join(", ").toString()}");
                //
                //       return ListView(
                //           children: _tiles(
                //               context,
                //               List.from(state.covalentTokenList.data.items
                //                   .where((element) => chatTokens
                //                       .contains(element.contractAddress)))));
                //     }
                //   },
                // ),
                child: ListView(
                    children:
                        _tiles(context, state.covalentTokenList.data.items)),
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
      ),
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

  List<Widget> _tiles(BuildContext context, List<CovalentToken> tokens) {
    var tiles = List<Widget>();
    var ls = tokens.where((element) => element.nftData == null);
    for (CovalentToken token in ls) {
      if (token.type == null || token.balance != "0") {
        var tile = CoinGroupTile(
          tokenData: token,
        );
        tiles.add(tile);
        tiles.add(Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Divider(
                thickness: 0.5,
                height: 1,
                color: Theme.of(context).iconTheme.color.withOpacity(0.5))));
      }
    }
    return tiles;
  }
}
