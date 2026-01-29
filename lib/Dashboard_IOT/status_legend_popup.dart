import 'package:flutter/material.dart';
import 'package:headeguideiot/Dashboard_IOT/time_table.dart';

class StatusLegendPopup {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Status Description",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                StatusLegendPopup.buildLegendItem(Colors.blue.withOpacity(0.8),
                    "Completed", Colors.green, Colors.black),
                const SizedBox(width: 24),
                StatusLegendPopup.buildLegendIconItem(
                    "Now", Icons.schedule, Colors.orange, Colors.black),
                const SizedBox(width: 24),
                StatusLegendPopup.buildLegendIconItem(
                    "Overdue", Icons.warning_amber, Colors.red, Colors.black),
              ],
            ),
            const SizedBox(height: 16),
            TimeTable(),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue.shade600, // Màu nền đẹp
              foregroundColor: Colors.white, // Màu chữ trắng
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Bo góc nhẹ
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Close",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildLegendIconItem(
      String label, IconData icon, Color colorIcon, Color colorLabel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            color: colorIcon,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(fontSize: 18, color: colorLabel),
          ),
        ],
      ),
    );
  }

  static Widget buildLegendItem(
      Color color, String label, Color colorIcon, Color colorLabel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(fontSize: 18, color: colorLabel),
          ),
        ],
      ),
    );
  }
}
