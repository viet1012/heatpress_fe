import 'package:flutter/material.dart';

class BlinkingCell extends StatefulWidget {
  final Widget child;
  final bool isOverdue; // Nếu quá hạn thì nhấp nháy
  final bool isWarning; // Nếu cảnh báo thì nhấp nháy nhanh hơn

  const BlinkingCell({
    Key? key,
    required this.child,
    required this.isOverdue,
    required this.isWarning,
  }) : super(key: key);

  @override
  _BlinkingCellState createState() => _BlinkingCellState();
}

class _BlinkingCellState extends State<BlinkingCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool hasStartedBlinking = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _getBlinkDuration(), // Chọn tốc độ nhấp nháy phù hợp
    );

    _animation = Tween<double>(begin: 0.2, end: 1.0).animate(_controller);

    if (widget.isOverdue || widget.isWarning) {
      startBlinking();
    }
  }

  @override
  void didUpdateWidget(covariant BlinkingCell oldWidget) {
    super.didUpdateWidget(oldWidget);

    if ((widget.isOverdue || widget.isWarning) && !hasStartedBlinking) {
      startBlinking();
    }

    // Nếu trạng thái thay đổi giữa isOverdue và isWarning, cập nhật tốc độ nhấp nháy
    if (oldWidget.isOverdue != widget.isOverdue || oldWidget.isWarning != widget.isWarning) {
      _controller.duration = _getBlinkDuration();
      _controller.repeat(reverse: true);
    }
  }

  Duration _getBlinkDuration() {
    if (widget.isWarning) {
      return const Duration(milliseconds: 250); // Nhấp nháy nhanh hơn khi cảnh báo
    } else {
      return const Duration(milliseconds: 800); // Nhấp nháy chậm hơn khi quá hạn
    }
  }

  void startBlinking() {
    hasStartedBlinking = true;
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: (widget.isOverdue || widget.isWarning) ? _animation.value : 1.0,
          child: widget.child,
        );
      },
    );
  }
}
