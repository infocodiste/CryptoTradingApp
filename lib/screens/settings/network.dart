import 'package:coin_analyzer/constants.dart';
import 'package:coin_analyzer/models/network/networks_list_model.dart';
import 'package:coin_analyzer/models/network/networks_model.dart';
import 'package:coin_analyzer/state_management/covalent_states/covalent_token_list_cubit_ethereum.dart';
import 'package:coin_analyzer/state_management/network_list_state/network_list_cubit.dart';
import 'package:coin_analyzer/utils/misc/box.dart';
import 'package:coin_analyzer/utils/misc/credential_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../theme_data.dart';

class NetworkSetting extends StatefulWidget {
  @override
  _NetworkSettingState createState() => _NetworkSettingState();
}

class _NetworkSettingState extends State<NetworkSetting> {
  List<NetworksObject> list;
  int value;
  NetworkListFinal state;

  @override
  initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final ethCubit = context.read<NetworkListCubit>();
      ethCubit.getNetworkList();
    });
    super.initState();
    setUpDetails();
  }

  setUpDetails() async {
    value = await BoxUtils.getActiveNetworkId();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,
        brightness: Brightness.light,
        title: Text("Network"),
      ),
      // body: (list == null || list.length <= 0)
      //     ? Container()
      //     : Container(
      //         padding: EdgeInsets.all(12),
      //         width: MediaQuery.of(context).size.width,
      //         child: Column(
      //           children: list
      //               .map((e) => networkCard(
      //                   title: e.name, body1: e.rpcUrl, val: list.indexOf(e)))
      //               .toList(),
      //         ),
      //       ),
      body: BlocBuilder<NetworkListCubit, NetworkListState>(
        builder: (context, state) {
          if (state is NetworkListInitial) {
            return SpinKitFadingFour(
              size: 40,
              color: Theme.of(context).accentColor,
            );
          } else if (state is NetworkListLoading) {
            return SpinKitFadingFour(
              size: 40,
              color: Theme.of(context).accentColor,
            );
          } else if (state is NetworkListFinal) {
            this.state = state;
            this.list = state.data.networks;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListView(
                  children: list
                      .map((e) => networkCard(
                          title: e.name, body1: e.rpcUrl, val: list.indexOf(e)))
                      .toList()),
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed(addNetworkSettingRoute);
          },
          icon: Icon(
            Icons.add_circle_rounded,
            size: 56,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget networkCard({String title, String body1, String body2, int val}) {
    return GestureDetector(
      onTap: () async {
        value = val;
        BoxUtils.setNetwork(value);
        bool isLogin = await BoxUtils.checkLogin();
        if (isLogin) {
          context.read<CovalentTokensListEthCubit>().getTokensList();
        }
        setState(() {});
      },
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        elevation: AppTheme.cardElevations,
        // color: Theme.of(context).primaryColorLight,
        child: Padding(
          padding: EdgeInsets.all(AppTheme.paddingHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(title ?? 'Mainnet',
                              style: Theme.of(context).textTheme.headline6)
                        ],
                      ),
                      // SizedBox(
                      //   height: AppTheme.paddingHeight,
                      // ),
                      // Container(
                      //   width: MediaQuery.of(context).size.width * 0.7,
                      //   child: Text(
                      //     body1 ?? 'Ethereum network',
                      //     style: Theme.of(context).textTheme.bodyText1,
                      //     overflow: TextOverflow.ellipsis,
                      //   ),
                      // ),
                    ],
                  ),
                  SizedBox(
                    width: AppTheme.paddingHeight,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(AppTheme.cardRadiusBig / 2),
                        color: value == val
                            ? AppTheme.orange_500
                            : AppTheme.white),
                    child: value == val
                        ? Icon(
                            Icons.check,
                            size: 24.0,
                            color: Colors.white,
                          )
                        : Icon(
                            Icons.circle,
                            size: 24.0,
                            color: Colors.white,
                          ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _initializeAgain() {
    final networkCubit = context.read<NetworkListCubit>();
    networkCubit.getNetworkList();
  }
}
