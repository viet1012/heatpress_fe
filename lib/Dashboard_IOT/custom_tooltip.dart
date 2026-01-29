import 'package:flutter/material.dart';
import 'dart:async';

class CustomTooltip extends StatefulWidget {
  final Widget child;
  final String icNotePart;
  final String details;

  const CustomTooltip({
    required this.child,
    required this.icNotePart,
    required this.details,
    super.key,
  });

  @override
  State<CustomTooltip> createState() => _CustomTooltipState();
}

class _CustomTooltipState extends State<CustomTooltip> {
  OverlayEntry? _overlayEntry;
  Timer? _hideTimer;
  bool _isPinned = false;

  void _showTooltip(BuildContext context) {
    _hideTimer?.cancel();

    if (_overlayEntry != null) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final target = renderBox.localToGlobal(Offset.zero);
    final scrollController = ScrollController(); // 👈 thêm controller

    _overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        left: target.dx,
        top: target.dy + renderBox.size.height + 5,
        child: MouseRegion(
          onEnter: (_) => _hideTimer?.cancel(),
          onExit: (_) {
            if (!_isPinned) _startHideTimer();
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 500,
              constraints: const BoxConstraints(
                maxHeight: 400, // 👈 Đặt chiều cao nhỏ hơn để dễ test cuộn
              ),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  thumbColor: MaterialStateProperty.resolveWith<Color>(
                    (states) {
                      if (states.contains(MaterialState.hovered)) {
                        return Colors.blueAccent; // Khi hover
                      }
                      return Colors.blueAccent.withOpacity(0.7); // Bình thường
                    },
                  ),
                  trackColor: MaterialStateProperty.all(
                      Colors.black12), // Nền thanh cuộn
                  trackBorderColor:
                      MaterialStateProperty.all(Colors.grey.shade400),
                  thickness: MaterialStateProperty.all(4),
                  radius: const Radius.circular(12), // Bo cong mềm mại hơn
                  thumbVisibility: MaterialStateProperty.all(true),
                ),
                child: Scrollbar(
                  controller: scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.icNotePart,
                          style: const TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.details,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        if (_isPinned)
                          Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () {
                                _isPinned = false;
                                _removeTooltip();
                              },
                              child: const Icon(
                                Icons.close,
                                color: Colors.white70,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 200), () {
      if (!_isPinned) {
        _removeTooltip();
      }
    });
  }

  void _removeTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _hideTooltip() {
    if (!_isPinned) _startHideTimer();
  }

  void _pinTooltip(BuildContext context) {
    if (_overlayEntry == null) {
      _showTooltip(context);
    }
    setState(() {
      _isPinned = true;
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _removeTooltip();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pinTooltip(context),
      child: MouseRegion(
        onEnter: (_) => _showTooltip(context),
        onExit: (_) => _hideTooltip(),
        child: widget.child,
      ),
    );
  }
}
