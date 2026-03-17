import 'dart:math';

import 'package:flutter/material.dart';

class CaptchaWidget extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final VoidCallback? onTap; // 点击刷新用（可选）

  const CaptchaWidget({
    super.key,
    required this.text,
    this.width = 100,
    this.height = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final painter = _CaptchaPainter(text);
    final child = CustomPaint(
      size: Size(width, height),
      painter: painter,
    );
    return GestureDetector(
      onTap: onTap,
      child: child,
    );
  }
}
class _CaptchaPainter extends CustomPainter {
  final String text;
  final List<Offset> _lineStarts;
  final List<Offset> _lineEnds;

  _CaptchaPainter(this.text)
      : _lineStarts = [],
        _lineEnds = [] {
    final rand = Random(text.hashCode); // 用 text 做种子，保证同一 text 生成的噪点固定
    for (int i = 0; i < 6; i++) {
      _lineStarts.add(Offset(rand.nextDouble(), rand.nextDouble()));
      _lineEnds.add(Offset(rand.nextDouble(), rand.nextDouble()));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = Colors.grey.shade200;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 画干扰线：按之前生成好的相对坐标画
    final linePaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;
    for (var i = 0; i < _lineStarts.length; i++) {
      final p1 = Offset(
        _lineStarts[i].dx * size.width,
        _lineStarts[i].dy * size.height,
      );
      final p2 = Offset(
        _lineEnds[i].dx * size.width,
        _lineEnds[i].dy * size.height,
      );
      canvas.drawLine(p1, p2, linePaint);
    }

    // 画文字（和你原来一样）
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      letterSpacing: 3,
    );
    final span = TextSpan(text: text, style: textStyle);
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr)
      ..layout();
    final dx = (size.width - tp.width) / 2;
    final dy = (size.height - tp.height) / 2;
    tp.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant _CaptchaPainter oldDelegate) =>
      oldDelegate.text != text;
}