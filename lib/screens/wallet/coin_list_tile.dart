import 'package:coin_analyzer/models/covalent_models/covalent_token_list.dart';
import 'package:coin_analyzer/models/send_token_model/send_token_data.dart';
import 'package:coin_analyzer/state_management/send_token_state/send_token_cubit.dart';
import 'package:coin_analyzer/utils/web3_utils/eth_conversions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants.dart';
import '../../theme_data.dart';

class CoinListTile extends StatelessWidget {
  final CovalentToken tokenData;

  const CoinListTile({Key key, this.tokenData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var amount = EthConversions.weiToEth(
            BigInt.parse(tokenData.balance), tokenData.contractDecimals)
        .toString();

    SendTransactionCubit data = context.read<SendTransactionCubit>();

    return Row(
      children: [
        Expanded(
          child: ListTile(
            onTap: () {
              data.setData(SendTokenData(token: tokenData));
              Navigator.pushNamed(context, coinTransactionsRoute);
            },
            minVerticalPadding: 0,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
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
                  "\$${tokenData.quote}",
                  style: Theme.of(context).textTheme.headline6,
                ),
                Text(
                  amount,
                  style: Theme.of(context).textTheme.subtitle2,
                )
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, chatRoute, arguments: this.tokenData);
          },
          child: Container(
              height: 32,
              width: 32,
              margin: EdgeInsets.only(right: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppTheme.purpleSelected,
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Icon(Icons.chat_bubble, color: Colors.white, size: 16)),
        )
      ],
    );
  }
}
