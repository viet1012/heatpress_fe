import 'dart:async';
import 'package:flutter/material.dart';

class StatusContainer extends StatefulWidget {
  final bool isOverdue;
  final bool isInProgress;
  final bool isError;
  final bool isWarning;
  final double progress;
  final List<Color> progressColors;
  final Widget child;
  final DateTime? computedFinishTime;
  final DateTime? startTime;
  final DateTime? finishTime;

  const StatusContainer({
    super.key,
    required this.isOverdue,
    required this.isInProgress,
    required this.isError,
    required this.isWarning,
    required this.progress,
    required this.progressColors,
    required this.child,
    required this.computedFinishTime,
    required this.startTime,
    required this.finishTime,
  });

  @override
  State<StatusContainer> createState() => _StatusContainerState();
}

class _StatusContainerState extends State<StatusContainer> {
  Color startColorOverdue = Colors.orange.withOpacity(0.1);
  Color endColorOverdue = Colors.yellow.withOpacity(0.2);
  Timer? _timerForOverdue;
  int elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isOverdue) {
      _startOverdueEffect();
    }
  }

  @override
  void didUpdateWidget(covariant StatusContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isOverdue != oldWidget.isOverdue) {
      _timerForOverdue?.cancel(); // Hủy timer cũ để tránh trùng lặp

      if (widget.isOverdue) {
        elapsedSeconds = 0; // Reset thời gian đếm
        _startOverdueEffect();
      } else {
        setState(() {
          startColorOverdue = Colors.orange.withOpacity(0.1);
          endColorOverdue = Colors.yellow.withOpacity(0.2);
        });
      }
    }
  }

  void _startOverdueEffect() {
    // _updateColorForOverdue(); // Cập nhật ngay lập tức
    _timerForOverdue = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (elapsedSeconds < 600) {
        // Chạy đúng 10 phút
        elapsedSeconds += 10;
        _updateColorForOverdue();
      } else {
        _timerForOverdue?.cancel(); // Dừng sau 10 phút
      }
    });
  }

  void _updateColorForOverdue() {
    // double opacity = (0.4 + (elapsedSeconds / 600) * (0.8 - 0.4)).clamp(0.4, 0.8);
    double opacity =
        (0.2 + (elapsedSeconds / 600) * (0.8 - 0.2)).clamp(0.2, 0.8);

    setState(() {
      startColorOverdue = Colors.orange.withOpacity(opacity);
      endColorOverdue = Colors.yellow.withOpacity(opacity + 0.1);
    });

    // debugPrint("Elapsed: $elapsedSeconds - Opacity: $opacity"); // Kiểm tra giá trị opacity
  }

  @override
  void dispose() {
    _timerForOverdue?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.isOverdue || widget.isError
              ? Colors.red
              : Colors.transparent,
          width: 2,
        ),
        gradient: _getGradient(),
      ),
      child: widget.child,
    );
  }

  LinearGradient? _getGradient() {
    if (widget.isError) {
      return LinearGradient(
        colors: [Colors.red, Colors.red.withOpacity(0.5)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    } else if (widget.isOverdue) {
      return LinearGradient(
        colors: [startColorOverdue, endColorOverdue],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    } else if (widget.isWarning) {
      return LinearGradient(
        colors: [Colors.orangeAccent, Colors.red.withOpacity(.8)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    } else if (widget.isInProgress) {
      return LinearGradient(
        colors: widget.progressColors,
        stops: [widget.progress * 0.7, widget.progress, widget.progress + 0.1],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    } else if (widget.finishTime != null && widget.startTime != null) {
      return LinearGradient(
        colors: [Colors.blue.withOpacity(0.8), Colors.blue.withOpacity(0.8)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    } else {
      return null;
    }
  }
}
