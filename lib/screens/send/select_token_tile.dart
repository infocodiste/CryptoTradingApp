import 'package:coin_analyzer/models/covalent_models/covalent_token_list.dart';
import 'package:coin_analyzer/models/send_token_model/send_token_data.dart';
import 'package:coin_analyzer/state_management/send_token_state/send_token_cubit.dart';
import 'package:coin_analyzer/utils/web3_utils/eth_conversions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants.dart';
import '../../theme_data.dart';

class SelectTokenTile extends StatelessWidget {
  final CovalentToken tokenData;
  final String address;

  const SelectTokenTile({Key key, this.tokenData, this.address})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var amount = EthConversions.weiToEth(
            BigInt.parse(tokenData.balance), tokenData.contractDecimals)
        .toString();
    SendTransactionCubit data = context.read<SendTransactionCubit>();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      margin: EdgeInsets.only(right: 12),
      child: Card(
        color: Theme.of(context).primaryColorLight,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(32),
                bottomRight: Radius.circular(32))),
        elevation: AppTheme.cardElevations,
        child: ListTile(
          onTap: () {
            if (address == null) {
              data.setData(SendTokenData(token: tokenData));
              Navigator.pushNamed(context, enterAmountRoute);
            } else {
              data.setData(SendTokenData(token: tokenData, receiver: address));
              Navigator.pushNamed(context, enterAmountRoute);
            }
          },
          leading: Container(
            width: 36,
            height: 36,
            child: FadeInImage.assetNetwork(
              placeholder: tokenIcon,
              image: tokenData.logoUrl,
              width: AppTheme.tokenIconHeight,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(tokenIcon, fit: BoxFit.fitWidth);
              },
            ),
          ),
          title: Text(tokenData.contractName,
              style: Theme.of(context).textTheme.headline6),
          subtitle: Text(tokenData.contractTickerSymbol,
              style: Theme.of(context).textTheme.subtitle2),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "\$${tokenData.quote.toStringAsFixed(2)}",
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(amount, style: Theme.of(context).textTheme.bodyText1),
            ],
          ),
        ),
      ),
    );
  }
}
