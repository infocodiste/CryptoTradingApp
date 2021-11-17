import 'package:coin_analyzer/models/covalent_models/covalent_token_list.dart';
import 'package:coin_analyzer/utils/web3_utils/eth_conversions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants.dart';
import '../../theme_data.dart';

class NftListTile extends StatelessWidget {
  final CovalentToken tokenData;

  const NftListTile({Key key, this.tokenData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var amount = EthConversions.weiToEth(
            BigInt.parse(tokenData.balance), tokenData.contractDecimals)
        .toString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Center(
        child: FlatButton(
          onPressed: () {
            // Navigator.pushNamed(context, nftTokenProfile, arguments: tokenData);
          },
          child: ListTile(
            leading: FadeInImage.assetNetwork(
              placeholder: tokenIcon,
              image: tokenData.logoUrl,
              width: AppTheme.tokenIconHeight,
            ),
            title: Text(tokenData.contractName, style: AppTheme.title),
            subtitle:
                Text(tokenData.contractTickerSymbol, style: AppTheme.subtitle),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "\$${tokenData.quote}",
                  style: AppTheme.balanceMain,
                ),
                Text(
                  amount,
                  style: AppTheme.balanceSub,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
