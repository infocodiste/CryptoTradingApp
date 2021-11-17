import 'package:coin_analyzer/constants.dart';
import 'package:flutter/material.dart';

import '../theme_data.dart';

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.paddingHeight12),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Image.asset(appIcon),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
