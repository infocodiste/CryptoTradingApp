import 'dart:math' as math;

import 'package:coin_analyzer/models/covalent_models/token_history.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionTile extends StatelessWidget {
  final TransferInfo data;
  final String address;

  const TransactionTile({Key key, this.data, this.address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool sent =
        (data?.transfers[0]?.decoded?.params[0]?.value ?? "") == address;
    BigInt amount =
        BigInt.parse(data?.transfers[0]?.decoded?.params[2]?.value ?? "");
    var value = amount / BigInt.from(10).pow(18);
    var f = NumberFormat('0.00################', 'en_Us');
    var value1 = f.format(value);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Card(
            margin: EdgeInsets.only(right: 12),
            child: Container(
              padding: EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.d().format(DateTime.parse(data.blockSignedAt)),
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(fontSize: 20),
                  ),
                  Text(
                    DateFormat.MMM().format(DateTime.parse(data.blockSignedAt)),
                    style: Theme.of(context).textTheme.subtitle2,
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: ListTile(
              // isThreeLine: true,
              contentPadding: EdgeInsets.zero,
              minVerticalPadding: 0,
              horizontalTitleGap: 0,
              minLeadingWidth: 64,
              trailing: sent
                  ? Transform.rotate(
                      angle: -math.pi / 4,
                      child: Icon(
                        Icons.arrow_right_alt_outlined,
                        color: Colors.redAccent,
                      ),
                    )
                  : Transform.rotate(
                      angle: math.pi / 1.35,
                      child: Icon(
                        Icons.arrow_right_alt_outlined,
                        color: Colors.teal,
                      ),
                    ),
              title: Text(
                sent
                    ? "${data.transfers[0].decoded.params[1].value}"
                    : "${data.transfers[0].decoded.params[0].value}",
                // data.transfers[0].decoded.name,
                style: Theme.of(context).textTheme.subtitle1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                value1,
                style: Theme.of(context).textTheme.headline6.copyWith(
                    color: sent ? Colors.redAccent : Colors.lightGreen),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
