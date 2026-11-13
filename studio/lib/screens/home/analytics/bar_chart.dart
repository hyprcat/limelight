import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LineChartSample2 extends StatefulWidget {
  const LineChartSample2({super.key});

  @override
  State<LineChartSample2> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  bool showAvg = false;

  List<Color> gradientColors = [
    Colors.green,
    Colors.green,
  ];

  @override
  Widget build(BuildContext context) {
    final List<SalesData> chartData = [
      SalesData(DateTime(2019), 0),
      SalesData(DateTime(2020), 0),
      SalesData(DateTime(2021), 0),
      SalesData(DateTime(2022), 0),
      SalesData(DateTime(2023), 0)
    ];
    return SfCartesianChart(primaryXAxis: DateTimeAxis(), series: <ChartSeries>[
      // Renders line chart
      LineSeries<SalesData, DateTime>(
          dataSource: chartData, xValueMapper: (SalesData sales, _) => sales.year, yValueMapper: (SalesData sales, _) => sales.sales)
    ]);
  }
}

class SalesData {
  SalesData(this.year, this.sales);
  final DateTime year;
  final double sales;
}
