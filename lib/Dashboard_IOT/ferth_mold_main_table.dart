import 'dart:math';

import 'package:flutter/material.dart';
import 'package:headeguideiot/api_service.dart';
import 'package:headeguideiot/model/BatchAbnormalModel.dart';
import 'package:headeguideiot/model/ItemModel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/FerthModel.dart';
import '../model/LotModel.dart';
import '../model/abnormal_count.dart';
import '../model/abnormal_status.dart';
import 'AnimatedIcon.dart';
import 'blinking_cell.dart';
import 'center_text.dart';
import 'centered_title_text.dart';
import 'custom_tooltip.dart';
import 'error_items_provider.dart';
import 'ferth_mold_main_waiting_table.dart';
import 'status_container_cell.dart';
import 'package:headeguideiot/Dashboard_IOT/time_format.dart';

class FerthMoldMainTable extends StatefulWidget {
  final List<FerthModel> ferthList;

  const FerthMoldMainTable({
    super.key,
    required this.ferthList,
  });

  @override
  State<FerthMoldMainTable> createState() => _FerthMoldMainTableState();
}

class _FerthMoldMainTableState extends State<FerthMoldMainTable> {
  // ===============================
  // UI STATE
  // ===============================
  bool _showWaitingItems = false;
  bool _isLoading = false;
  List<FerthModel> moldMainWaitings = [];

  // Auto Scroll
  final ScrollController _verticalScrollController = ScrollController();

  // ===============================
  // CONSTANTS / CONFIG
  // ===============================
  static final DateTime kDefaultStart = DateTime(2024, 3, 20, 0, 0);
  static const int kToleranceMinutes = 1;

  static const List<String> kCheckTypes = [
    "Wash_1",
    "Quench",
    "OilShower",
    "Cool_Fan_1",
    "Wash_2",
    "Cool_Fan_2",
    "HRC_1",
    "Temper_1",
    "Cool_Fan_3",
    "HRC_2",
    "Temper_2",
    "Cool_Fan_4",
    "Waiting",
  ];

  static const Map<String, int> estimatedTimes = {
    "Wash_1": 60,
    "Quench": 180,
    "OilShower": 15,
    "Cool_Fan_1": 60,
    "Wash_2": 60,
    "Cool_Fan_2": 60,
    "Temper_1": 150,
    "Cool_Fan_3": 60,
    "Temper_2": 150,
    "Cool_Fan_4": 60,
    "Waiting": 1440,
  };

  // ===============================
  // FETCH WAITING
  // ===============================
  Future<void> _fetchDataMoldMainWaiting() async {
    final fetched = await ApiService()
        .fetchDataFromApiFindDailyHeatGuideMoldAndMainWaitingOT();
    moldMainWaitings = fetched;
  }

  // ===============================
  // ABNORMAL STATUS (for sorting)
  // ===============================
  AbnormalStatus getItemAbnormalStatus(
    ItemModel item,
    DateTime previousFinishTime, {
    required DateTime? quenchFinishTime,
    required DateTime? oilShowerFinishTime,
  }) {
    final checkType = item.itemCheck;
    final estimatedTime = estimatedTimes[checkType] ?? 0;

    final startTime = item.startTime;
    final finishTime = item.finishTime;

    bool isError = false;
    bool isOverdue = false;

    // 1) Sai thứ tự
    if (startTime != null && startTime.isBefore(previousFinishTime)) {
      isError = true;
    }

    // 2) OilShower: <= 60 phút sau Quench, và không được trước Quench
    if (checkType == "OilShower" &&
        startTime != null &&
        quenchFinishTime != null) {
      final diff = startTime.difference(quenchFinishTime).inMinutes;
      if (diff > 60 || diff < 0) isError = true;
    }

    // 3) Cool_Fan_3: <= 24h sau OilShower, và không được trước OilShower
    if (checkType == "Cool_Fan_3" &&
        startTime != null &&
        oilShowerFinishTime != null) {
      final diff = startTime.difference(oilShowerFinishTime).inMinutes;
      if (diff > 1440 || diff < 0) isError = true;
    }

    // 4) Overdue: start != null, finish == null, estimated > 0
    if (startTime != null && finishTime == null && estimatedTime > 0) {
      final expectedFinish = startTime.add(Duration(minutes: estimatedTime));
      if (DateTime.now().isAfter(expectedFinish)) isOverdue = true;
    }

    return AbnormalStatus(isError: isError, isOverdue: isOverdue);
  }

  AbnormalCount countAbnormalItems(List<ItemModel> items) {
    DateTime previousFinishTime = kDefaultStart;
    int errorCount = 0;
    int overdueCount = 0;

    DateTime? quenchFinishTime;
    DateTime? oilShowerFinishTime;

    for (final item in items) {
      final status = getItemAbnormalStatus(
        item,
        previousFinishTime,
        quenchFinishTime: quenchFinishTime,
        oilShowerFinishTime: oilShowerFinishTime,
      );

      if (status.isError) errorCount++;
      if (status.isOverdue) overdueCount++;

      if (item.finishTime != null) {
        previousFinishTime = item.finishTime!;
        if (item.itemCheck == "Quench") quenchFinishTime = item.finishTime!;
        if (item.itemCheck == "OilShower")
          oilShowerFinishTime = item.finishTime!;
      }
    }

    return AbnormalCount(errorCount: errorCount, overdueCount: overdueCount);
  }

  List<LotModel> sortLotsByErrorsAndSizeAndTime(List<FerthModel> ferthList) {
    final allLots = <LotModel>[];
    for (final ferth in ferthList) {
      allLots.addAll(ferth.lots);
    }

    allLots.sort((a, b) {
      final abnormalA = countAbnormalItems(a.items);
      final abnormalB = countAbnormalItems(b.items);

      if (abnormalA.errorCount != abnormalB.errorCount) {
        return abnormalB.errorCount.compareTo(abnormalA.errorCount);
      }
      if (abnormalA.overdueCount != abnormalB.overdueCount) {
        return abnormalB.overdueCount.compareTo(abnormalA.overdueCount);
      }
      if (a.items.length != b.items.length) {
        return b.items.length.compareTo(a.items.length);
      }

      final allFinishA = a.items.every((e) => e.finishTime != null);
      final allFinishB = b.items.every((e) => e.finishTime != null);
      if (allFinishA != allFinishB) return allFinishB ? 1 : -1;

      final unfinishedA = a.items.firstWhereOrNull((e) => e.finishTime == null);
      final unfinishedB = b.items.firstWhereOrNull((e) => e.finishTime == null);
      if (unfinishedA?.startTime != null && unfinishedB?.startTime != null) {
        final c = unfinishedA!.startTime!.compareTo(unfinishedB!.startTime!);
        if (c != 0) return c;
      }

      final durationsA = a.items
          .where((e) => e.startTime != null && e.finishTime != null)
          .map((e) => e.finishTime!.difference(e.startTime!).inMilliseconds)
          .toList();
      final durationsB = b.items
          .where((e) => e.startTime != null && e.finishTime != null)
          .map((e) => e.finishTime!.difference(e.startTime!).inMilliseconds)
          .toList();

      if (durationsA.isNotEmpty && durationsB.isNotEmpty) {
        final minA = durationsA.reduce(min);
        final minB = durationsB.reduce(min);
        final c = minA.compareTo(minB);
        if (c != 0) return c;
      } else if (durationsA.isNotEmpty && durationsB.isEmpty) {
        return -1;
      } else if (durationsA.isEmpty && durationsB.isNotEmpty) {
        return 1;
      }

      final startsA = a.items
          .where((e) => e.startTime != null)
          .map((e) => e.startTime!)
          .toList();
      final startsB = b.items
          .where((e) => e.startTime != null)
          .map((e) => e.startTime!)
          .toList();

      if (startsA.isEmpty && startsB.isEmpty) return 0;
      if (startsA.isEmpty) return 1;
      if (startsB.isEmpty) return -1;

      final earliestA = startsA.reduce((x, y) => y.isBefore(x) ? y : x);
      final earliestB = startsB.reduce((x, y) => y.isBefore(x) ? y : x);
      return earliestA.compareTo(earliestB);
    });

    return allLots;
  }

  // ===============================
  // BUILD
  // ===============================
  @override
  Widget build(BuildContext context) {
    final seenLots = <String>{};
    final rows = <TableRow>[];
    int idCounter = 1;

    // Nếu bạn cần ID cố định theo order ban đầu, bật lại đoạn này
    // final lotIdMap = <String, String>{};
    // int tempIdCounter = 1;
    // for (final ferth in widget.ferthList) {
    //   for (final lot in ferth.lots) {
    //     lotIdMap[lot.lot] = "A$tempIdCounter";
    //     tempIdCounter++;
    //   }
    // }

    final sortedLots = sortLotsByErrorsAndSizeAndTime(widget.ferthList);

    for (final lot in sortedLots) {
      if (!seenLots.add(lot.lot)) continue;

      final hrcNotes = _extractHrcNotes(lot);

      final rowCells = <Widget>[
        CenteredText("$idCounter", Colors.grey),
        _buildRfidCell(lot, hrcNotes),
        ..._createRowCellsForItem(
          items: lot.items,
          rowId: "$idCounter",
          lot: lot,
          valueHRC_1: hrcNotes.hrc1,
          valueHRC_2: hrcNotes.hrc2,
        ),
      ];

      while (rowCells.length < 15) {
        rowCells.add(const SizedBox.shrink());
      }

      rows.add(TableRow(children: rowCells));
      idCounter++;
    }

    return Stack(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  controller: _verticalScrollController,
                  child: Table(
                    border: TableBorder.all(color: Colors.black45, width: 1),
                    columnWidths: _columnWidths,
                    children: rows,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Overlay Waiting table
        if (_showWaitingItems) _buildWaitingOverlay(context),
      ],
    );
  }

  Map<int, TableColumnWidth> get _columnWidths => const {
        0: FixedColumnWidth(80),
        1: FixedColumnWidth(170),
        2: FixedColumnWidth(135),
        3: FixedColumnWidth(135),
        4: FixedColumnWidth(135),
        5: FixedColumnWidth(135),
        6: FixedColumnWidth(135),
        7: FixedColumnWidth(135),
        8: FixedColumnWidth(90),
        9: FixedColumnWidth(135),
        10: FixedColumnWidth(135),
        11: FixedColumnWidth(90),
        12: FixedColumnWidth(135),
        13: FixedColumnWidth(135),
        14: FixedColumnWidth(135),
      };

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Table(
        border: TableBorder.all(color: Colors.black45, width: 1),
        columnWidths: _columnWidths,
        children: [
          TableRow(
            children: [
              const CenteredTitleText('ID'),
              const CenteredTitleText('RFID'),
              const CenteredTitleText('Wash_1'),
              const CenteredTitleText('Quench'),
              const CenteredTitleText('OilShower'),
              const CenteredTitleText('Cool_Fan_1'),
              const CenteredTitleText('Wash_2'),
              const CenteredTitleText('Cool_Fan_2'),
              const CenteredTitleText('HRC_1'),
              const CenteredTitleText('Temper_1'),
              const CenteredTitleText('Cool_Fan_3'),
              const CenteredTitleText('HRC_2'),
              const CenteredTitleText('Temper_2'),
              const CenteredTitleText('Cool_Fan_4'),
              _buildWaitingHeaderButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingHeaderButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CenteredTitleText('Waiting'),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            shape: const CircleBorder(),
            side: const BorderSide(color: Colors.white, width: 2),
            backgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.all(8),
          ),
          onPressed: () async {
            setState(() => _isLoading = true);
            await _fetchDataMoldMainWaiting();
            setState(() {
              _isLoading = false;
              _showWaitingItems = !_showWaitingItems;
            });
          },
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.black)
              : const Icon(Icons.hourglass_bottom, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildWaitingOverlay(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () => setState(() => _showWaitingItems = false),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: 1.0,
          child: Container(
            height: MediaQuery.of(context).size.height / 1.6,
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Waiting Items List",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          hoverColor: Colors.blueAccent,
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () =>
                              setState(() => _showWaitingItems = false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: FerthMoldMainWaitingTable(
                            ferthList: moldMainWaitings),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===============================
  // RFID + HRC NOTES
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
        if (hrcNotes.hrc1.isNotEmpty)
          parts.add('HRC BF TEMP: ${hrcNotes.hrc1}');
        if (hrcNotes.hrc2.isNotEmpty)
          parts.add('HRC AF TEMP: ${hrcNotes.hrc2}');
        return parts.join(' & ');
      }
      return 'HRC BF TEMP';
    })();

    final details = (() {
      final firstWithPo =
          lot.info.firstWhereOrNull((e) => e.poreqnosWithQty.isNotEmpty);
      if (firstWithPo != null)
        return firstWithPo.poreqnosWithQty.replaceAll(' ; ', '\n');
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
  List<Widget> _createRowCellsForItem({
    required List<ItemModel> items,
    required String rowId,
    required LotModel lot,
    required String valueHRC_1,
    required String valueHRC_2,
  }) {
    DateTime previousFinishTime = kDefaultStart;
    DateTime? quenchFinishTime;
    DateTime? oilShowerFinishTime;

    final rowCells = <Widget>[];
    final currentOverdueItems = <Map<String, String>>{};
    final errorItemsProvider =
        Provider.of<ErrorItemsProvider>(context, listen: false);

    for (final checkType in kCheckTypes) {
      final item = _findItem(items, checkType);

      // HRC cells
      if (checkType == "HRC_1" || checkType == "HRC_2") {
        final hrcValue = (checkType == "HRC_1") ? valueHRC_1 : valueHRC_2;
        rowCells.add(_buildHrcCell(hrcValue));
        continue;
      }

      final computed = _computeTimes(item, fallbackStart: previousFinishTime);
      final adjusted = _adjustStartIfNeeded(item, computed, previousFinishTime);

      final startTime = item.startTime;
      final finishTime = item.finishTime;
      final computedStartTime = adjusted.start;
      final computedFinishTime = adjusted.finish;

      // Track finish times
      if (checkType == "Quench") quenchFinishTime = item.finishTime;
      if (checkType == "OilShower") oilShowerFinishTime = item.finishTime;

      // Warnings
      final isWarning = _isWarning(
            checkType: checkType,
            item: item,
            quenchFinishTime: quenchFinishTime,
          ) ||
          _isTemper1Warning(
            checkType: checkType,
            item: item,
            quenchFinishTime: quenchFinishTime,
          );

      // Schedule errors
      final errorInfo = _computeErrors(
        checkType: checkType,
        item: item,
        computedStartTime: computedStartTime,
        computedFinishTime: computedFinishTime,
        previousFinishTime: previousFinishTime,
        quenchFinishTime: quenchFinishTime,
        oilShowerFinishTime: oilShowerFinishTime,
      );
      bool isError = errorInfo.isError;
      final isErrorNG = errorInfo.isErrorNG;
      final errorComment = errorInfo.errorComment;

      // Special machine exception
      final validMachines = const ["A-1389", "A-1520"];
      if (checkType == "Quench" && validMachines.contains(item.machine)) {
        isError = false;
      }

      // Push abnormal to API once per lot
      if (isError && !errorItemsProvider.isAlreadyAbnormal(lot.lot)) {
        errorItemsProvider.markAbnormal(lot.lot);

        final batchAbnormalModel = BatchAbnormalModel(
          batchId: lot.lot,
          dateadd: DateTime.now(),
          process: checkType,
          comment: errorComment,
        );
        ApiService().addBatch(batchAbnormalModel);
      }

      // Progress / overdue
      final progressState = _computeProgress(
        item: item,
        computedStartTime: computedStartTime,
        computedFinishTime: computedFinishTime,
      );

      if (progressState.isOverdue) {
        currentOverdueItems.add({
          "checkType": checkType,
          "rowId": rowId,
          "lot": lot.lot,
          "machine": item.machine ?? "Unknown",
        });
      }

      final progressColors = _progressColors(
        isInProgress: progressState.isInProgress,
        computedFinishTime: computedFinishTime,
        isOverdue: progressState.isOverdue,
      );

      rowCells.add(
        BlinkingCell(
          isOverdue: progressState.isOverdue,
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
            message: _tooltipMessage(
              checkType: checkType,
              item: item,
              isError: isError,
              isErrorNG: isErrorNG,
              isWarning: isWarning,
              isOverdue: progressState.isOverdue,
              computedStartTime: computedStartTime,
              computedFinishTime: computedFinishTime,
            ),
            child: StatusContainer(
              isOverdue: progressState.isOverdue,
              isInProgress: progressState.isInProgress,
              isError: isError,
              isWarning: isWarning,
              progress: progressState.progress,
              progressColors: progressColors,
              computedFinishTime: computedFinishTime,
              startTime: startTime,
              finishTime: finishTime,
              child: buildStatusRow(
                isOverdue: progressState.isOverdue,
                isWarning: isWarning,
                isInProgress: progressState.isInProgress,
                isError: isError,
                items: items,
                checkType: checkType,
                computedStartTime: computedStartTime,
              ),
            ),
          ),
        ),
      );

      _postFrameSyncErrors(
        errorItemsProvider: errorItemsProvider,
        currentOverdueItems: currentOverdueItems,
        checkType: checkType,
        rowId: rowId,
        lot: lot,
        finishTime: finishTime,
        computedFinishTime: computedFinishTime,
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
  // TIME + ADJUST
  // ===============================
  _Times _computeTimes(ItemModel item, {required DateTime fallbackStart}) {
    final estimated = estimatedTimes[item.itemCheck] ?? 0;
    final start = item.startTime ?? fallbackStart;
    final finish = item.finishTime ?? start.add(Duration(minutes: estimated));
    return _Times(start: start, finish: finish, estimatedMinutes: estimated);
  }

  _Times _adjustStartIfNeeded(
      ItemModel item, _Times t, DateTime previousFinishTime) {
    // Giữ y logic cũ: nếu previousFinishTime < now và startTime null => set expected start = now
    if (previousFinishTime.isBefore(DateTime.now()) && item.startTime == null) {
      final now = DateTime.now();
      return _Times(
        start: now,
        finish: now.add(Duration(minutes: t.estimatedMinutes)),
        estimatedMinutes: t.estimatedMinutes,
      );
    }
    return t;
  }

  // ===============================
  // WARNINGS
  // ===============================
  bool _isWarning({
    required String checkType,
    required ItemModel item,
    required DateTime? quenchFinishTime,
  }) {
    if (checkType != "OilShower") return false;
    if (item.startTime != null) return false;
    if (quenchFinishTime == null) return false;

    final now = DateTime.now();
    final deadline = quenchFinishTime.add(const Duration(hours: 1));
    final remainTime = deadline.subtract(const Duration(minutes: 30));

    return now.isAfter(remainTime);
  }

  bool _isTemper1Warning({
    required String checkType,
    required ItemModel item,
    required DateTime? quenchFinishTime,
  }) {
    if (checkType != "Temper_1") return false;
    if (item.startTime != null) return false;
    if (quenchFinishTime == null) return false;

    final now = DateTime.now();
    final deadline = quenchFinishTime.add(const Duration(hours: 24));
    final remainTime = deadline.subtract(const Duration(minutes: 180));

    return now.isAfter(remainTime);
  }

  // ===============================
  // ERRORS
  // ===============================
  _ErrorInfo _computeErrors({
    required String checkType,
    required ItemModel item,
    required DateTime computedStartTime,
    required DateTime computedFinishTime,
    required DateTime previousFinishTime,
    required DateTime? quenchFinishTime,
    required DateTime? oilShowerFinishTime,
  }) {
    bool isError = false;
    bool isErrorNG = false;
    String errorComment = "";

    // (A) Start too early
    final threshold =
        previousFinishTime.subtract(const Duration(minutes: kToleranceMinutes));
    if (computedStartTime.isBefore(threshold)) {
      isError = true;
      errorComment = "Start time is earlier than allowed";
    }

    // (B) Special NG rules (your old logic)
    final validMachines = const ["A-1389", "A-1520"];

    if (checkType == "OilShower" &&
        item.finishTime != null &&
        !validMachines.contains(item.machine)) {
      if (quenchFinishTime != null) {
        final diffMinutes =
            computedFinishTime.difference(quenchFinishTime).inMinutes;
        if (diffMinutes > 60) {
          isError = true;
          isErrorNG = true;
          errorComment = "Temper_1 - OilShower time > 60 minutes";
        }
      }
    }

    if (checkType == "Cool_Fan_3" && item.finishTime != null) {
      if (oilShowerFinishTime != null) {
        final diffMinutes =
            computedFinishTime.difference(oilShowerFinishTime).inMinutes;
        if (diffMinutes > 1440) {
          isError = true;
          isErrorNG = true;
          errorComment = "Cool_Fan_3 - OilShower time > 24 hours";
        }
      }
    }

    return _ErrorInfo(
        isError: isError, isErrorNG: isErrorNG, errorComment: errorComment);
  }

  // ===============================
  // PROGRESS / COLORS
  // ===============================
  _Progress _computeProgress({
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
      if (DateTime.now().isAfter(computedFinishTime)) isOverdue = true;
    }

    return _Progress(
        progress: progress, isInProgress: isInProgress, isOverdue: isOverdue);
  }

  List<Color> _progressColors({
    required bool isInProgress,
    required DateTime computedFinishTime,
    required bool isOverdue,
  }) {
    Color startColor = Colors.blue.withOpacity(0.8);
    Color endColor = isInProgress ? Colors.blue.withOpacity(0.2) : startColor;

    if (isOverdue) {
      final overdueMinutes =
          DateTime.now().difference(computedFinishTime).inMinutes;
      final opacity =
          (0.1 + (overdueMinutes / 30) * (0.8 - 0.4)).clamp(0.4, 0.8);
      startColor = Colors.orange.withOpacity(opacity);
      endColor = Colors.yellow.withOpacity((opacity + 0.1).clamp(0.0, 1.0));
    }

    return [
      startColor,
      HSVColor.fromColor(startColor).withValue(0.9).toColor(),
      endColor,
    ];
  }

  // ===============================
  // TOOLTIP MESSAGE
  // ===============================
  String _tooltipMessage({
    required String checkType,
    required ItemModel item,
    required bool isError,
    required bool isErrorNG,
    required bool isWarning,
    required bool isOverdue,
    required DateTime computedStartTime,
    required DateTime computedFinishTime,
  }) {
    final startTime = item.startTime;
    final finishTime = item.finishTime;

    if (isError && isErrorNG) {
      if (checkType == "OilShower" && finishTime != null) {
        return "⚠️ Delay Error\nTime gap between Quench and OilShower exceeds 60 minutes!"
            "\nOilShower End: ${formatFullDate(computedFinishTime)}"
            "\nMachine: ${item.machine}";
      }
      if (checkType == "Cool_Fan_3" && finishTime != null) {
        return "⚠️ Delay Error\nTime gap between OilShower and Cool_Fan_3 exceeds 24 hours!"
            "\nTemper_1 End: ${formatFullDate(computedFinishTime)}"
            "\nMachine: ${item.machine}";
      }
    }

    if (isWarning) {
      if (checkType == "OilShower") {
        return "⚠️ Warning!\nOilShower should start within the next 30 minutes!"
            "\nExpected finish: ${formatFullDate(computedFinishTime)}"
            "\nMachine: ${item.machine}";
      }
      if (checkType == "Temper_1") {
        return "⚠️ Warning!\nTemper_1 should start within the next 180 minutes!"
            "\nExpected finish: ${formatFullDate(computedFinishTime)}"
            "\nMachine: ${item.machine}";
      }
    }

    if (isError) {
      return "⚠️ Schedule Error\nStart time: ${formatFullDate(startTime)} is too early!"
          "\nMachine: ${item.machine}";
    }

    if (isOverdue) {
      return "⚠️ Overdue!\nExpected finish: ${formatFullDate(computedFinishTime)}"
          "\nMachine: ${item.machine}";
    }

    if (startTime != null && finishTime == null) {
      return "Start: ${formatFullDate(startTime)}"
          "\nExpected finish: ${formatFullDate(computedFinishTime)}"
          "\nMachine: ${item.machine}";
    }

    if (startTime != null && finishTime != null) {
      return "Start: ${formatFullDate(startTime)}"
          "\nFinish: ${formatFullDate(finishTime)}"
          "\nMachine: ${item.machine}";
    }

    return "Expected start: ${formatFullDate(computedStartTime)}"
        "\nExpected finish: ${formatFullDate(computedFinishTime)}";
  }

  // ===============================
  // PROVIDER SYNC (post frame)
  // ===============================
  void _postFrameSyncErrors({
    required ErrorItemsProvider errorItemsProvider,
    required Set<Map<String, String>> currentOverdueItems,
    required String checkType,
    required String rowId,
    required LotModel lot,
    required DateTime? finishTime,
    required DateTime computedFinishTime,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Remove items no longer overdue
      currentOverdueItems.removeWhere((m) =>
          m['checkType'] == checkType &&
          m['lot'] == lot.lot &&
          DateTime.now().isBefore(computedFinishTime));

      // If Cool_Fan_4 completed => clear lot error
      if (checkType == "Cool_Fan_4" && finishTime != null) {
        errorItemsProvider.removeError(lot.lot);
      }

      // Remove rowId error if not still overdue
      final stillOverdue = currentOverdueItems.any(
        (m) => m['rowId'] == rowId && m['checkType'] == checkType,
      );
      if (!stillOverdue &&
          errorItemsProvider.errorItemsByRowId.containsKey(rowId)) {
        errorItemsProvider.removeError(rowId);
      }

      // Add new overdue errors
      for (final m in currentOverdueItems) {
        final lotId = m['lot'];
        final ct = m['checkType'];
        final machine = m['machine'];
        final rid = m['rowId'];

        if (lotId == null || ct == null || machine == null || rid == null)
          continue;

        final isNew = !errorItemsProvider.errorItemsByRowId.containsKey(lotId);
        if (isNew) {
          errorItemsProvider
              .updateErrorItems(rid, machine, ct, lotId, ["Overdue"]);
        }
      }
    });
  }

  // ===============================
  // STATUS ROW
  // ===============================
  Widget buildStatusRow({
    required bool isOverdue,
    required bool isWarning,
    required bool isInProgress,
    required bool isError,
    required List<ItemModel> items,
    required String checkType,
    required DateTime computedStartTime,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
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

  // ===============================
  // DATA CELL
  // ===============================
  Widget _createDataCell(
      List<ItemModel> items, String checkType, DateTime previousFinishTime) {
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
    if (time == null) return '--:--';
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

class _Times {
  final DateTime start;
  final DateTime finish;
  final int estimatedMinutes;
  const _Times(
      {required this.start,
      required this.finish,
      required this.estimatedMinutes});
}

class _ErrorInfo {
  final bool isError;
  final bool isErrorNG;
  final String errorComment;
  const _ErrorInfo(
      {required this.isError,
      required this.isErrorNG,
      required this.errorComment});
}

class _Progress {
  final double progress;
  final bool isInProgress;
  final bool isOverdue;
  const _Progress(
      {required this.progress,
      required this.isInProgress,
      required this.isOverdue});
}

// ===============================
// EXTENSIONS
// ===============================
extension FirstWhereOrNullExt<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
