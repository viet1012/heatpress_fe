import 'dart:async';

import 'package:flutter/material.dart';

class FlyingSanta extends StatefulWidget {
  final double height;
  const FlyingSanta({super.key, this.height = 40});

  @override
  _FlyingSantaState createState() => _FlyingSantaState();
}

class _FlyingSantaState extends State<FlyingSanta> {
  double posX = -150; // bắt đầu ngoài màn hình
  late double screenWidth;

  @override
  void initState() {
    super.initState();

    // Lặp lại chuyển động 5 giây/lần
    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted) return;

      setState(() {
        posX += 3; // tốc độ bay
        if (posX > screenWidth + 150) posX = -150; // bay xong quay lại
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 30),
      left: posX,
      top: 0,
      child: Image.asset(
        "assets/animated-santa-claus-image-0404.gif",
        height: widget.height,
      ),
    );
  }
}
