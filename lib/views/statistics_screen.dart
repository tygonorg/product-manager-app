import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:product_manager_app/controllers/statistics_controller.dart';
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart

class StatisticsScreen extends StatelessWidget {
  final StatisticsController controller = Get.find<StatisticsController>(); // Use Get.find

  StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê'),
      ),
      body: Obx(() {
        if (controller.productSales.isEmpty &&
            controller.categorySales.isEmpty &&
            controller.monthlySales.isEmpty &&
            controller.quarterlySales.isEmpty &&
            controller.yearlySales.isEmpty) {
          return const Center(
            child: Text('Không có dữ liệu thống kê.'),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChartSelectionDropdown(),
              const SizedBox(height: 16),
              _buildSalesChart(),
              const SizedBox(height: 24),
              _buildSectionTitle('Thống kê sản phẩm đã bán'),
              _buildProductSalesList(),
              const SizedBox(height: 24),
              _buildSectionTitle('Thống kê doanh thu theo tháng'),
              _buildSalesList(controller.monthlySales),
              const SizedBox(height: 24),
              _buildSectionTitle('Thống kê doanh thu theo quý'),
              _buildSalesList(controller.quarterlySales),
              const SizedBox(height: 24),
              _buildSectionTitle('Thống kê doanh thu theo năm'),
              _buildSalesList(controller.yearlySales),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildChartSelectionDropdown() {
    return Obx(
      () => DropdownButton<String>(
        value: controller.selectedChartType.value,
        onChanged: (String? newValue) {
          if (newValue != null) {
            controller.setSelectedChartType(newValue);
          }
        },
        items: const <DropdownMenuItem<String>>[
          DropdownMenuItem<String>(
            value: 'product',
            child: Text('Theo sản phẩm'),
          ),
          DropdownMenuItem<String>(
            value: 'category',
            child: Text('Theo danh mục'),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart() {
    final data = controller.selectedChartType.value == 'product'
        ? controller.productSales
        : controller.categorySales;

    if (data.isEmpty) {
      return const Center(
        child: Text('Không có dữ liệu để vẽ biểu đồ.'),
      );
    }

    final List<PieChartSectionData> sections = [];
    int i = 0;
    data.forEach((name, value) {
      final color = Colors.primaries[i % Colors.primaries.length];
      sections.add(
        PieChartSectionData(
          color: color,
          value: value.toDouble(),
          title: '${value}',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      i++;
    });

    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
          sectionsSpace: 2,
          startDegreeOffset: -90,
          borderData: FlBorderData(show: false),
          pieTouchData: PieTouchData(enabled: false), // Disable touch for simplicity
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildProductSalesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.productSales.length,
      itemBuilder: (context, index) {
        final productName = controller.productSales.keys.elementAt(index);
        final quantity = controller.productSales.values.elementAt(index);
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            title: Text(productName),
            trailing: Text('Đã bán: $quantity'),
          ),
        );
      },
    );
  }

  Widget _buildSalesList(Map<String, double> salesData) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: salesData.length,
      itemBuilder: (context, index) {
        final period = salesData.keys.elementAt(index);
        final amount = salesData.values.elementAt(index);
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            title: Text(period),
            trailing: Text(
              NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount),
            ),
          ),
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(
    this.text,
    this.color,
    {
    required this.size,
  });
  final String text;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      padding: const EdgeInsets.all(4.0),
      child: FittedBox(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
