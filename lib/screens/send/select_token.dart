import 'package:coin_analyzer/state_management/covalent_states/covalent_token_list_cubit_ethereum.dart';
import 'package:coin_analyzer/state_management/send_token_state/send_token_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../constants.dart';
import '../../theme_data.dart';
import 'select_token_tile.dart';

class SelectTokenList extends StatefulWidget {
  @override
  _SelectTokenListState createState() => _SelectTokenListState();
}

class _SelectTokenListState extends State<SelectTokenList> {
  bool submitted = false;

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
      title: new Text('All Tokens'),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  _SelectTokenListState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      backgroundColor: Theme.of(context).backgroundColor,
      body: BlocBuilder<CovalentTokensListEthCubit, CovalentTokensListEthState>(
          builder: (context, listState) {
        return BlocBuilder<SendTransactionCubit, SendTransactionState>(
            builder: (context, tokenState) {
          if (listState is CovalentTokensListEthInitial) {
            return SpinKitFadingFour(
              size: 40,
              color: AppTheme.primaryColor,
            );
          } else if (listState is CovalentTokensListEthLoading) {
            return SpinKitFadingFour(
              size: 40,
              color: AppTheme.primaryColor,
            );
          } else if (listState is CovalentTokensListEthLoaded &&
              tokenState is SendTransactionFinal) {
            if (listState.covalentTokenList.data.items.length == 0) {
              return Center(
                child: Text(
                  "No tokens",
                  style: AppTheme.title,
                ),
              );
            }
            var ls = listState.covalentTokenList.data.items
                .where((element) => element.nftData == null)
                .toList();

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                itemCount: ls.length,
                itemBuilder: (context, index) {
                  var token = ls[index];
                  return SelectTokenTile(
                    address: tokenState.data.receiver,
                    tokenData: token,
                  );
                },
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
                      onPressed: () {
                        _initializeAgain();
                      }),
                ],
              ),
            );
          }
        });
      }),
    );
  }

  _initializeAgain() async {
    final tokenListCubit = context.read<CovalentTokensListEthCubit>();
    await tokenListCubit.getTokensList();
  }

  Future<void> _refresh() async {
    final tokenListCubit = context.read<CovalentTokensListEthCubit>();
    await tokenListCubit.refresh();
  }
}
