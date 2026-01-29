import 'package:flutter/material.dart';

// Class animation cho icon
class AnimatedIconWidget extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final AnimationType animationType;
  final Duration duration;

  const AnimatedIconWidget({
    Key? key,
    required this.icon,
    required this.color,
    this.size = 16,
    this.animationType = AnimationType.pulse,
    this.duration = const Duration(seconds: 1),
  }) : super(key: key);

  @override
  State<AnimatedIconWidget> createState() => _AnimatedIconWidgetState();
}

class _AnimatedIconWidgetState extends State<AnimatedIconWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    switch (widget.animationType) {
      case AnimationType.pulse:
        _animation = Tween<double>(
          begin: 0.8,
          end: 1.4,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        ));
        break;
      case AnimationType.bounce:
        _animation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.elasticOut,
        ));
        break;
      case AnimationType.rotate:
        _animation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.linear,
        ));
        break;
      case AnimationType.shake:
        _animation = Tween<double>(
          begin: -0.1,
          end: 0.1,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.elasticInOut,
        ));
        break;
    }

    _startAnimation();
  }

  void _startAnimation() {
    if (widget.animationType == AnimationType.pulse ||
        widget.animationType == AnimationType.shake) {
      _animationController.repeat(reverse: true);
    } else if (widget.animationType == AnimationType.rotate) {
      _animationController.repeat();
    } else {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        switch (widget.animationType) {
          case AnimationType.pulse:
            return Transform.scale(
              scale: _animation.value,
              child: Icon(
                widget.icon,
                color: widget.color,
                size: widget.size,
              ),
            );
          case AnimationType.bounce:
            return Transform.translate(
              offset: Offset(0, -10 * _animation.value),
              child: Icon(
                widget.icon,
                color: widget.color,
                size: widget.size,
              ),
            );
          case AnimationType.rotate:
            return Transform.rotate(
              angle: _animation.value * 2 * 3.14159,
              child: Icon(
                widget.icon,
                color: widget.color,
                size: widget.size,
              ),
            );
          case AnimationType.shake:
            return Transform.translate(
              offset: Offset(_animation.value * 20, 0),
              child: Icon(
                widget.icon,
                color: widget.color,
                size: widget.size,
              ),
            );
        }
      },
    );
  }
}

// Enum để định nghĩa các loại animation
enum AnimationType {
  pulse, // Phóng to/thu nhỏ
  bounce, // Nhảy lên xuống
  rotate, // Quay tròn
  shake, // Lắc qua lại
}
