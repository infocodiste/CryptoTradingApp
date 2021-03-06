import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color backgroundWhite = Color(0xffF3F2EF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color somewhatYellow = Color(0xffE3DECF);
  static const Color primaryColor = Color(0xFFEB5B56);
  static const Color secondaryColor = Color(0xff26241E);
  static const Color black = Color(0xFF000000);
  static const Color warningCardColor = Color(0xFFD38A6B);
  static const Color lightgray_700 = Color(0xFFFFFFFF);

  static const Color warmgray_100 = Color(0xFFE8E6E1);
  static const Color warmgray_200 = Color(0xFFD2CDC5);
  static const Color warmgray_300 = Color(0xFFB6B1A8);
  static const Color warmgray_600 = Color(0xFF605D52);
  static const Color warmgray_900 = Color(0xFF26241E);

  static const Color orange_500 = Color(0xFFEB5B56);

  static const Color yellow_500 = Color(0xFFE7B549);

  static const Color red_500 = Color(0xFFDE524C);
  static const Color red_600 = Color(0xFFCB3A31);

  static const Color teal_500 = Color(0xFF24A8AF);

  static const Color grey = Color(0xFF3A5160);
  static const Color stackingGrey = Color(0xFFF3F2EF);
  static const Color purpleSelected = Color(0xFF7854C5);
  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Color(0xFF17262A);
  static const Color lightText = Color(0xFF4A6572);
  static const Color deactivatedText = Color(0xFF767676);
  static const Color dismissibleBackground = Color(0xFF364A54);
  static const Color whiteTextColor = Color(0xFFEEF1F3);
  static const Color spacer = Color(0xFFF2F2F2);
  static const Color tabbarBGColor = Color(0xFFE7E3D8);
  static const Color borderColorGreyish = Color(0xFFDCDFE6);
  static const Color buttonColorBlue = Color(0xFF003CB2);
  static const Color warmGrey = Color(0xFFE8E6E1);
  static const Color warmGrey_900 = Color(0xff26241E);
  static const String primaryHex = "#D287FD";
  static const double buttonRadius = 4;
  static const double buttonHeight_44 = 44;

  static const double cardRadius = 12;
  static const double cardRadiusMedium = 14;
  static const double cardRadiusBig = 16;
  static const double cardRadiusSmall = 10;
  static const double cardElevations = 0;
  static const String fontName = 'WorkSans';
  static const double tokenIconHeight = 34;
  static const double tokenIconSizeBig = 70;
  static const double paddingHeight = 16;
  static const double paddingHeight12 = 12;
  static const double paddingHeight20 = 20;
  static const Color orangeGradientStart = Color(0xffFEB38B);
  static const Color orangeGradientEnd = Color(0xffEB5A55);

  static const textTheme = TextTheme(
    bodyText1: body1,
    bodyText2: body2,
    headline1: headline,
    subtitle1: title,
    subtitle2: subtitle,
  );
  static const TextStyle display1 = TextStyle(
    // h4 -> display1
    fontWeight: FontWeight.bold,
    fontSize: 36,
    letterSpacing: 0.4,
    height: 0.9,
    color: darkerText,
  );
  static const TextStyle display2 = TextStyle(
    // h4 -> display1
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.4,
    height: 0.9,
    color: darkerText,
  );

  static const TextStyle headline = TextStyle(
    // h5 -> headline
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.27,
    color: darkerText,
  );
  static const TextStyle headline_grey = TextStyle(
      // h5 -> headline
      fontFamily: fontName,
      fontWeight: FontWeight.bold,
      fontSize: 22,
      letterSpacing: 0.27,
      color: warmgray_300);
  static const TextStyle bigLabel = TextStyle(
    // h5 -> headline
    fontFamily: fontName,
    fontWeight: FontWeight.w300,
    fontSize: 25,
    letterSpacing: 0.27,
    color: darkerText,
  );

  static const TextStyle title = TextStyle(
    // h6 -> title
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 0.18,
    color: darkerText,
  );

  static const TextStyle grey_title = TextStyle(
    // h6 -> title
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 0.18,
    color: warmgray_600,
  );
  static const TextStyle subtitle = TextStyle(
    // subtitle2 -> subtitle
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: -0.04,
    color: lightText,
  );

  static const TextStyle body2 = TextStyle(
    // body1 -> body2
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.2,
    color: darkText,
  );

  static const TextStyle body2White = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.2,
    color: white,
  );

  static const TextStyle body1 = TextStyle(
    // body2 -> body1
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: -0.05,
    color: darkText,
  );

  static const TextStyle body_small = TextStyle(
    // body2 -> body1
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.2,
    color: warmgray_600,
  );
  static const TextStyle body_small_bold = TextStyle(
    // body2 -> body1
    fontFamily: fontName,
    fontWeight: FontWeight.w500,
    fontSize: 13,
    letterSpacing: 0.2,
    color: warmgray_600,
  );

  static const TextStyle body_xsmall = TextStyle(
    // body2 -> body1
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.2,
    color: orange_500,
  );

  static const TextStyle body_medium = TextStyle(
    // body2 -> body1
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: 0.24,
    color: red_600,
  );

  static const TextStyle buttonText = TextStyle(
    // Caption -> caption
    fontFamily: fontName,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    letterSpacing: 0.3,
    color: whiteTextColor, // was lightText
  );
  static const TextStyle buttonTextSecondary = TextStyle(
    // Caption -> caption
    fontFamily: fontName,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    letterSpacing: 0.3,
    color: Colors.white, // was lightText
  );

  static const TextStyle balanceMain = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: -0.2,
    color: black,
  );
  static const TextStyle balanceSub = TextStyle(
    fontWeight: FontWeight.w400,
    fontFamily: fontName,
    fontSize: 14,
    color: black, // was lightText
  );
  static const TextStyle listTileTitle = TextStyle(
      fontWeight: FontWeight.w600,
      fontFamily: fontName,
      fontSize: 16,
      color: black,
      letterSpacing: -0.2 // was lightText
      );
  static const TextStyle boldThemeColoredText = TextStyle(
      fontWeight: FontWeight.w700,
      fontFamily: fontName,
      fontSize: 36,
      color: primaryColor,
      letterSpacing: -1 // was lightText
      );
  static const TextStyle tabbarTextStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontFamily: fontName,
    fontSize: 14,
    letterSpacing: -0.2,
    color: black, // was lightText
  );

  static const TextStyle textW600White14 = TextStyle(
    fontWeight: FontWeight.w600,
    fontFamily: fontName,
    fontSize: 14,
    letterSpacing: -0.2,
    color: white, // was lightText
  );

  static const TextStyle titleWhite = TextStyle(
    fontWeight: FontWeight.w600,
    fontFamily: fontName,
    fontSize: 16,
    color: white, // was lightText
  );
  static const TextStyle bodyW40016 = TextStyle(
    // Caption -> caption
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: 0.2,
    color: black, // was lightText
  );

  static const TextStyle header_H5 = TextStyle(
    // h6 -> title
    fontFamily: fontName,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    letterSpacing: 0.18,
    color: warmgray_900,
  );
  static const TextStyle header_H4_Black = TextStyle(
    // h6 -> title
    fontFamily: fontName,
    fontWeight: FontWeight.w600,
    fontSize: 18,
    letterSpacing: 0.28,
    color: warmGrey_900,
  );
  static const TextStyle header_H4 = TextStyle(
    // h6 -> title
    fontFamily: fontName,
    fontWeight: FontWeight.w700,
    fontSize: 18,
    letterSpacing: 0.28,
    color: orange_500,
  );

  static const TextStyle label_medium = TextStyle(
    // h6 -> title
    fontFamily: fontName,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    letterSpacing: 0.2,
    color: warmgray_900,
  );

  static const TextStyle label_xsmall = TextStyle(
    // h6 -> title
    fontFamily: fontName,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    letterSpacing: 0.2,
    color: warmgray_900,
  );

  static const TextStyle caption_normal = TextStyle(
    // h6 -> title
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.16,
    color: warmgray_300,
  );
  static const TextStyle subtitle_primary_color = TextStyle(
    // subtitle2 -> subtitle
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: -0.04,
    color: primaryColor,
  );
  static const cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(cardRadius)));

  static final ThemeData lightTheme = new ThemeData(
      primarySwatch: Colors.purple,
      brightness: Brightness.light,
      accentColor: Colors.purpleAccent[100],
      primaryColor: Colors.white,
      primaryColorLight: Colors.purple[700],
      primaryColorDark: Color(0xFF102957),
      backgroundColor: backgroundWhite,
      textSelectionHandleColor: Colors.purple[700],
      dividerColor: Colors.grey[200],
      bottomAppBarColor: Colors.grey[200],
      buttonColor: Colors.purple[700],
      iconTheme: new IconThemeData(color: Colors.black),
      primaryIconTheme: new IconThemeData(color: Colors.black),
      accentIconTheme: new IconThemeData(color: Colors.purple[700]),
      disabledColor: Colors.grey[500],
      // inputDecorationTheme: const InputDecorationTheme(
      //   labelStyle: TextStyle(color: Colors.white),
      //   hintStyle: TextStyle(color: Colors.grey),
      // ),
      textTheme: TextTheme(
        bodyText2: body1,
        bodyText1: body2,
        headline5: headline,
        headline6: title,
        subtitle2: subtitle,
      ));

  static final ThemeData darkTheme = new ThemeData(
      primarySwatch: Colors.purple,
      brightness: Brightness.dark,
      accentColor: Colors.deepPurpleAccent[100],
      primaryColor: Color.fromRGBO(50, 50, 57, 1.0),
      primaryColorLight: Color(0xFF102957),
      primaryColorDark: Colors.purple[700],
      backgroundColor: Color(0xFF001434),
      textSelectionHandleColor: Colors.deepPurpleAccent[100],
      buttonColor: Colors.deepPurpleAccent[100],
      iconTheme: new IconThemeData(color: Colors.white),
      primaryIconTheme: new IconThemeData(color: Colors.white),
      accentIconTheme: new IconThemeData(color: Colors.deepPurpleAccent[100]),
      // cardColor: Colors.deepPurpleAccent[100],
      // dividerColor: Color.fromRGBO(60, 60, 60, 1.0),
      dividerColor: Colors.blueGrey,
      bottomAppBarColor: Colors.black26,
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(color: Colors.black),
        hintStyle: TextStyle(color: Colors.grey),
      ),
      textTheme: TextTheme(
        bodyText2: TextStyle(
          fontFamily: fontName,
          fontWeight: FontWeight.w400,
          fontSize: 16,
          letterSpacing: -0.05,
          color: whiteTextColor,
        ),
        bodyText1: TextStyle(
          // body1 -> body2
          fontFamily: fontName,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          letterSpacing: 0.2,
          color: whiteTextColor,
        ),
        headline5: TextStyle(
          // h5 -> headline
          fontFamily: fontName,
          fontWeight: FontWeight.bold,
          fontSize: 24,
          letterSpacing: 0.27,
          color: whiteTextColor,
        ),
        headline6: TextStyle(
          // h6 -> title
          fontFamily: fontName,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          letterSpacing: 0.18,
          color: whiteTextColor,
        ),
        subtitle2: TextStyle(
          // subtitle2 -> subtitle
          fontFamily: fontName,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          letterSpacing: -0.04,
          color: whiteTextColor,
        ),
      ));

  static final ThemeData darkThemeOLED = new ThemeData(
    brightness: Brightness.dark,
    accentColor: Colors.deepPurpleAccent[100],
    primaryColor: Color.fromRGBO(5, 5, 5, 1.0),
    backgroundColor: Colors.black,
    canvasColor: Colors.black,
    primaryColorLight: Colors.deepPurple[300],
    buttonColor: Colors.deepPurpleAccent[100],
    accentIconTheme: new IconThemeData(color: Colors.deepPurple[300]),
    cardColor: Color.fromRGBO(16, 16, 16, 1.0),
    dividerColor: Color.fromRGBO(20, 20, 20, 1.0),
    bottomAppBarColor: Color.fromRGBO(19, 19, 19, 1.0),
    dialogBackgroundColor: Colors.black,
    textSelectionHandleColor: Colors.deepPurpleAccent[100],
    iconTheme: new IconThemeData(color: Colors.white),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.white),
      hintStyle: TextStyle(color: Colors.grey),
    ),
  );
}
