// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'error_items_provider.dart';
//
//
// class ImageMachine extends StatefulWidget {
//   const ImageMachine({Key? key}) : super(key: key);
//
//   @override
//   _ImageMachineState createState() => _ImageMachineState();
// }
//
// class _ImageMachineState extends State<ImageMachine> {
//   double? _tapXPercent, _tapYPercent;
//   double _indicatorOpacity = 1.0;
//   Timer? _blinkTimer;
//   GlobalKey _imageKey = GlobalKey();
//   List<List<dynamic>> _blinkPoints = [];
//
//   final List<List<dynamic>> validPoints = [
//     [0.38, 0.42, 100, 135, "Wash_1"],
//     [0.87, 0.28, 100, 55, "Waiting"],
//     [0.86, 0.42, 40, 45, "A-1499"],
//     [0.755, 0.45, 30, 35, "Cool_Fan_2"],
//     [0.794, 0.45, 30, 35, "Cool_Fan_1_R"],
//   ];
//
//   @override
//   void dispose() {
//     _blinkTimer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _handleExternalSelection();
//   }
//
//   @override
//   void didUpdateWidget(covariant ImageMachine oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     _handleExternalSelection();
//   }
//
//   void _handleExternalSelection() {
//     final errorItemsProvider = Provider.of<ErrorItemsProvider>(context, listen: false);
//
//     Future.delayed(Duration.zero, () {
//       for (var machineId in errorItemsProvider.errorItemsByMachine.keys) {
//         var matchingPoints = validPoints.where((point) => point[4] == machineId).toList();
//
//         if (matchingPoints.isNotEmpty && errorItemsProvider.errorItemsByMachine[machineId]?.isNotEmpty == true) {
//           print("Matching Points Found: ${matchingPoints.first}");
//
//           if (mounted) {
//             setState(() {
//               // _tapXPercent = matchingPoints.first[0];
//               // _tapYPercent = matchingPoints.first[1];
//               // _indicatorOpacity = 1.0;
//               _blinkPoints = matchingPoints.map((point) {
//                 return [point[0], point[1]]; // Lưu trữ vị trí x, y của các điểm
//               }).toList();
//               _indicatorOpacity = 1.0;
//             });
//             _startBlinking();
//           }
//         }
//       }
//     });
//   }
//
//   void _startBlinking() {
//     _blinkTimer?.cancel();
//
//     _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }
//       setState(() {
//         _indicatorOpacity = (_indicatorOpacity == 1.0) ? 0.3 : 1.0;
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ErrorItemsProvider>(builder: (context, errorItemsProvider, child) {
//       return Stack(
//         children: [
//           // Hình ảnh máy
//           Image.asset(
//             'assets/machines.jpeg',
//             key: _imageKey,
//             fit: BoxFit.contain,
//             width: MediaQuery.of(context).size.width / 2.4,
//           ),
//           // if (_tapXPercent != null && _tapYPercent != null) _buildTapIndicators(),
//           if (_blinkPoints.isNotEmpty) _buildTapIndicators(),
//         ],
//       );
//     });
//   }
//
//   // Chức năng vẽ chỉ báo nhấp nháy
//   // Widget _buildTapIndicator() {
//   //   final RenderBox? renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
//   //   if (renderBox == null || !renderBox.hasSize) return SizedBox.shrink();
//   //
//   //   final imageSize = renderBox.size;
//   //   double tapX = _tapXPercent! * imageSize.width;
//   //   double tapY = _tapYPercent! * imageSize.height;
//   //
//   //   var selectedPoint = validPoints.firstWhere(
//   //         (point) => point[0] == _tapXPercent && point[1] == _tapYPercent,
//   //     orElse: () => [0.0, 0.0, 100, 70, "Unknown"],
//   //   );
//   //
//   //   double indicatorHeight = selectedPoint[3].toDouble();
//   //   double indicatorWidth = selectedPoint[2].toDouble();
//   //
//   //   return Positioned(
//   //     left: tapX - (indicatorWidth / 2),
//   //     top: tapY - (indicatorHeight / 2),
//   //     child: AnimatedOpacity(
//   //       duration: const Duration(milliseconds: 300),
//   //       opacity: _indicatorOpacity,
//   //       child: Container(
//   //         width: indicatorWidth,
//   //         height: indicatorHeight,
//   //         decoration: BoxDecoration(
//   //           border: Border.all(color: Colors.blue, width: 4),
//   //           color: Colors.transparent,
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }
// // Chức năng vẽ chỉ báo nhấp nháy cho nhiều điểm
//
//   Widget _buildTapIndicators() {
//     final RenderBox? renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
//
//     // If the renderBox is null or not laid out yet, return an empty SizedBox.
//     if (renderBox == null || !renderBox.hasSize) return SizedBox.shrink();
//
//     // If the layout is complete, proceed with calculating sizes
//     final imageSize = renderBox.size;
//
//     return Stack(
//       children: _blinkPoints.map((point) {
//         double tapX = point[0] * imageSize.width;
//         double tapY = point[1] * imageSize.height;
//
//         var selectedPoint = validPoints.firstWhere(
//               (validPoint) => validPoint[0] == point[0] && validPoint[1] == point[1],
//           orElse: () => [0.0, 0.0, 100, 70, "Unknown"],
//         );
//
//         double indicatorHeight = selectedPoint[3].toDouble();
//         double indicatorWidth = selectedPoint[2].toDouble();
//
//         return Positioned(
//           left: tapX - (indicatorWidth / 2),
//           top: tapY - (indicatorHeight / 2),
//           child: AnimatedOpacity(
//             duration: const Duration(milliseconds: 300),
//             opacity: _indicatorOpacity,
//             child: Container(
//               width: indicatorWidth,
//               height: indicatorHeight,
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.blue, width: 4),
//                 color: Colors.transparent,
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
//
//   // Widget _buildTapIndicators() {
//   //   final RenderBox? renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
//   //   if (renderBox == null || !renderBox.hasSize) return SizedBox.shrink();
//   //
//   //   final imageSize = renderBox.size;
//   //
//   //   return Stack(
//   //     children: _blinkPoints.map((point) {
//   //       double tapX = point[0] * imageSize.width;
//   //       double tapY = point[1] * imageSize.height;
//   //
//   //       var selectedPoint = validPoints.firstWhere(
//   //             (validPoint) => validPoint[0] == point[0] && validPoint[1] == point[1],
//   //         orElse: () => [0.0, 0.0, 100, 70, "Unknown"],
//   //       );
//   //
//   //       double indicatorHeight = selectedPoint[3].toDouble();
//   //       double indicatorWidth = selectedPoint[2].toDouble();
//   //
//   //       return Positioned(
//   //         left: tapX - (indicatorWidth / 2),
//   //         top: tapY - (indicatorHeight / 2),
//   //         child: AnimatedOpacity(
//   //           duration: const Duration(milliseconds: 300),
//   //           opacity: _indicatorOpacity,
//   //           child: Container(
//   //             width: indicatorWidth,
//   //             height: indicatorHeight,
//   //             decoration: BoxDecoration(
//   //               border: Border.all(color: Colors.blue, width: 4),
//   //               color: Colors.transparent,
//   //             ),
//   //           ),
//   //         ),
//   //       );
//   //     }).toList(),
//   //   );
//   // }
//
//
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'error_items_provider.dart';

// class ImageMachine extends StatefulWidget {
//   const ImageMachine({Key? key}) : super(key: key);
//
//   @override
//   _ImageMachineState createState() => _ImageMachineState();
// }
//
// class _ImageMachineState extends State<ImageMachine> {
//   double? _tapXPercent, _tapYPercent;
//   double _indicatorOpacity = 1.0;
//   Timer? _blinkTimer;
//   GlobalKey _imageKey = GlobalKey();
//
//   final List<List<dynamic>> validPoints = [
//     // [0.385, 0.42, 130, 150, "A-2757"],
//     // [0.48, 0.4, 60, 70, "A-1520"],
//     // [0.54, 0.25, 80, 60, "A-1389"],
//     // [0.67, 0.28, 130, 80, "A-2402"],
//     // [0.75, 0.2, 78, 75, "A-2400"],
//     // [0.87, 0.28, 130, 80, "A-2002"],
//     // [0.86, 0.42, 70, 75, "A-1499"],
//     // [0.87, 0.57, 130, 80, "A-1412"],
//     // [0.87, 0.82, 130, 80, "A-1592"],
//     // [0.48, 0.6, 80, 80, "A-1596"],
//     // [0.57, 0.42, 60, 60, "A-2842"],
//     // [0.41, 0.9, 90, 60, "A-1999"],
//     // [0.5, 0.9, 90, 60, "A-1413"],
//     // [0.57, 0.9, 60, 60, "A-1639"],
//     // [0.74, 0.9, 60, 60, "A-1587"],
//     [0.79, 0.8, 60, 60, "A-1498"],
//     // [0.17, 0.86, 50, 50, "A-1426"],
//     // [0.13, 0.76, 50, 50, "A-1427"],
//     // [0.385, 0.42, 110, 145, "Wash_2"],
//     // [0.75, 0.86, 78, 75, "Temper_1"],
//     // [0.75, 0.86, 78, 75, "Temper_2"],
//     // [0.73, 0.51, 76, 76, "Cool_Fan_1_L"],
//     // [0.8, 0.51, 76, 76, "Cool_Fan_1_R"],
//     // [0.65, 0.51, 80, 80, "Cool_Fan_2"],
//     // [0.7, 0.51, 80, 80, "Cool_Fan_3"],
//     // [0.73, 0.51, 80, 80, "Cool_Fan_4"],
//   ];
//
//   List<bool> _blinkStates = [];
//
//   @override
//   void dispose() {
//     _blinkTimer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _handleExternalSelection();
//     _initializeBlinkStates();
//   }
//
//   void _initializeBlinkStates() {
//     _blinkStates = List<bool>.filled(validPoints.length, false);
//   }
//
//   @override
//   void didUpdateWidget(covariant ImageMachine oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     _handleExternalSelection();
//   }
//
//   void _handleExternalSelection() {
//     final errorItemsProvider =
//         Provider.of<ErrorItemsProvider>(context, listen: false);
//     _startBlinking();
//     // Future.delayed(Duration.zero, () {
//     //   for (var machineId in errorItemsProvider.errorItemsByMachine.keys) {
//     //     var matchingPoints = validPoints.where((point) => point[4] == machineId).toList();
//     //
//     //     if (matchingPoints.isNotEmpty && errorItemsProvider.errorItemsByMachine[machineId]?.isNotEmpty == true) {
//     //       print("Matching Points Found: ${matchingPoints.first}");
//     //
//     //       if (mounted) {
//     //         setState(() {
//     //           _tapXPercent = matchingPoints.first[0];
//     //           _tapYPercent = matchingPoints.first[1];
//     //           _indicatorOpacity = 1.0;
//     //         });
//     //         _startBlinking();
//     //       }
//     //     }
//     //   }
//     // });
//   }
//
//   void _startBlinking() {
//     _blinkTimer?.cancel();
//
//     _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }
//
//       setState(() {
//         // Update the blinking state for each point
//         for (int i = 0; i < _blinkStates.length; i++) {
//           _blinkStates[i] = !_blinkStates[i];
//         }
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ErrorItemsProvider>(
//         builder: (context, errorItemsProvider, child) {
//       return Stack(
//         children: [
//           // Hình ảnh máy
//           Image.asset(
//             'assets/machine_update.png',
//             key: _imageKey,
//             fit: BoxFit.contain,
//           ),
//           ..._buildTapIndicators(),
//         ],
//       );
//     });
//   }
//
//   // Chức năng vẽ chỉ báo nhấp nháy cho tất cả các điểm
//   List<Widget> _buildTapIndicators() {
//     final RenderBox? renderBox =
//         _imageKey.currentContext?.findRenderObject() as RenderBox?;
//     if (renderBox == null || !renderBox.hasSize) return [];
//
//     final imageSize = renderBox.size;
//     List<Widget> indicators = [];
//
//     for (int i = 0; i < validPoints.length; i++) {
//       var point = validPoints[i];
//       double tapX = point[0] * imageSize.width;
//       double tapY = point[1] * imageSize.height;
//       double indicatorHeight = point[3].toDouble();
//       double indicatorWidth = point[2].toDouble();
//
//       indicators.add(
//         Positioned(
//           left: tapX - (indicatorWidth / 2),
//           top: tapY - (indicatorHeight / 2),
//           child: AnimatedOpacity(
//             duration: const Duration(milliseconds: 200),
//             opacity: _blinkStates[i] ? 1.0 : 0.5, // Nhấp nháy theo từng điểm
//             child: Container(
//               width: indicatorWidth,
//               height: indicatorHeight,
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.blue, width: 4),
//                 color: Colors.transparent,
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//
//     return indicators;
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImageMachine extends StatefulWidget {
  const ImageMachine({Key? key}) : super(key: key);

  @override
  State<ImageMachine> createState() => _ImageMachineState();
}

// ===============================
// DATA MODEL
// ===============================
class MachinePoint {
  final double xPercent;
  final double yPercent;
  final double width;
  final double height;
  final String machineId;

  const MachinePoint({
    required this.xPercent,
    required this.yPercent,
    required this.width,
    required this.height,
    required this.machineId,
  });
}

class _ImageMachineState extends State<ImageMachine> {
  // Image size lookup
  final GlobalKey _imageKey = GlobalKey();

  // Blink
  Timer? _blinkTimer;
  late List<bool> _blinkStates;

  // Optional: highlight selection (bạn có nhưng không dùng trong UI hiện tại)
  double? _tapXPercent, _tapYPercent;
  double _indicatorOpacity = 1.0;

  // ===============================
  // POINTS CONFIG
  // ===============================
  static const List<MachinePoint> validPoints = [
    MachinePoint(
        xPercent: 0.385,
        yPercent: 0.42,
        width: 130,
        height: 150,
        machineId: "A-2757"),
    MachinePoint(
        xPercent: 0.48,
        yPercent: 0.40,
        width: 60,
        height: 70,
        machineId: "A-1520"),
    MachinePoint(
        xPercent: 0.54,
        yPercent: 0.25,
        width: 80,
        height: 60,
        machineId: "A-1389"),
    MachinePoint(
        xPercent: 0.67,
        yPercent: 0.28,
        width: 130,
        height: 80,
        machineId: "A-2402"),
    MachinePoint(
        xPercent: 0.75,
        yPercent: 0.20,
        width: 78,
        height: 75,
        machineId: "A-2400"),
    MachinePoint(
        xPercent: 0.87,
        yPercent: 0.28,
        width: 130,
        height: 80,
        machineId: "A-2002"),
    MachinePoint(
        xPercent: 0.86,
        yPercent: 0.42,
        width: 70,
        height: 75,
        machineId: "A-1499"),
    MachinePoint(
        xPercent: 0.87,
        yPercent: 0.57,
        width: 130,
        height: 80,
        machineId: "A-1412"),
    MachinePoint(
        xPercent: 0.87,
        yPercent: 0.82,
        width: 130,
        height: 80,
        machineId: "A-1592"),
    MachinePoint(
        xPercent: 0.48,
        yPercent: 0.60,
        width: 80,
        height: 80,
        machineId: "A-1596"),
    MachinePoint(
        xPercent: 0.57,
        yPercent: 0.42,
        width: 60,
        height: 60,
        machineId: "A-2842"),
    MachinePoint(
        xPercent: 0.41,
        yPercent: 0.80,
        width: 90,
        height: 60,
        machineId: "A-1999"),
    MachinePoint(
        xPercent: 0.50,
        yPercent: 0.80,
        width: 90,
        height: 60,
        machineId: "A-1413"),
    MachinePoint(
        xPercent: 0.57,
        yPercent: 0.84,
        width: 90,
        height: 90,
        machineId: "A-1639"),
    MachinePoint(
        xPercent: 0.74,
        yPercent: 0.80,
        width: 60,
        height: 60,
        machineId: "A-1587"),
    MachinePoint(
        xPercent: 0.79,
        yPercent: 0.80,
        width: 60,
        height: 60,
        machineId: "A-1498"),
    MachinePoint(
        xPercent: 0.17,
        yPercent: 0.86,
        width: 50,
        height: 50,
        machineId: "A-1426"),
    MachinePoint(
        xPercent: 0.13,
        yPercent: 0.76,
        width: 50,
        height: 50,
        machineId: "A-1427"),

    // Process labels
    MachinePoint(
        xPercent: 0.385,
        yPercent: 0.42,
        width: 110,
        height: 145,
        machineId: "Wash_2"),
    MachinePoint(
        xPercent: 0.75,
        yPercent: 0.86,
        width: 78,
        height: 75,
        machineId: "Temper_1"),
    MachinePoint(
        xPercent: 0.75,
        yPercent: 0.86,
        width: 78,
        height: 75,
        machineId: "Temper_2"),
    MachinePoint(
        xPercent: 0.73,
        yPercent: 0.51,
        width: 76,
        height: 76,
        machineId: "Cool_Fan_1_L"),
    MachinePoint(
        xPercent: 0.80,
        yPercent: 0.51,
        width: 76,
        height: 76,
        machineId: "Cool_Fan_1_R"),
    MachinePoint(
        xPercent: 0.65,
        yPercent: 0.51,
        width: 80,
        height: 80,
        machineId: "Cool_Fan_2"),
    MachinePoint(
        xPercent: 0.70,
        yPercent: 0.51,
        width: 80,
        height: 80,
        machineId: "Cool_Fan_3"),
    MachinePoint(
        xPercent: 0.73,
        yPercent: 0.51,
        width: 80,
        height: 80,
        machineId: "Cool_Fan_4"),
  ];

  // ===============================
  // LIFECYCLE
  // ===============================
  @override
  void initState() {
    super.initState();
    _blinkStates = List<bool>.filled(validPoints.length, false);
  }

  @override
  void dispose() {
    _stopBlinking();
    super.dispose();
  }

  // ===============================
  // BLINK CONTROL
  // ===============================
  void _stopBlinking() {
    _blinkTimer?.cancel();
    _blinkTimer = null;
  }

  void _ensureBlinkingRunning(bool hasAnyErrors) {
    if (!hasAnyErrors) {
      if (_blinkTimer != null) {
        setState(() {
          _blinkStates = List<bool>.filled(validPoints.length, false);
        });
      }
      _stopBlinking();
      return;
    }

    // already running
    if (_blinkTimer != null) return;

    _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      setState(() {
        for (int i = 0; i < _blinkStates.length; i++) {
          _blinkStates[i] = !_blinkStates[i];
        }
      });
    });
  }

  // ===============================
  // IMAGE SIZE
  // ===============================
  Size? _getImageSize() {
    final renderBox =
        _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return null;
    return renderBox.size;
  }

  // ===============================
  // EXTERNAL SELECTION (optional)
  // ===============================
  void _handleExternalSelection(ErrorItemsProvider provider) {
    // Chỉ highlight 1 điểm đầu tiên match (nếu muốn)
    for (final entry in provider.errorItemsByRowId.entries) {
      final machineId = entry.value['machineId'];
      if (machineId == null) continue;

      final matchIndex =
          validPoints.indexWhere((p) => p.machineId == machineId);
      if (matchIndex != -1) {
        final p = validPoints[matchIndex];
        _tapXPercent = p.xPercent;
        _tapYPercent = p.yPercent;
        _indicatorOpacity = 1.0;
        break;
      }
    }
  }

  // ===============================
  // BUILD
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Consumer<ErrorItemsProvider>(
      builder: (context, provider, _) {
        final hasAnyErrors = provider.errorItemsByRowId.isNotEmpty;

        // start/stop blinking based on provider state
        _ensureBlinkingRunning(hasAnyErrors);

        // optional: compute highlight target
        _handleExternalSelection(provider);

        return Stack(
          children: [
            Image.asset(
              'assets/machine_update.png',
              key: _imageKey,
              fit: BoxFit.contain,
            ),
            ..._buildIndicators(provider),
          ],
        );
      },
    );
  }

  // ===============================
  // INDICATORS
  // ===============================
  List<Widget> _buildIndicators(ErrorItemsProvider provider) {
    final imageSize = _getImageSize();
    if (imageSize == null) return [];

    final indicators = <Widget>[];

    for (int i = 0; i < validPoints.length; i++) {
      final point = validPoints[i];

      final rowIdsForMachine = provider.errorItemsByRowId.entries
          .where((e) => e.value['machineId'] == point.machineId)
          .map((e) => e.key)
          .toList();

      if (rowIdsForMachine.isEmpty) continue;

      final tapX = point.xPercent * imageSize.width;
      final tapY = point.yPercent * imageSize.height;

      indicators.add(
        Positioned(
          left: tapX - (point.width / 2),
          top: tapY - (point.height / 2),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 800),
            opacity: _blinkStates[i] ? 1.0 : 0.5,
            child: SizedBox(
              width: point.width,
              height: point.height,
              child: _IndicatorBubble(
                machineId: point.machineId,
                rowIds: rowIdsForMachine,
                provider: provider,
              ),
            ),
          ),
        ),
      );
    }

    return indicators;
  }
}

// ===============================
// INDICATOR UI
// ===============================
class _IndicatorBubble extends StatelessWidget {
  final String machineId;
  final List<String> rowIds;
  final ErrorItemsProvider provider;

  const _IndicatorBubble({
    required this.machineId,
    required this.rowIds,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.orangeAccent, Colors.yellow],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.redAccent, width: 2),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: rowIds.map((id) {
                  final display =
                      provider.errorItemsByRowId[id]?['rowId'] ?? id;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      display,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.orangeAccent, Colors.yellow],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              shape: BoxShape.rectangle,
              border: Border.all(color: Colors.redAccent, width: 2),
            ),
            child: Text(
              machineId,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
