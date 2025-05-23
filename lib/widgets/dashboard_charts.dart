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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildChart("Expense", expenseChartData)),
                      const SizedBox(width: 24),
                      Expanded(child: _buildChart("Income", incomeChartData)),
                    ],
                  )
                  : Column(
                    children: [
                      _buildChart("Expense", expenseChartData),
                      const SizedBox(height: 32),
                      _buildChart("Income", incomeChartData),
                    ],
                  ),
        );
      },
    );
  }

  Widget _buildChart(String title, List<ChartData> data) {
    final total = data.fold<double>(0, (sum, item) => sum + item.amount);

    if (data.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 16),
              // Chart
              SizedBox(
                height: 200,
                width: 200,
                child: SfCircularChart(
                  tooltipBehavior: tooltipBehavior,
                legend: const Legend(isVisible: false), // Hide default legend
                series: <CircularSeries>[
                  DoughnutSeries<ChartData, String>(
                    animationDuration: 1500,
                    dataSource: data,
                    radius: '100%',
                    innerRadius: '60%',
                    xValueMapper: (ChartData d, _) => d.category,
                    yValueMapper: (ChartData d, _) => d.amount,
                    pointColorMapper: (ChartData d, _) => d.color,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: false,
                    ),
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
              const SizedBox(width: 16),

              // Custom Legend (no Expanded here)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: data.map((d) {
                  final percentage = total == 0 ? 0 : (d.amount / total * 100);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: d.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          d.category,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
