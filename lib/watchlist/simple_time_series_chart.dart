import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import "dart:math";

import 'package:intl/intl.dart';
import 'package:local_database/local_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class TimeSeriesPrice {
  DateTime time;
  double price;

  TimeSeriesPrice(this.time, this.price);
}

class SimpleTimeSeriesChart extends StatefulWidget {
  final String period, id;

  final int startTime;

  SimpleTimeSeriesChart(this.id, this.startTime, this.period);

  @override
  _SimpleTimeSeriesChartState createState() => _SimpleTimeSeriesChartState();
}

class _SimpleTimeSeriesChartState extends State<SimpleTimeSeriesChart> {
  List<TimeSeriesPrice> seriesList;
  double count = 0.0;
  double selectedPrice = -1.0;
  DateTime selectedTime;
  bool canLoad = true, loading = true;
  int base;
  num minVal, maxVal;

  num _exchangeRate;
  String _symbol;

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();

    http
        .get(Uri.parse(
            "https://api.coincap.io/v2/assets/${widget.id}/history?interval=" +
                widget.period +
                "&start=" +
                now
                    .subtract(Duration(days: widget.startTime))
                    .millisecondsSinceEpoch
                    .toString() +
                "&end=" +
                now.millisecondsSinceEpoch.toString()))
        .then((value) async {
      await getData();
      seriesList = createChart(json.decode(value.body), widget.id);
      setState(() {
        loading = false;
      });
      base = minVal >= 0 ? max(0, (-log(minVal) / log(10)).ceil() + 2) : 0;
      if (minVal <= 1.1 && minVal > .9) {
        base++;
      }
    });
  }

  Map<String, int> dataPerDay = {
    "m5": 288,
    "m30": 48,
    "h2": 12,
    "h12": 2,
    "d1": 1
  };

  Map<String, DateFormat> formatMap = {
    "m5": DateFormat("h꞉mm a"),
    "m30": DateFormat.MMMd(),
    "h2": DateFormat.MMMd(),
    "h12": DateFormat.MMMd(),
    "d1": DateFormat.MMMd(),
  };

  getData() async {
    Database _userData =
        Database((await getApplicationDocumentsDirectory()).path);
    Map<String, dynamic> _conversionMap = await _userData["conversionMap"];
    Map<String, dynamic> _settings = await _userData["settings"];
    var conversionData = _conversionMap[_settings["currency"]];
    _exchangeRate = conversionData["rate"];
    _symbol = conversionData["symbol"];
  }

  @override
  Widget build(BuildContext context) {
    bool hasData = seriesList != null &&
        seriesList.length > (widget.startTime * dataPerDay[widget.period] / 10);
    double dif, factor, visMax, visMin;
    DateFormat xFormatter = formatMap[widget.period];
    NumberFormat yFormatter = NumberFormat.currency(
        symbol: _symbol.toString().replaceAll("\.", ""),
        locale: "en_US",
        decimalDigits: base);
    if (!loading && hasData) {
      dif = (maxVal - minVal);
      factor = min(1, max(.2, dif / maxVal));
      visMin = max(0, minVal - dif * factor);
      visMax = visMin != 0 ? maxVal + dif * factor : maxVal + minVal;
    }
    return !loading && canLoad && hasData
        ? Container(
            // width: 350.0 * MediaQuery.of(context).size.width / 375.0,
            // height: 200.0,
            child: SfSparkLineChart.custom(
              trackball: SparkChartTrackball(
                  activationMode: SparkChartActivationMode.tap),
              //Enable marker
              // marker: SparkChartMarker(
              //     displayMode: SparkChartMarkerDisplayMode.all),
              //Enable data label
              // labelDisplayMode: SparkChartLabelDisplayMode.all,
              xValueMapper: (int index) => seriesList[index].time,
              yValueMapper: (int index) => seriesList[index].price,
              dataCount: seriesList.length,
            ),
            // child: SfCartesianChart(
            //   series: [
            //     LineSeries<TimeSeriesPrice, DateTime>(
            //         dataSource: seriesList,
            //         xValueMapper: (TimeSeriesPrice s, _) => s.time,
            //         yValueMapper: (TimeSeriesPrice s, _) => s.price,
            //         animationDuration: 0,
            //         color: Colors.blue)
            //   ],
            //   plotAreaBackgroundColor: Colors.transparent,
            //   primaryXAxis: DateTimeAxis(dateFormat: xFormatter),
            //   primaryYAxis: NumericAxis(
            //       numberFormat: yFormatter,
            //       decimalPlaces: base,
            //       visibleMaximum: visMax,
            //       visibleMinimum: visMin,
            //       interval: (visMax - visMin) / 4.001),
            //   selectionGesture: ActivationMode.singleTap,
            //   selectionType: SelectionType.point,
            //   onAxisLabelRender: (a) {
            //     if (a.orientation == AxisOrientation.vertical) {
            //       a.text = yFormatter.format(a.value);
            //     } else {
            //       a.text = xFormatter
            //           .format(DateTime.fromMillisecondsSinceEpoch(a.value));
            //     }
            //   },
            //   trackballBehavior: TrackballBehavior(
            //       activationMode: ActivationMode.singleTap,
            //       enable: true,
            //       shouldAlwaysShow: true,
            //       tooltipSettings: InteractiveTooltip(
            //           color: Colors.white,
            //           format: "point.x | point.y",
            //           decimalPlaces: base)),
            //   onTrackballPositionChanging: (a) {
            //     var v = a.chartPointInfo.chartDataPoint;
            //     a.chartPointInfo.label =
            //         "${xFormatter.format(v.x)} | ${yFormatter.format(v.y)}";
            //   },
            // ),
          )
        : canLoad && (hasData || loading)
            ? Container(
                height: 233.0,
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [CircularProgressIndicator()]))
            : Container(
                height: 233.0,
                child: Center(
                    child: Text("Sorry, this coin graph is not supported",
                        style: TextStyle(fontSize: 17.0))));
  }

  List<TimeSeriesPrice> createChart(Map<String, dynamic> info, String s) {
    List<TimeSeriesPrice> data = [];

    if (info != null && info.length > 1) {
      for (int i = 0; i < info["data"].length; i++) {
        num val = num.parse(info["data"][i]["priceUsd"]) * _exchangeRate;
        minVal = min(minVal ?? val, val);
        maxVal = max(maxVal ?? val, val);
        data.add(TimeSeriesPrice(
            DateTime.fromMillisecondsSinceEpoch(info["data"][i]["time"]), val));
      }
    } else {
      canLoad = false;
    }
    return data;
  }
}
