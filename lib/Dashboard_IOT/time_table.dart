import 'package:flutter/material.dart';
import 'package:headeguideiot/Dashboard_IOT/blinking_cell.dart';

class TimeTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildTable("Quench", "OilShower", "04:27  05:08", "05:38  06:08", Colors.grey[600]!,
                isWarning: true),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SizedBox(
                width: 400, // Giới hạn chiều rộng, bạn có thể điều chỉnh
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                    // Style mặc định
                    children: const [
                      TextSpan(
                          text: "Cảnh báo: \n",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orangeAccent)),
                      TextSpan(
                          text: "-Trước Start:",
                      ),
                      TextSpan(
                          text: " 15 phút (đối với Oil Shower), 120 phút (đối với Tempering).\n",
                          style: TextStyle(
                              fontWeight: FontWeight.bold)),
                      TextSpan(
                        text: "-Đã đến thời gian nhưng chưa",
                      ),
                      TextSpan(
                          text: " Finish\n",
                          style: TextStyle(
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            buildTable("Quench", "OilShower", "04:27  05:00", "05:10  06:30",Colors.black,
                isError: true),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SizedBox(
                width: 400, // Giới hạn chiều rộng, bạn có thể điều chỉnh
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                    // Style mặc định
                    children: const [
                      TextSpan(
                          text: "Lỗi: \n",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.red)),
                      TextSpan(text: "-Thời gian "),
                      TextSpan(
                          text: "Oil Quenching Finish~Oil Shower Finish > 60 phút.\n",
                          style: TextStyle(
                              fontWeight: FontWeight.bold)),
                      TextSpan(text: "-Thời gian "),
                      TextSpan(
                          text: "Oil Shower Finish~Cool Fan 3 (sau Tempering 1) Finish > 24 giờ.\n",
                          style: TextStyle(
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildTable(String title1, String title2, String time1, String time2,Color colorTime,
      {bool isError = false, bool isOverdue = false, bool isWarning = false}) {
    return Column(
      children: [
        // Hàng tiêu đề
        Row(
          children: [
            buildCell(title1, isHeader: true),
            buildCell(title2, isHeader: true),
          ],
        ),
        // Hàng dữ liệu
        Row(
          children: [
            buildCell(time1),
            BlinkingCell(
              isOverdue: isOverdue,
              isWarning: isWarning,
              child: buildStatusCell(time2,colorTime,
                  isError: isError, isWarning: isWarning, isOverdue: isOverdue),
            ),
          ],
        ),
      ],
    );
  }

  /// Ô bình thường (header hoặc dữ liệu)
  Widget buildCell(String text, {bool isHeader = false}) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isHeader ? Colors.blue : Colors.white,
        border: Border.all(color: Colors.black, width: .5),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: isHeader ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget buildStatusCell(String time,
      Color colorText,
      {bool isError = false,
      bool isOverdue = false,
      bool isWarning = false,
      bool isInProgress = false}) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: _getGradient(isError, isOverdue, isWarning, isInProgress),
        // Áp dụng Gradient
        border: Border.all(color: Colors.red, width: 1), // Viền đỏ nếu cảnh báo
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // if (isError)
          //   const Icon(Icons.error_outline, color: Colors.black, size: 20),
          if (isOverdue || isWarning)
            const Icon(Icons.warning_amber, color: Colors.red, size: 20),
          // if (isError || isOverdue || isWarning) const SizedBox(width: 4),
          // const Icon(Icons.access_time, color: Colors.white, size: 20),
          // Đồng hồ
          const SizedBox(width: 8),
          Text(
            time,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorText),
          ),
        ],
      ),
    );
  }

  LinearGradient? _getGradient(
      bool isError, bool isOverdue, bool isWarning, bool isInProgress) {
    if (isError) {
      return LinearGradient(
        colors: [Colors.red, Colors.red.withOpacity(0.5)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    } else if (isOverdue) {
      return LinearGradient(
        colors: [Colors.orange, Colors.red.withOpacity(0.8)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    } else if (isWarning) {
      return LinearGradient(
        colors: [Colors.orangeAccent, Colors.yellow.withOpacity(0.8)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    } else if (isInProgress) {
      return LinearGradient(
        colors: [Colors.blue, Colors.blue.withOpacity(0.5)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    }
    return null; // Nếu không có trạng thái nào, bỏ gradient
  }
}
