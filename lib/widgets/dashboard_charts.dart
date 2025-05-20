// dashboard_chart.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartData {
  final String category;
  final double amount;
  final Color color;

  ChartData(this.category, this.amount, this.color);
}

class DashboardChart extends StatelessWidget {
  final List<ChartData> incomeChartData;
  final List<ChartData> expenseChartData;
  final TooltipBehavior tooltipBehavior;
  final void Function(String category, String type)? onCategoryTap;

  const DashboardChart({
    super.key,
    required this.incomeChartData,
    required this.expenseChartData,
    required this.tooltipBehavior,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              isWide
                  ? Row(
                    children: [
                      Expanded(child: _buildChart("Expense", expenseChartData)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildChart("Income", incomeChartData)),
                    ],
                  )
                  : Column(
                    children: [
                      _buildChart("Expense", expenseChartData),
                      const SizedBox(height: 24),
                      _buildChart("Income", incomeChartData),
                    ],
                  ),
        );
      },
    );
  }

  Widget _buildChart(String title, List<ChartData> data) {
    if (data.isEmpty) {
      return Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'No data to show analysis for.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
        ],
      );
    }
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 200,
          child: SfCircularChart(
            legend: Legend(
              isVisible: true,
              overflowMode: LegendItemOverflowMode.wrap,
              position: LegendPosition.right,
            ),
            tooltipBehavior: tooltipBehavior,
            series: <CircularSeries>[
              PieSeries<ChartData, String>(
                dataSource: data,
                xValueMapper: (ChartData data, _) => data.category,
                yValueMapper: (ChartData data, _) => data.amount,
                pointColorMapper: (ChartData data, _) => data.color,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
                onPointTap: (details) {
                  if (onCategoryTap != null) {
                    onCategoryTap!(
                      title.toLowerCase(),
                      data[details.pointIndex!].category,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
