import 'package:coin_analyzer/utils/misc/credential_manager.dart';
import 'package:coin_analyzer/utils/misc/wc_handler.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../theme_data.dart';

class AppLandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.paddingHeight12),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Image.asset(appIcon, width: 200, height: 200),
                ),
                // Container(
                //   width: MediaQuery.of(context).size.width,
                //   height: AppTheme.buttonHeight_44,
                //   margin: EdgeInsets.symmetric(
                //       horizontal: AppTheme.paddingHeight12),
                //   child: TextButton(
                //     style: TextButton.styleFrom(
                //         backgroundColor: AppTheme.orange_500,
                //         elevation: 0,
                //         shape: RoundedRectangleBorder(
                //             borderRadius:
                //                 BorderRadius.circular(AppTheme.buttonRadius))),
                //     onPressed: () {
                //       Navigator.of(context).pushNamed(createWalletRoute);
                //     },
                //     child: Text(
                //       'Create a new account',
                //       style: AppTheme.label_medium
                //           .copyWith(color: AppTheme.lightgray_700),
                //     ),
                //   ),
                // ),
                // SizedBox(
                //   height: AppTheme.paddingHeight / 2,
                // ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: AppTheme.buttonHeight_44,
                  margin: EdgeInsets.symmetric(
                      horizontal: AppTheme.paddingHeight12),
                  child: TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: AppTheme.red_500,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22))),
                    onPressed: () {
                      Navigator.pushNamed(context, importWalletRoute,
                          arguments: {'seeds': true});
                    },
                    child: Text(
                      'Import using Secret Recovery Phase',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  height: AppTheme.paddingHeight / 2,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: AppTheme.buttonHeight_44,
                  margin: EdgeInsets.symmetric(
                      horizontal: AppTheme.paddingHeight12),
                  child: TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: AppTheme.orange_500,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22))),
                    onPressed: () {
                      Navigator.pushNamed(context, importWalletRoute,
                          arguments: {'seeds': false});
                    },
                    child: Text(
                      'Import using Private key',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  height: AppTheme.paddingHeight / 2,
                ),
                // Container(
                //   width: MediaQuery.of(context).size.width,
                //   height: AppTheme.buttonHeight_44,
                //   margin: EdgeInsets.symmetric(
                //       horizontal: AppTheme.paddingHeight12),
                //   child: TextButton(
                //     style: TextButton.styleFrom(
                //         backgroundColor: AppTheme.orange_500,
                //         elevation: 0,
                //         shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(22))),
                //     onPressed: () {
                //       WCHandler.connect(context);
                //     },
                //     child: Text(
                //       'Sync with MetaMask',
                //       style: TextStyle(color: Colors.white),
                //       // style: AppTheme.label_medium,
                //     ),
                //   ),
                // ),
                // SizedBox(
                //   height: AppTheme.paddingHeight / 2,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
