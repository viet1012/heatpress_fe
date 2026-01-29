import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/FerthModel.dart';
import '../model/ItemModel.dart';
import '../model/LotModel.dart';
import 'AnimatedIcon.dart';
import 'blinking_cell.dart';
import 'center_text.dart';
import 'centered_title_text.dart';
import 'custom_tooltip.dart';
import 'status_container_cell.dart';
import 'package:headeguideiot/Dashboard_IOT/time_format.dart';

// ===============================
// MAIN TABLE
// ===============================
class FerthMainMoldTable extends StatefulWidget {
  final List<FerthModel> ferthList;
  const FerthMainMoldTable({super.key, required this.ferthList});

  @override
  State<FerthMainMoldTable> createState() => _FerthMainMoldTableState();
}

class _FerthMainMoldTableState extends State<FerthMainMoldTable> {
  // ===============================
  // CONFIG / CONSTANTS
  // ===============================
  static final DateTime kDefaultStart = DateTime(2024, 3, 20, 0, 0);

  static const Map<String, int> estimatedTimes = {
    "Wash_1": 0,
    "Quench": 15,
    "OilShower": 15,
    "Wash_2": 15,
    "Cool_Fan_1": 30,
    "Temper_1": 150,
    "Cool_Fan_2": 60,
  };

  static const List<String> checkTypes = [
    "Quench",
    "Wash_2",
    "Cool_Fan_1",
    "Temper_1",
    "Cool_Fan_2",
    "HRC_1",
    // "HRC_2", // nếu sau này cần thì thêm vào đây + header/columnWidths
  ];

  static const int scheduleToleranceMinutes = 1;

  // Lưu finishTime của Quench để check Temper_1
  DateTime? quenchFinishTime;

  // ===============================
  // ABNORMAL / ERROR COUNT
  // ===============================
  bool isItemAbnormal(ItemModel item) {
    final computed = _computeTimes(item, fallbackStart: kDefaultStart);
    final computedFinish = computed.computedFinishTime;

    final isOverdue = item.startTime != null &&
        item.finishTime == null &&
        DateTime.now().isAfter(computedFinish);

    return isOverdue;
  }

  int countAbnormalItems(List<ItemModel> items) =>
      items.where(isItemAbnormal).length;

  // ===============================
  // SORT LOTS
  // ===============================
  List<LotModel> sortLotsByErrorsAndSizeAndTime(List<FerthModel> ferthList) {
    final allLots = <LotModel>[];
    for (final ferth in ferthList) {
      allLots.addAll(ferth.lots);
    }

    allLots.sort((a, b) {
      final errorCountA = countAbnormalItems(a.items);
      final errorCountB = countAbnormalItems(b.items);

      // 1) ưu tiên nhiều lỗi hơn
      if (errorCountA != errorCountB) {
        return errorCountB.compareTo(errorCountA);
      }

      // 2) nếu lỗi bằng nhau -> ưu tiên lot nhiều item hơn
      if (a.items.length != b.items.length) {
        return b.items.length.compareTo(a.items.length);
      }

      // 3) ưu tiên lot có all finishTime != null trước
      final allFinishValidA = a.items.every((e) => e.finishTime != null);
      final allFinishValidB = b.items.every((e) => e.finishTime != null);
      if (allFinishValidA != allFinishValidB) {
        return allFinishValidB ? 1 : -1;
      }

      // 4) nếu cả 2 đều có unfinished -> so theo earliest start
      final hasUnfinishedA = a.items.any((e) => e.finishTime == null);
      final hasUnfinishedB = b.items.any((e) => e.finishTime == null);
      if (hasUnfinishedA && hasUnfinishedB) {
        final earliestStartA = _earliestStart(a.items) ?? DateTime(9999);
        final earliestStartB = _earliestStart(b.items) ?? DateTime(9999);
        return earliestStartA.compareTo(earliestStartB);
      }

      // 5) min duration
      final minDurationA = _minDurationMs(a.items) ?? 999999999;
      final minDurationB = _minDurationMs(b.items) ?? 999999999;

      if (minDurationA != minDurationB) {
        return minDurationA.compareTo(minDurationB);
      }

      // 6) fallback earliest start
      final earliestStartA = _earliestStart(a.items) ?? DateTime(9999);
      final earliestStartB = _earliestStart(b.items) ?? DateTime(9999);
      return earliestStartA.compareTo(earliestStartB);
    });

    return allLots;
  }

  DateTime? _earliestStart(List<ItemModel> items) {
    final starts =
        items.where((e) => e.startTime != null).map((e) => e.startTime!);
    if (starts.isEmpty) return null;
    return starts.reduce((a, b) => a.isBefore(b) ? a : b);
  }

  int? _minDurationMs(List<ItemModel> items) {
    final durations = items
        .where((e) => e.startTime != null && e.finishTime != null)
        .map((e) => e.finishTime!.difference(e.startTime!).inMilliseconds)
        .toList();
    if (durations.isEmpty) return null;
    return durations.reduce((min, e) => e < min ? e : min);
  }

  // ===============================
  // BUILD
  // ===============================
  @override
  Widget build(BuildContext context) {
    final seenLots = <String>{};
    final rows = <TableRow>[];
    int idCounter = 1;

    final sortedLots = sortLotsByErrorsAndSizeAndTime(widget.ferthList);

    for (final lot in sortedLots) {
      if (seenLots.contains(lot.lot)) continue;
      seenLots.add(lot.lot);

      final cells = <Widget>[];

      // ID
      cells.add(CenteredText("$idCounter", Colors.grey));

      // RFID + tooltip (HRC note + PO info)
      final hrcNotes = _extractHrcNotes(lot);
      cells.add(_buildRfidCell(lot, hrcNotes));

      // Item cells
      cells.addAll(_createRowCellsForItem(
        lot.items,
        "$idCounter",
        lot,
        hrcNotes.hrc1,
        hrcNotes.hrc2,
      ));

      while (cells.length < 9) {
        cells.add(const SizedBox.shrink());
      }

      rows.add(TableRow(children: cells));
      idCounter++;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Table(
                  border: TableBorder.all(color: Colors.black45, width: 1),
                  columnWidths: const {
                    0: FixedColumnWidth(80),
                    1: FixedColumnWidth(170),
                    2: FixedColumnWidth(135),
                    3: FixedColumnWidth(135),
                    4: FixedColumnWidth(135),
                    5: FixedColumnWidth(135),
                    6: FixedColumnWidth(135),
                    7: FixedColumnWidth(135),
                  },
                  children: rows,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.blue,
      child: Table(
        border: TableBorder.all(color: Colors.black45, width: 1),
        columnWidths: const {
          0: FixedColumnWidth(80),
          1: FixedColumnWidth(170),
          2: FixedColumnWidth(135),
          3: FixedColumnWidth(135),
          4: FixedColumnWidth(135),
          5: FixedColumnWidth(135),
          6: FixedColumnWidth(135),
          7: FixedColumnWidth(135),
        },
        children: const [
          TableRow(children: [
            CenteredTitleText('ID'),
            CenteredTitleText('RFID'),
            CenteredTitleText('Induction'),
            CenteredTitleText('Wash_2'),
            CenteredTitleText('Cool_Fan_1'),
            CenteredTitleText('Temper_1'),
            CenteredTitleText('Cool_Fan_2'),
            CenteredTitleText('HRC_1'),
          ])
        ],
      ),
    );
  }

  // ===============================
  // RFID CELL + HRC NOTES
  // ===============================
  _HrcNotes _extractHrcNotes(LotModel lot) {
    String hrc1 = "";
    String hrc2 = "";

    final info = lot.info;

    final hrc1Info = info.where((e) => e.itemCheckFinal == 'HRC_1').isNotEmpty
        ? info.firstWhere((e) => e.itemCheckFinal == 'HRC_1')
        : null;

    final hrc2Info = info.where((e) => e.itemCheckFinal == 'HRC_2').isNotEmpty
        ? info.firstWhere((e) => e.itemCheckFinal == 'HRC_2')
        : null;

    if (hrc1Info != null) hrc1 = hrc1Info.note ?? "";
    if (hrc2Info != null) hrc2 = hrc2Info.note ?? "";

    return _HrcNotes(hrc1: hrc1, hrc2: hrc2);
  }

  Widget _buildRfidCell(LotModel lot, _HrcNotes hrcNotes) {
    final icNotePart = (() {
      if (hrcNotes.hrc1.isNotEmpty || hrcNotes.hrc2.isNotEmpty) {
        final parts = <String>[];
        if (hrcNotes.hrc1.isNotEmpty) {
          parts.add('HRC BF TEMP: ${hrcNotes.hrc1}');
        }
        if (hrcNotes.hrc2.isNotEmpty) {
          parts.add('HRC AF TEMP: ${hrcNotes.hrc2}');
        }
        return parts.join(' & ');
      }
      return 'HRC BF TEMP';
    })();

    final details = (() {
      final firstWithPoreqnos = (() {
        try {
          return lot.info.firstWhere((e) => e.poreqnosWithQty.isNotEmpty);
        } catch (_) {
          return null;
        }
      })();

      if (firstWithPoreqnos != null) {
        return firstWithPoreqnos.poreqnosWithQty.replaceAll(' ; ', '\n');
      }
      return 'No PO info';
    })();

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: CustomTooltip(
        icNotePart: icNotePart,
        details: details,
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
    );
  }

  // ===============================
  // ROW CELLS
  // ===============================
  List<Widget> _createRowCellsForItem(
    List<ItemModel> items,
    String rowId,
    LotModel lot,
    String valueHRC_1,
    String valueHRC_2,
  ) {
    DateTime previousFinishTime = kDefaultStart;
    final rowCells = <Widget>[];

    // reset for each row
    quenchFinishTime = null;

    for (final checkType in checkTypes) {
      final item = _findItem(items, checkType);

      // HRC cell (special)
      if (checkType == "HRC_1" || checkType == "HRC_2") {
        final hrcValue = (checkType == "HRC_1") ? valueHRC_1 : valueHRC_2;
        rowCells.add(_buildHrcCell(hrcValue));
        continue;
      }

      final computed = _computeTimes(
        item,
        fallbackStart: previousFinishTime,
      );

      // nếu previousFinishTime < now và startTime null -> move expected start to now (giữ logic bạn đang có)
      final adjusted = _adjustStartIfNeeded(
        item: item,
        computed: computed,
      );

      final computedStartTime = adjusted.computedStartTime;
      final computedFinishTime = adjusted.computedFinishTime;

      // Quench finish cache
      if (checkType == "Quench" && item.finishTime != null) {
        quenchFinishTime = computedFinishTime;
      }

      final isError = _isScheduleError(
        checkType: checkType,
        item: item,
        computedStartTime: computedStartTime,
        previousFinishTime: previousFinishTime,
      );

      final isWarning = _isWarning(
        checkType: checkType,
        item: item,
        computedFinishTime: computedFinishTime,
      );

      final state = _computeProgressState(
        item: item,
        computedStartTime: computedStartTime,
        computedFinishTime: computedFinishTime,
      );

      final progressColors = _progressColors(
        isOverdue: state.isOverdue,
        isInProgress: state.isInProgress,
      );

      rowCells.add(
        BlinkingCell(
          isOverdue: state.isOverdue,
          isWarning: isWarning,
          child: Tooltip(
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(10),
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            message: _buildTooltipMessage(
              isError: isError,
              isOverdue: state.isOverdue,
              item: item,
              computedStartTime: computedStartTime,
              computedFinishTime: computedFinishTime,
            ),
            child: StatusContainer(
              isOverdue: state.isOverdue,
              isInProgress: state.isInProgress,
              isError: isError,
              progress: state.progress,
              isWarning: isWarning,
              progressColors: progressColors,
              computedFinishTime: computedFinishTime,
              startTime: item.startTime,
              finishTime: item.finishTime,
              child: buildStatusRow(
                isOverdue: state.isOverdue,
                isInProgress: state.isInProgress,
                isError: isError,
                items: items,
                checkType: checkType,
                computedStartTime: computedStartTime,
              ),
            ),
          ),
        ),
      );

      previousFinishTime = computedFinishTime;
    }

    return rowCells;
  }

  ItemModel _findItem(List<ItemModel> items, String checkType) {
    return items.firstWhere(
      (e) => e.itemCheck == checkType,
      orElse: () => ItemModel.basic(itemCheck: checkType),
    );
  }

  Widget _buildHrcCell(String hrcValue) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: hrcValue.isNotEmpty ? Colors.blue.withOpacity(0.8) : Colors.white,
      child: Text(
        hrcValue,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ===============================
  // TIME COMPUTATION HELPERS
  // ===============================
  _ComputedTimes _computeTimes(ItemModel item,
      {required DateTime fallbackStart}) {
    final estimated = estimatedTimes[item.itemCheck] ?? 0;

    final computedStart = item.startTime ?? fallbackStart;
    final computedFinish =
        item.finishTime ?? computedStart.add(Duration(minutes: estimated));

    return _ComputedTimes(
      computedStartTime: computedStart,
      computedFinishTime: computedFinish,
      estimatedMinutes: estimated,
    );
  }

  _ComputedTimes _adjustStartIfNeeded({
    required ItemModel item,
    required _ComputedTimes computed,
  }) {
    // giữ nguyên logic bạn đang có
    if (computed.computedStartTime.isBefore(DateTime.now()) &&
        item.startTime == null) {
      final now = DateTime.now();
      return _ComputedTimes(
        computedStartTime: now,
        computedFinishTime:
            now.add(Duration(minutes: computed.estimatedMinutes)),
        estimatedMinutes: computed.estimatedMinutes,
      );
    }
    return computed;
  }

  bool _isScheduleError({
    required String checkType,
    required ItemModel item,
    required DateTime computedStartTime,
    required DateTime previousFinishTime,
  }) {
    // Rule Temper_1 - start - quenchFinish > 24h
    if (checkType == "Temper_1" &&
        item.startTime != null &&
        quenchFinishTime != null) {
      final diffMinutes =
          item.startTime!.difference(quenchFinishTime!).inMinutes;
      if (diffMinutes > 1440) {
        return true;
      }
    }

    // Rule start too early compared to previous finish
    final threshold = previousFinishTime.subtract(
      const Duration(minutes: scheduleToleranceMinutes),
    );
    return computedStartTime.isBefore(threshold);
  }

  bool _isWarning({
    required String checkType,
    required ItemModel item,
    required DateTime computedFinishTime,
  }) {
    if (checkType == "OilShower" && item.startTime == null) {
      final now = DateTime.now();
      final remainTime =
          computedFinishTime.subtract(const Duration(minutes: 15));
      return now.isAfter(remainTime);
    }
    return false;
  }

  _ProgressState _computeProgressState({
    required ItemModel item,
    required DateTime computedStartTime,
    required DateTime computedFinishTime,
  }) {
    double progress = 1.0;
    bool isInProgress = false;
    bool isOverdue = false;

    if (item.startTime != null && item.finishTime == null) {
      final total = computedFinishTime.difference(computedStartTime);
      final elapsed = DateTime.now().difference(computedStartTime);

      final totalMinutes = total.inMinutes == 0 ? 1 : total.inMinutes;
      progress = (elapsed.inMinutes / totalMinutes).clamp(0.0, 1.0);

      isInProgress = true;
      if (DateTime.now().isAfter(computedFinishTime)) {
        isOverdue = true;
      }
    }

    return _ProgressState(
      progress: progress,
      isInProgress: isInProgress,
      isOverdue: isOverdue,
    );
  }

  List<Color> _progressColors({
    required bool isOverdue,
    required bool isInProgress,
  }) {
    Color start = Colors.blue.withOpacity(0.8);
    Color end = isInProgress ? Colors.blue.withOpacity(0.2) : start;

    if (isOverdue) {
      start = Colors.red.withOpacity(0.8);
      end = Colors.red.withOpacity(0.4);
    }

    return [
      start,
      HSVColor.fromColor(start).withValue(0.9).toColor(),
      end,
    ];
  }

  String _buildTooltipMessage({
    required bool isError,
    required bool isOverdue,
    required ItemModel item,
    required DateTime computedStartTime,
    required DateTime computedFinishTime,
  }) {
    final startTime = item.startTime;
    final finishTime = item.finishTime;

    if (isError) {
      return "⚠️ Schedule Error\nStart time: ${formatFullDate(startTime)} is too early!\nMachine: ${item.machine}";
    }
    if (isOverdue) {
      return "⚠️ Overdue!\nExpected finish: ${formatFullDate(computedFinishTime)}\nMachine: ${item.machine}";
    }
    if (startTime != null && finishTime == null) {
      return "Start: ${formatFullDate(startTime)}\nExpected finish: ${formatFullDate(computedFinishTime)}\nMachine: ${item.machine}";
    }
    if (startTime != null && finishTime != null) {
      return "Start: ${formatFullDate(startTime)}\nFinish: ${formatFullDate(finishTime)}\nMachine: ${item.machine}";
    }
    return "Expected start: ${formatFullDate(computedStartTime)}\nExpected finish: ${formatFullDate(computedFinishTime)}";
  }

  // ===============================
  // STATUS ROW
  // ===============================
  Widget buildStatusRow({
    required bool isOverdue,
    required bool isInProgress,
    required bool isError,
    required List<ItemModel> items,
    required String checkType,
    required DateTime computedStartTime,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isOverdue)
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
            duration: Duration(seconds: 2),
          ),
        if (isError)
          const Icon(Icons.error_outline, color: Colors.black, size: 16),
        _createDataCell(items, checkType, computedStartTime),
      ],
    );
  }

  // ===============================
  // TIME CELL
  // ===============================
  Widget _createDataCell(
    List<ItemModel> items,
    String checkType,
    DateTime previousFinishTime,
  ) {
    final item = _findItem(items, checkType);

    final estimated = estimatedTimes[checkType] ?? 0;

    final isEstimatedStartTime = item.startTime == null;
    final startTime = item.startTime ?? previousFinishTime;

    final isEstimatedFinishTime = item.finishTime == null;
    final finishTime =
        item.finishTime ?? startTime.add(Duration(minutes: estimated));

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

  // ===============================
  // FORMATTERS
  // ===============================
  String formatFullDateBasic(DateTime? dateTime) {
    if (dateTime == null) return "N/A";
    return "${dateTime.day.toString().padLeft(2, '0')}/"
        "${dateTime.month.toString().padLeft(2, '0')}/"
        "${dateTime.year} "
        "${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')}";
  }

  String formatFullDate(DateTime? dateTime) {
    if (dateTime == null) return "N/A";
    return DateFormat("dd/MMM/yy HH:mm:ss").format(dateTime);
  }

  String formatTime(DateTime? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

// ===============================
// SMALL HELPERS
// ===============================
class _HrcNotes {
  final String hrc1;
  final String hrc2;
  const _HrcNotes({required this.hrc1, required this.hrc2});
}

class _ComputedTimes {
  final DateTime computedStartTime;
  final DateTime computedFinishTime;
  final int estimatedMinutes;
  const _ComputedTimes({
    required this.computedStartTime,
    required this.computedFinishTime,
    required this.estimatedMinutes,
  });
}

class _ProgressState {
  final double progress;
  final bool isInProgress;
  final bool isOverdue;
  const _ProgressState({
    required this.progress,
    required this.isInProgress,
    required this.isOverdue,
  });
}
