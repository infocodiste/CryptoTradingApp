import 'package:coin_analyzer/models/network/networks_list_model.dart';
import 'package:coin_analyzer/models/network/networks_model.dart';
import 'package:coin_analyzer/state_management/covalent_states/covalent_token_list_cubit_ethereum.dart';
import 'package:coin_analyzer/state_management/network_list_state/network_list_cubit.dart';
import 'package:coin_analyzer/utils/misc/box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../theme_data.dart';

class AddNetworkSetting extends StatefulWidget {
  @override
  _AddNetworkSettingState createState() => _AddNetworkSettingState();
}

class _AddNetworkSettingState extends State<AddNetworkSetting> {
  TextEditingController nameController = new TextEditingController();
  TextEditingController urlController = new TextEditingController();
  TextEditingController chainIdController = new TextEditingController();
  bool isTestNet = false;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,
        brightness: Brightness.light,
        title: Text("Add Network"),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(),
                Card(
                  shape: AppTheme.cardShape,
                  child: Padding(
                    padding: EdgeInsets.all(AppTheme.paddingHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.cardRadius),
                              color: AppTheme.warmgray_200,
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                  width: 1, color: AppTheme.orange_500)),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: TextFormField(
                            controller: nameController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (val) => val.trim().split(" ").length > 0
                                ? null
                                : 'Enter Name',
                            style: AppTheme.label_medium
                                .copyWith(color: AppTheme.warmgray_600),
                            decoration: InputDecoration(
                              fillColor: AppTheme.black,
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              labelText: "Name",
                              hintText: "Enter network name",
                            ),
                          ),
                        ),
                        SizedBox(
                          height: AppTheme.paddingHeight12,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.cardRadius),
                              color: AppTheme.warmgray_100,
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                  width: 1, color: AppTheme.orange_500)),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: TextFormField(
                            controller: urlController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (val) => val.trim().split(" ").length > 0
                                ? null
                                : 'Enter RPC URL',
                            style: AppTheme.label_medium
                                .copyWith(color: AppTheme.warmgray_600),
                            decoration: InputDecoration(
                              fillColor: AppTheme.warmgray_100,
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              labelText: "RPC URL",
                              hintText: "Enter Network RPC URL",
                            ),
                          ),
                        ),
                        SizedBox(
                          height: AppTheme.paddingHeight12,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.cardRadius),
                              color: AppTheme.warmgray_100,
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                  width: 1, color: AppTheme.orange_500)),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: TextFormField(
                            controller: chainIdController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (val) => val.trim().split(" ").length > 0
                                ? null
                                : 'Add Chain Id',
                            style: AppTheme.label_medium
                                .copyWith(color: AppTheme.warmgray_600),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            // Only numbers can be entered
                            decoration: InputDecoration(
                              fillColor: AppTheme.warmgray_100,
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              labelText: "Chain Id",
                              hintText: "Enter network chain id",
                            ),
                          ),
                        ),
                        SizedBox(
                          height: AppTheme.paddingHeight12,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text("Testnet",
                                  style: Theme.of(context).textTheme.headline6),
                              new Switch(
                                activeColor: Theme.of(context).accentColor,
                                value: isTestNet,
                                onChanged: (onOff) {
                                  isTestNet = onOff;
                                  setState(() {});
                                },
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: AppTheme.buttonHeight_44,
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: AppTheme.buttonHeight_44,
          margin: EdgeInsets.symmetric(horizontal: AppTheme.paddingHeight12),
          child: TextButton(
            style: TextButton.styleFrom(
                backgroundColor: AppTheme.orange_500,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.buttonRadius))),
            onPressed: _addNetwork,
            child: Text(
              'Add',
              style:
                  AppTheme.label_medium.copyWith(color: AppTheme.lightgray_700),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  _addNetwork() async {
    var isValid = true;
    String message = "";
    if (nameController.text.trim().length <= 0) {
      isValid = false;
      message = "Enter Network Name";
    } else if (urlController.text.trim().length <= 0) {
      isValid = false;
      message = "Enter RPC URL";
    } else if (chainIdController.text.trim().length <= 0) {
      isValid = false;
      message = "Enter Chain Id";
    }

    if (!isValid) {
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      String name = nameController.text;
      String url = urlController.text;
      String chainId = chainIdController.text;
      BoxUtils.addNetwork(name, url, int.parse(chainId), isTestNet ? 1 : 0);
      context.read<NetworkListCubit>().getNetworkList();
      Navigator.pop(context);
    }
  }
}
