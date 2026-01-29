import 'package:flutter/material.dart';
import 'dart:math' as math;

// Enum cho các loại animation
enum InductionAnimationType {
  pulse, // Phóng to/thu nhỏ
  bounce, // Nhảy lên xuống
  fade, // Mờ dần/sáng dần
  shake, // Lắc qua lại
  glow, // Phát sáng
  wave, // Sóng
  typewriter, // Hiệu ứng đánh máy
  rainbow, // Đổi màu cầu vồng
  shimmer, // Shimmer effect
  rotate, // Xoay
  slide, // Trượt
  gradient, // Gradient animation
}

// Class chính cho Animated INDUCTION Text
class AnimatedInductionText extends StatefulWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final InductionAnimationType animationType;
  final Duration duration;
  final bool repeat;

  const AnimatedInductionText({
    Key? key,
    this.text = 'INDUCTION',
    this.fontSize = 20,
    this.color = Colors.blueAccent,
    this.fontWeight = FontWeight.normal,
    this.animationType = InductionAnimationType.pulse,
    this.duration = const Duration(seconds: 2),
    this.repeat = true,
  }) : super(key: key);

  @override
  State<AnimatedInductionText> createState() => _AnimatedInductionTextState();
}

class _AnimatedInductionTextState extends State<AnimatedInductionText>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _setupAnimation();

    if (widget.repeat) {
      if (widget.animationType == InductionAnimationType.pulse ||
          widget.animationType == InductionAnimationType.glow ||
          widget.animationType == InductionAnimationType.fade) {
        _controller.repeat(reverse: true);
      } else {
        _controller.repeat();
      }
    } else {
      _controller.forward();
    }
  }

  void _setupAnimation() {
    switch (widget.animationType) {
      case InductionAnimationType.pulse:
        _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        break;
      case InductionAnimationType.bounce:
        _animation = Tween<double>(begin: 0, end: 20).animate(
          CurvedAnimation(parent: _controller, curve: Curves.bounceOut),
        );
        break;
      case InductionAnimationType.fade:
        _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        break;
      case InductionAnimationType.shake:
        _animation = Tween<double>(begin: -10, end: 10).animate(
          CurvedAnimation(parent: _controller, curve: Curves.elasticInOut),
        );
        break;
      case InductionAnimationType.glow:
        _animation = Tween<double>(begin: 0, end: 10).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        break;
      case InductionAnimationType.rotate:
        _animation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
          CurvedAnimation(parent: _controller, curve: Curves.linear),
        );
        break;
      case InductionAnimationType.slide:
        _animation = Tween<double>(begin: -100, end: 0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        );
        break;
      default:
        _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    }

    // Color animation cho rainbow effect
    _colorAnimation = ColorTween(
      begin: widget.color,
      end: widget.color == Colors.blueAccent ? Colors.red : Colors.blueAccent,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        switch (widget.animationType) {
          case InductionAnimationType.pulse:
            return Transform.scale(
              scale: _animation.value,
              child: _buildText(),
            );

          case InductionAnimationType.bounce:
            return Transform.translate(
              offset: Offset(0, -_animation.value),
              child: _buildText(),
            );

          case InductionAnimationType.fade:
            return Opacity(
              opacity: _animation.value,
              child: _buildText(),
            );

          case InductionAnimationType.shake:
            return Transform.translate(
              offset: Offset(_animation.value, 0),
              child: _buildText(),
            );

          case InductionAnimationType.glow:
            return Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.6),
                    blurRadius: _animation.value,
                    spreadRadius: _animation.value / 2,
                  ),
                ],
              ),
              child: _buildText(),
            );

          case InductionAnimationType.wave:
            return _buildWaveText();

          case InductionAnimationType.typewriter:
            return _buildTypewriterText();

          case InductionAnimationType.rainbow:
            return _buildText(color: _colorAnimation.value);

          case InductionAnimationType.shimmer:
            return _buildShimmerText();

          case InductionAnimationType.rotate:
            return Transform.rotate(
              angle: _animation.value,
              child: _buildText(),
            );

          case InductionAnimationType.slide:
            return Transform.translate(
              offset: Offset(_animation.value, 0),
              child: _buildText(),
            );

          case InductionAnimationType.gradient:
            return _buildGradientText();

          default:
            return _buildText();
        }
      },
    );
  }

  Widget _buildText({Color? color}) {
    return Text(
      widget.text,
      style: TextStyle(
        color: color ?? widget.color,
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
      ),
    );
  }

  Widget _buildWaveText() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widget.text.split('').asMap().entries.map((entry) {
        int index = entry.key;
        String char = entry.value;
        double delay = index * 0.1;
        double waveOffset =
            math.sin((_controller.value * 2 * math.pi) + delay) * 5;

        return Transform.translate(
          offset: Offset(0, waveOffset),
          child: Text(
            char,
            style: TextStyle(
              color: widget.color,
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypewriterText() {
    int visibleChars = (_animation.value * widget.text.length).round();
    String visibleText =
        widget.text.substring(0, visibleChars.clamp(0, widget.text.length));

    return Text(
      visibleText + (_controller.status == AnimationStatus.forward ? '|' : ''),
      style: TextStyle(
        color: widget.color,
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
      ),
    );
  }

  Widget _buildShimmerText() {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            widget.color.withOpacity(0.3),
            widget.color,
            widget.color.withOpacity(0.3),
          ],
          stops: [
            _animation.value - 0.3,
            _animation.value,
            _animation.value + 0.3,
          ].map((e) => e.clamp(0.0, 1.0)).toList(),
        ).createShader(bounds);
      },
      child: _buildText(color: Colors.white),
    );
  }

  Widget _buildGradientText() {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: const [
            Colors.blue,
            Colors.purple,
            Colors.red,
            Colors.orange,
            Colors.yellow,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          transform: GradientRotation(_animation.value * 2 * math.pi),
        ).createShader(bounds);
      },
      child: _buildText(color: Colors.white),
    );
  }
}
