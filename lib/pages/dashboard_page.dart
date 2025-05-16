import 'package:flutter/material.dart';
import '../widgets/CustomAppbar.dart';
import '../widgets/CustomSidebar.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomSidebar(), // Sidebar
      body: Builder(
        builder: (scaffoldContext) {
          return Column(
            children: [
              // Custom AppBar
              CustomAppBar(
                title: 'Dashboard', // Set the title of the app bar
                showBackButton: false,
                leading: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(scaffoldContext).openDrawer(); // Open sidebar
                  },
                ),
              ),
              // Dashboard content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dashboard Overview',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Expense Card
                    _buildCard('Total Expenses', '\u{20B9} 1,234.56', Colors.red),
                    const SizedBox(height: 16),
                    // Income Card
                    _buildCard('Total Income', '\u{20B9} 5,000.00', Colors.green),
                    const SizedBox(height: 16),
                    // Balance Card
                    _buildCard('Balance', '\u{20B9} 3,765.44', Colors.blue),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // A simple method to create a card with a title, amount, and color
  Widget _buildCard(String title, String amount, Color color) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              amount,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
