import 'package:coin_analyzer/models/covalent_models/covalent_token_list.dart';
import 'package:coin_analyzer/utils/web3_utils/eth_conversions.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../theme_data.dart';

class CoinGroupTile extends StatelessWidget {
  final CovalentToken tokenData;

  const CoinGroupTile({Key key, this.tokenData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.pushNamed(context, chatRoute, arguments: this.tokenData);
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
      trailing: Icon(Icons.arrow_forward_ios_sharp, size: 16),
    );
  }
}
