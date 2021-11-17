import 'package:coin_analyzer/models/covalent_models/covalent_token_list.dart';
import 'package:flutter/material.dart';

import '../../theme_data.dart';
import 'coin_list_tile.dart';

class CoinListCard extends StatelessWidget {
  final List<CovalentToken> tokens;

  CoinListCard({Key key, @required this.tokens}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int total;
    List<Widget> ls = List<Widget>();
    total = tokens.where((element) => element.nftData == null).length;
    // ls.add(_divider(context));
    ls.add(_disclaimer(context));
    ls.addAll(_tiles(context));
    if (total > 5) {
      ls.add(_divider(context));
      ls.add(_raisedButton(context));
    }
    return Card(
      elevation: AppTheme.cardElevations,
      shape: AppTheme.cardShape,
      child: ExpansionTile(
        title: Text(
          "$total Coins",
          style: Theme.of(context).textTheme.headline6,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        children: ls,
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child: Divider(color: AppTheme.lightText),
    );
  }

  Widget _disclaimer(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Text(
          "Showing coins with balance only",
          style: Theme.of(context).textTheme.bodyText1,
        ));
  }

  List<Widget> _tiles(BuildContext context) {
    var tiles = List<Widget>();
    var ls = tokens.where((element) => element.nftData == null);
    var index = 0;
    for (CovalentToken token in ls) {
      if (index == 5) {
        break;
      }
      if (token.type == null || token.balance != "0") {
        index++;
        var tile = CoinListTile(
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

  _raisedButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RaisedButton(
          onPressed: () {
            // Navigator.pushNamed(context, coinListRoute);
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Text("View All Tokens", style: AppTheme.body2White),
          color: AppTheme.secondaryColor,
        )
      ],
    );
  }
}
