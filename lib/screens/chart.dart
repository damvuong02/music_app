import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: SfCartesianChart(
        title: ChartTitle(text: 'Stacked Line Chart'),
        legend: Legend(isVisible: true),
        series: <ChartSeries>[
          StackedLineSeries<Data, String>(
            dataSource: [
              Data('Category 1', 10, 15),
              Data('Category 2', 20, 25),
              Data('Category 3', 30, 35),
              // Add more data points as needed
            ],
            xValueMapper: (Data data, _) => data.category,
            yValueMapper: (Data data, _) => data.value1,
            // additionalYValueMapper: (Data data, _) => data.value2,
            // Add more additionalYValueMappers for additional series
          ),
        ],
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(),
      ),
    );
  }
}

class Data {
  final String category;
  final double value1;
  final double value2;

  Data(this.category, this.value1, this.value2);
}
