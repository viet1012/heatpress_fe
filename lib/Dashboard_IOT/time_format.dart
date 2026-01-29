import 'package:flutter/material.dart';

class TimeTooltip extends StatelessWidget {
  final DateTime? startTime;
  final DateTime? finishTime;
  final bool isEstimatedStartTime;
  final bool isEstimatedFinishTime;

  const TimeTooltip({
    Key? key,
    required this.startTime,
    required this.finishTime,
    this.isEstimatedStartTime = false,
    this.isEstimatedFinishTime = false,
  }) : super(key: key);

  String formatFullDate(DateTime? dateTime) {
    if (dateTime == null) return "N/A";
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  String formatTime(DateTime? time) {
    if (time == null) {
      return '--:--'; // Hiển thị mặc định nếu không có thời gian
    }
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: "${formatTime(startTime)}  ",
            style: TextStyle(
              color: isEstimatedStartTime ? Colors.grey.shade600 : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          TextSpan(
            text: "${formatTime(finishTime)}",
            style: TextStyle(
              color: isEstimatedFinishTime ? Colors.grey.shade600 : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
