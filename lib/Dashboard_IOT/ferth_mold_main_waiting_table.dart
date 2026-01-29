import 'package:flutter/material.dart';
import 'package:headeguideiot/Dashboard_IOT/time_format.dart';
import 'package:collection/collection.dart';
import '../model/BatchAbnormalModel.dart';
import '../model/FerthModel.dart';
import '../model/ItemModel.dart';
import '../model/LotModel.dart';
import 'AnimatedIcon.dart';
import 'blinking_cell.dart';
import 'center_text.dart';
import 'centered_title_text.dart';
import 'error_items_provider.dart';
import 'ferth_mold_main_table.dart';
import 'package:collection/collection.dart' hide IterableExtension;

import 'status_container_cell.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class FerthMoldMainWaitingTable extends StatefulWidget {
  final List<FerthModel> ferthList;

  const FerthMoldMainWaitingTable({super.key, required this.ferthList});

  @override
  State<FerthMoldMainWaitingTable> createState() =>
      _FerthMoldMainWaitingTableState();
}

class _FerthMoldMainWaitingTableState extends State<FerthMoldMainWaitingTable> {
  @override
  void initState() {
    super.initState();
  }

  bool isItemAbnormal(ItemModel item) {
    DateTime computedStartTime = item.startTime ?? DateTime(2024, 3, 20, 0, 0);
    int estimatedTime = estimatedTimes[item.itemCheck] ?? 0;
    DateTime computedFinishTime = item.finishTime ??
        computedStartTime.add(Duration(minutes: estimatedTime));

    // bool isError = computedStartTime.isBefore(DateTime(2024, 3, 20, 0, 0).subtract(Duration(minutes: 30)));
    bool isOverdue = item.startTime != null &&
        item.finishTime == null &&
        DateTime.now().isAfter(computedFinishTime);

    return isOverdue;
  }

  int countAbnormalItems(List<ItemModel> items) {
    return items.where((item) => isItemAbnormal(item)).length;
  }

  @override
  void didUpdateWidget(covariant FerthMoldMainWaitingTable oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // Set để kiểm tra các lot đã xuất hiện
    Set<String> seenLots = {};

    // Tạo danh sách DataRow và lọc lot trùng
    List<TableRow> rows = [];
    int idCounter = 1;

    List<LotModel> sortLotsByErrorsAndSizeAndTime(List<FerthModel> ferthList) {
      List<LotModel> allLots = [];

      // Gom tất cả Lot từ mọi Ferth vào danh sách chung
      for (var ferth in ferthList) {
        allLots.addAll(ferth.lots);
      }

      // Sắp xếp danh sách Lots
      allLots.sort((a, b) {
        int errorCountA = countAbnormalItems(a.items);
        int errorCountB = countAbnormalItems(b.items);

        if (errorCountA == errorCountB) {
          if (a.items.length == b.items.length) {
            bool allFinishValidA = a.items.every((e) => e.finishTime != null);
            bool allFinishValidB = b.items.every((e) => e.finishTime != null);

            if (allFinishValidA != allFinishValidB) {
              return allFinishValidB ? 1 : -1;
            }

            // 🔍 Tìm StartTime của item chưa hoàn thành (FinishTime == null)
            ItemModel? unfinishedItemA = IterableExtension(a.items)
                .firstWhereOrNull((e) => e.finishTime == null);
            DateTime? unfinishedStartA = unfinishedItemA?.startTime;

            ItemModel? unfinishedItemB = IterableExtension(b.items)
                .firstWhereOrNull((e) => e.finishTime == null);
            DateTime? unfinishedStartB = unfinishedItemB?.startTime;

            if (unfinishedStartA != null && unfinishedStartB != null) {
              int unfinishedCompare =
                  unfinishedStartA.compareTo(unfinishedStartB);
              if (unfinishedCompare != 0) {
                return unfinishedCompare; // Ưu tiên Lot có unfinished StartTime sớm hơn
              }
            }

            var durationsA = a.items
                .where((e) => e.finishTime != null && e.startTime != null)
                .map((e) =>
                    e.finishTime!.difference(e.startTime!).inMilliseconds)
                .toList();

            int minDurationA = durationsA.isNotEmpty
                ? durationsA.reduce((min, e) => e < min ? e : min)
                : 0; // Hoặc giá trị mặc định khác

            var durationsB = b.items
                .where((e) => e.finishTime != null && e.startTime != null)
                .map((e) =>
                    e.finishTime!.difference(e.startTime!).inMilliseconds)
                .toList();

            int minDurationB = durationsB.isNotEmpty
                ? durationsB.reduce((min, e) => e < min ? e : min)
                : 0;

            int durationCompare = minDurationA.compareTo(minDurationB);
            if (durationCompare != 0) {
              return durationCompare; // Lot có Min Duration nhỏ hơn đứng trước
            }

            DateTime earliestStartA = a.items
                .where((e) => e.startTime != null)
                .map((e) => e.startTime!)
                .reduce((earliest, e) => e.isBefore(earliest) ? e : earliest);

            DateTime earliestStartB = b.items
                .where((e) => e.startTime != null)
                .map((e) => e.startTime!)
                .reduce((earliest, e) => e.isBefore(earliest) ? e : earliest);

            return earliestStartA.compareTo(earliestStartB);
          }

          return b.items.length.compareTo(a.items.length);
        }

        return errorCountB.compareTo(errorCountA);
      });

      return allLots;
    }

    // In danh sách sau khi sắp xếp
    List<LotModel> sortedLots =
        sortLotsByErrorsAndSizeAndTime(widget.ferthList);

    for (var lot in sortedLots) {
      if (seenLots.contains(lot.lot)) {
        continue;
      }
      seenLots.add(lot.lot);

      List<Widget> rowCells = [];

      rowCells.add(CenteredText(idCounter.toString(), Colors.grey));
      rowCells.add(
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          child: Tooltip(
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(10),
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace', // để dễ căn cột như bảng
            ),
            message: lot.info
                .map((e) =>
                    'POREQNO: ${e.poreqno} | Ferth: ${e.ferth} | Qty: ${e.qty} ')
                .join('\n'),
            child: SelectableText(
              '[${lot.rfID_key.toString().padLeft(2, '0')}]',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      );
      rowCells
          .addAll(_createRowCellsForItem(lot.items, idCounter.toString(), lot));

      while (rowCells.length < 13) {
        rowCells.add(const Text(''));
      }
      rows.add(TableRow(children: rowCells));
      idCounter++;
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          Container(
            color: Colors.blue,
            child: Table(
              border: TableBorder.all(color: Colors.black45, width: 1),
              // Viền bảng
              columnWidths: const {
                0: FixedColumnWidth(80), // Cột ID nhỏ hơn
                1: FixedColumnWidth(170), // Cột Lot nhỏ hơn
                2: FixedColumnWidth(135), // Wash_1
                3: FixedColumnWidth(135), // Quench
                4: FixedColumnWidth(135), // Cool_Fan_1
                5: FixedColumnWidth(135), // Wash_2
                6: FixedColumnWidth(135), // Cool_Fan_2
                7: FixedColumnWidth(135), // Temper_1
                8: FixedColumnWidth(135), // Cool_Fan_3
                9: FixedColumnWidth(135), // Temper_2
                10: FixedColumnWidth(135), // Cool_Fan_4
                11: FixedColumnWidth(135),
                12: FixedColumnWidth(135), // Qu
              },
              children: const [
                TableRow(children: [
                  const CenteredTitleText('ID'),
                  const CenteredTitleText('RFID'),
                  const CenteredTitleText('Wash_1'),
                  const CenteredTitleText('Quench'),
                  const CenteredTitleText('OilShower'),
                  const CenteredTitleText('Cool_Fan_1'),
                  const CenteredTitleText('Wash_2'),
                  const CenteredTitleText('Cool_Fan_2'),
                  const CenteredTitleText('Temper_1'),
                  const CenteredTitleText('Cool_Fan_3'),
                  const CenteredTitleText('Temper_2'),
                  const CenteredTitleText('Cool_Fan_4'),
                  const CenteredTitleText('Waiting'),
                ]),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Table(
              border: TableBorder.all(color: Colors.black45, width: 1),
              columnWidths: const {
                0: FixedColumnWidth(80), // Cột ID nhỏ hơn
                1: FixedColumnWidth(170), // Cột Lot nhỏ hơn
                2: FixedColumnWidth(135), // Wash_1
                3: FixedColumnWidth(135), // Quench
                4: FixedColumnWidth(135), // Cool_Fan_1
                5: FixedColumnWidth(135), // Wash_2
                6: FixedColumnWidth(135), // Cool_Fan_2
                7: FixedColumnWidth(135), // Temper_1
                8: FixedColumnWidth(135), // Cool_Fan_3
                9: FixedColumnWidth(135), // Temper_2
                10: FixedColumnWidth(135), // Cool_Fan_4
                11: FixedColumnWidth(135),
                12: FixedColumnWidth(135), // Qu
              },
              children: rows,
            ),
          ),
        ],
      ),
    );
  }

// Hàm tạo DataCell cho mỗi item trong lot
  List<Widget> _createRowCellsForItem(
      List<ItemModel> items, String id, LotModel lot) {
    List<String> checkTypes = [
      "Wash_1",
      "Quench",
      "OilShower",
      "Cool_Fan_1",
      "Wash_2",
      "Cool_Fan_2",
      "Temper_1",
      "Cool_Fan_3",
      "Temper_2",
      "Cool_Fan_4",
      "Waiting"
    ];
    DateTime previousFinishTime = DateTime(2024, 3, 20, 0, 0);
    List<Widget> rowCells = [];
    DateTime? quenchFinishTime; // 🔹 Lưu thời gian kết thúc của Quench
    DateTime? oilShowerFinishTime; // 🔹 Lưu thời gian kết thúc của Oil Shower
    DateTime? coolFan3FinishTime; // 🔹 Lưu thời gian kết thúc của Oil Shower
    List<int> validIndices = [];

    Set<Map<String, String>> currentOverdueItems =
        {}; // 🔹 Lưu {checkType, rowId}

    final errorItemsProvider =
        Provider.of<ErrorItemsProvider>(context, listen: false);

    for (int i = 0; i < checkTypes.length; i++) {
      String checkType = checkTypes[i];

      // String rowId = "row_$i"; // 🔹 ID của row

      final item = items.firstWhere(
        (item) => item.itemCheck == checkType,
        orElse: () => ItemModel.basic(itemCheck: checkType),
      );

      DateTime? startTime = item.startTime;
      DateTime? finishTime = item.finishTime;

      if (startTime != null && finishTime != null) {
        validIndices.add(i);
      }

      int estimatedTime = estimatedTimes[checkType] ?? 0;
      DateTime computedStartTime = startTime ?? previousFinishTime;
      DateTime computedFinishTime =
          finishTime ?? computedStartTime.add(Duration(minutes: estimatedTime));

      if (checkType == "Quench") {
        // quenchFinishTime = computedFinishTime; // Cập nhật finishTime của Quench
        quenchFinishTime = item.finishTime; // Cập nhật finishTime của Quench
      }

      if (checkType == "OilShower") {
        // oilShowerFinishTime =
        //     computedFinishTime; // ✅ Lưu thời gian kết thúc OilShower
        oilShowerFinishTime = item.finishTime;
      }

      bool isWarning = false;
      if (checkType == "OilShower" && startTime == null) {
        DateTime now = DateTime.now();
        DateTime? computedFinishTimeNG =
            quenchFinishTime?.add(const Duration(hours: 1));
        DateTime? remainTime =
            computedFinishTimeNG?.subtract(const Duration(minutes: 30));
        DateTime? recommendedStartTime =
            computedFinishTimeNG?.subtract(const Duration(minutes: 30));

        if (now.isAfter(remainTime!)) {
          isWarning = true;
          print(
              "⚠ Warning: OilShower should start within the next 30 minutes!");
          print(
              "⏳ Recommended Start Time: ${formatFullDate(recommendedStartTime)}");
        }
      }
      // 🔥 Cảnh báo nếu Temper_1 chưa bắt đầu và còn 3 tiếng đến hạn
      if (checkType == "Temper_1" && startTime == null) {
        DateTime now = DateTime.now();
        DateTime? computedFinishTimeNG =
            quenchFinishTime?.add(const Duration(hours: 24));
        DateTime? remainTime =
            computedFinishTimeNG?.subtract(const Duration(minutes: 180));
        DateTime? recommendedStartTime =
            computedFinishTimeNG?.subtract(const Duration(minutes: 180));

        if (now.isAfter(remainTime!)) {
          isWarning = true;
          print(
              "⚠ Warning: Temper_1 should start within the next 180 minutes!");
          print(
              "⏳ Recommended Start Time: ${formatFullDate(recommendedStartTime)}");
        }
      }

// 🔥 Kiểm tra lỗi thời gian
      const int toleranceMinutes = 1;
      bool isError;
      String errorComment = ''; // ✅ Thêm biến để lưu loại lỗi

      isError = computedStartTime.isBefore(previousFinishTime
          .subtract(const Duration(minutes: toleranceMinutes)));

      if (isError) {
        errorComment = 'Start time is earlier than allowed';
      }

      bool isErrorNG = false;
      List<String> validMachines = ["A-1389", "A-1520"];
      // 🔥 Kiểm tra nếu Temper_1 - OilShower >  60 phút
      if (checkType == "OilShower" &&
          finishTime != null &&
          !validMachines.contains(item.machine)) {
        int diffMinutes =
            computedFinishTime.difference(quenchFinishTime!).inMinutes;
        if (diffMinutes > 60) {
          isError = true;
          isErrorNG = true;
          errorComment = 'Temper_1 - OilShower time > 60 minutes';
        }
      }

      // 🔥 Kiểm tra nếu Cool_Fan_3 - OilShower > 24 giờ
      if (checkType == "Cool_Fan_3" && finishTime != null) {
        int diffMinutes =
            computedFinishTime.difference(oilShowerFinishTime!).inMinutes;
        if (diffMinutes > 1440) {
          isError = true;
          isErrorNG = true;
          errorComment = 'Cool_Fan_3 - OilShower time > 24 hours';
        }
      }

      if (checkType == "Quench" && validMachines.contains(item.machine)) {
        isError = false;
      }

      // 🔥 TÍNH TỶ LỆ TIẾN ĐỘ (progress)
      double progress = 1.0; // Mặc định là 100%
      bool isInProgress = false; // Đang chạy
      bool isOverdue = false; // Bị trễ hạn

      if (startTime != null) {
        if (finishTime == null) {
          // Chỉ tính progress nếu chưa có finishTime
          Duration totalDuration =
              computedFinishTime.difference(computedStartTime);
          Duration elapsedDuration =
              DateTime.now().difference(computedStartTime);

          progress = (elapsedDuration.inMinutes / totalDuration.inMinutes)
              .clamp(0.0, 1.0);
          isInProgress = true; // Đánh dấu đang thực hiện
          // 🔴 Kiểm tra nếu đã quá hạn nhưng chưa hoàn thành
          if (DateTime.now().isAfter(computedFinishTime)) {
            isOverdue = true;
            currentOverdueItems.add({"checkType": checkType, "rowId": id});
          }
        }
      }

      // 🎨 Xác định màu sắc trực quan hơn
      Color startColor = Colors.blue.withOpacity(0.8);
      Color endColor = isInProgress
          ? Colors.blue.withOpacity(0.2) // Đậm hơn nếu đang thực hiện
          : startColor;

      if (isOverdue) {
        int overdueMinutes =
            DateTime.now().difference(computedFinishTime).inMinutes;

        // Nếu quá hạn >= 10 phút thì dùng màu đậm nhất (0.8 opacity)
        double opacity =
            (0.1 + (overdueMinutes / 30) * (0.8 - 0.4)).clamp(0.4, 0.8);

        startColor = Colors.orange.withOpacity(opacity);
        endColor = Colors.yellow
            .withOpacity(opacity + 0.1); // Chênh lệch nhẹ để tạo gradient
      }

      // 📌 Gradient với nhiều mức độ hơn
      List<Color> progressColors = [
        startColor,
        HSVColor.fromColor(startColor).withValue(0.9).toColor(),
        // Chuyển màu mượt hơn
        endColor
      ];

      rowCells.add(
        BlinkingCell(
          isOverdue: isOverdue,
          isWarning: isWarning,
          child: Tooltip(
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(10),
            textStyle: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            message: () {
              if (isError && isErrorNG) {
                if (checkType == "OilShower" && finishTime != null) {
                  return "⚠️ Delay Error\nTime gap between Quench and OilShower exceeds 60 minutes!"
                      "\nOilShower End: ${formatFullDate(computedFinishTime)}"
                      "\nMachine: ${item.machine}";
                } else if (checkType == "Cool_Fan_3" && finishTime != null) {
                  return "⚠️ Delay Error\nTime gap between OilShower and Cool_Fan_3 exceeds 24 hours!"
                      "\nTemper_1 End: ${formatFullDate(computedFinishTime)}"
                      "\nMachine: ${item.machine}";
                }
              } else if (isWarning) {
                if (checkType == "OilShower") {
                  return "⚠️ Warning!\nOilShower should start within the next 30 minutes!"
                      "\nExpected finish: ${formatFullDate(computedFinishTime)}"
                      "\nMachine: ${item.machine}";
                } else if (checkType == "Temper_1") {
                  return "⚠️ Warning!\nTemper_1 should start within the next 180 minutes!"
                      "\nExpected finish: ${formatFullDate(computedFinishTime)}"
                      "\nMachine: ${item.machine}";
                }
              } else if (isError) {
                return "⚠️ Schedule Error\n"
                    "Start time: ${formatFullDate(startTime)} is too early!"
                    "\nMachine: ${item.machine}";
              } else if (isOverdue) {
                return "⚠️ Overdue!\nExpected finish: ${formatFullDate(computedFinishTime)}"
                    "\nMachine: ${item.machine}";
              } else if (startTime != null && finishTime == null) {
                return "Start: ${formatFullDate(startTime)}"
                    "\nExpected finish: ${formatFullDate(computedFinishTime)}"
                    "\nMachine: ${item.machine}";
              } else if (startTime != null && finishTime != null) {
                return "Start: ${formatFullDate(startTime)}"
                    "\nFinish: ${formatFullDate(finishTime)}"
                    "\nMachine: ${item.machine}";
              } else {
                return "Expected start: ${formatFullDate(computedStartTime)}"
                    "\nExpected finish: ${formatFullDate(computedFinishTime)}";
              }
            }(),
            child: StatusContainer(
                isOverdue: isOverdue,
                isInProgress: isInProgress,
                isError: isError,
                isWarning: isWarning,
                progress: progress,
                progressColors: progressColors,
                computedFinishTime: computedFinishTime,
                startTime: startTime,
                finishTime: finishTime,
                child: buildStatusRow(
                    isOverdue: isOverdue,
                    isWarning: isWarning,
                    isInProgress: isInProgress,
                    isError: isError,
                    items: items,
                    checkType: checkType,
                    computedStartTime: computedStartTime)),
          ),
        ),
      );

      previousFinishTime = computedFinishTime;
    }

    return rowCells;
  }

  Widget buildStatusRow({
    required bool isOverdue,
    required bool isWarning,
    required bool isInProgress,
    required bool isError,
    required dynamic items,
    required dynamic checkType,
    required DateTime computedStartTime,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isOverdue || isWarning)
          const AnimatedIconWidget(
            icon: Icons.warning_amber,
            color: Colors.red,
            size: 16,
            animationType: AnimationType.pulse,
            duration: Duration(milliseconds: 800),
          ),
        if (isInProgress)
          const AnimatedIconWidget(
            icon: Icons.schedule,
            color: Colors.orange,
            size: 16,
            animationType: AnimationType.rotate,
            duration: Duration(seconds: 3),
          ),
        _createDataCell(items, checkType, computedStartTime),
      ],
    );
  }

  String formatFullDateBasic(DateTime? dateTime) {
    if (dateTime == null) return "N/A";
    return "${dateTime.day.toString().padLeft(2, '0')}/"
        "${dateTime.month.toString().padLeft(2, '0')}/"
        "${dateTime.year} "
        "${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')}";
  }

  String formatFullDate(DateTime? dateTime) {
    return DateFormat("dd/MMM/yy HH:mm:ss").format(dateTime!);
  }

  String formatTime(DateTime? time) {
    if (time == null) {
      return '--:--'; // Hiển thị mặc định nếu không có thời gian
    }
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  final Map<String, int> estimatedTimes = {
    "Wash_1": 30,
    "Quench": 180,
    "OilShower": 15,
    "Cool_Fan_1": 60,
    "Wash_2": 30,
    "Cool_Fan_2": 60,
    "Temper_1": 150,
    "Cool_Fan_3": 60,
    "Temper_2": 150,
    "Cool_Fan_4": 60,
    "Waiting": 1440
  };

// Hàm tạo DataCell theo itemCheck và thời gian
  Widget _createDataCell(
      List<ItemModel> items, String checkType, DateTime previousFinishTime) {
    final item = items.firstWhere(
      (item) => item.itemCheck == checkType,
      orElse: () => ItemModel.basic(itemCheck: checkType),
    );

    // Lấy thời gian dự kiến từ Map
    int estimatedTime = estimatedTimes[checkType] ?? 0;

    // Kiểm tra nếu startTime chưa có thì sử dụng previousFinishTime
    bool isEstimatedStartTime = item.startTime == null;
    DateTime startTime = item.startTime ?? previousFinishTime;

    // Kiểm tra nếu finishTime chưa có thì sử dụng estimatedTime
    bool isEstimatedFinishTime = item.finishTime == null;
    DateTime finishTime =
        item.finishTime ?? startTime.add(Duration(minutes: estimatedTime));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: TimeTooltip(
        startTime: startTime,
        finishTime: finishTime,
        isEstimatedStartTime: isEstimatedStartTime,
        isEstimatedFinishTime: isEstimatedFinishTime,
      ),
    );
  }
}
