import 'package:coin_analyzer/models/send_token_model/send_token_data.dart';
import 'package:coin_analyzer/state_management/send_token_state/send_token_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants.dart';
import '../../theme_data.dart';


class TopBalance extends StatelessWidget {
  final balance;

  TopBalance(this.balance);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "\$$balance",
                  style: Theme.of(context)
                      .textTheme
                      .headline3
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    balanceString,
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 98,
                          height: 44,
                          child: TextButton(
                            style: ButtonStyle(shape: MaterialStateProperty
                                .resolveWith<OutlinedBorder>((_) {
                              return RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100));
                            }), backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed))
                                  return AppTheme.purpleSelected
                                      .withOpacity(0.2);
                                return AppTheme.purpleSelected.withOpacity(1);
                                // Use the component's default.
                              },
                            )),
                            onPressed: () {
                              // Navigator.of(context).pushNamed(receivePageRoute);
                            },
                            child: Container(
                                width: double.infinity,
                                child: Center(
                                    child: Text("Receive",
                                        style: AppTheme.buttonTextSecondary))),
                          ),
                        ),
                        SizedBox(
                          width: 98,
                          height: 44,
                          child: TextButton(
                            style: ButtonStyle(shape: MaterialStateProperty
                                .resolveWith<OutlinedBorder>((_) {
                              return RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100));
                            }), backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed))
                                  return AppTheme.primaryColor.withOpacity(0.5);
                                return AppTheme.primaryColor.withOpacity(1);
                              },
                            )),
                            onPressed: () {
                              var cubit = context.read<SendTransactionCubit>();
                              cubit.setData(SendTokenData());
                              Navigator.pushNamed(context, selectTokenRoute);
                            },
                            child: Container(
                                width: double.infinity,
                                child: Center(
                                    child: Text(
                                  "Send",
                                  style: AppTheme.buttonText,
                                ))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }
}
/*

class TopBalance1 extends StatelessWidget {
  final balance;

  TopBalance1(this.balance);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AutoSizeText(
                  "$balance",
                  style: Theme.of(context).textTheme.headline3,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    balanceString,
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 98,
                          height: 44,
                          child: TextButton(
                            style: ButtonStyle(shape: MaterialStateProperty
                                .resolveWith<OutlinedBorder>((_) {
                              return RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100));
                            }), backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed))
                                  return Theme.of(context)
                                      .primaryColorDark
                                      .withOpacity(0.2);
                                return Theme.of(context)
                                    .primaryColorLight
                                    .withOpacity(1);
                                // Use the component's default.
                              },
                            )),
                            onPressed: () {
                              // Navigator.of(context).pushNamed(receivePageRoute);
                            },
                            child: Container(
                                width: double.infinity,
                                child: Center(
                                    child: Text(
                                  "Receive",
                                  style: TextStyle(color: Colors.white),
                                ))),
                          ),
                        ),
                        SizedBox(
                          width: 98,
                          height: 44,
                          child: TextButton(
                            style: ButtonStyle(shape: MaterialStateProperty
                                .resolveWith<OutlinedBorder>((_) {
                              return RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100));
                            }), backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed))
                                  return Theme.of(context)
                                      .primaryColorLight
                                      .withOpacity(0.5);
                                return Theme.of(context)
                                    .primaryColorDark
                                    .withOpacity(1);
                                // Use the component's default.
                              },
                            )),
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, confirmTokenTransactionRoute);
                            },
                            child: Container(
                                width: double.infinity,
                                child: Center(
                                    child: Text(
                                  "Send",
                                  style: TextStyle(color: Colors.white),
                                  // style: AppTheme.buttonText,
                                ))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }
}
*/
