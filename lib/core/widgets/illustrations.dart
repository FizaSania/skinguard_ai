import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Small smiling face oval used on the Full Face questionnaire.
class FaceAvatar extends StatelessWidget {
  const FaceAvatar({super.key, this.width = 64});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * 1.3,
      child: CustomPaint(painter: _FacePainter()),
    );
  }
}

class _FacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawOval(rect, Paint()..color = AppColors.skin);
    canvas.drawOval(
        rect.deflate(0.5),
        Paint()
          ..color = AppColors.skinBorder
          ..style = PaintingStyle.stroke);
    final stroke = Paint()
      ..color = const Color(0xFF8A6A55)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final w = size.width, h = size.height;
    canvas.drawLine(Offset(w * .32, h * .45), Offset(w * .42, h * .45), stroke);
    canvas.drawLine(Offset(w * .58, h * .45), Offset(w * .68, h * .45), stroke);
    canvas.drawArc(Rect.fromCenter(center: Offset(w * .5, h * .58), width: w * .24, height: h * .1),
        0.2, 2.7, false, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Sun + patch illustration for the lighting guide.
class LightingGuideIllustration extends StatelessWidget {
  const LightingGuideIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 64,
      child: CustomPaint(painter: _LightingPainter()),
    );
  }
}

class _LightingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sun = Offset(10, size.height / 2);
    canvas.drawCircle(sun, 8, Paint()..color = const Color(0xFFF7E19A));
    canvas.drawCircle(
        sun,
        8,
        Paint()
          ..color = AppColors.star
          ..style = PaintingStyle.stroke);
    final ray = Paint()
      ..color = AppColors.star
      ..strokeWidth = 1.4;
    for (final dy in [-6.0, 0.0, 6.0]) {
      canvas.drawLine(Offset(22, sun.dy + dy * 0.8), Offset(34, sun.dy + dy), ray);
    }
    final patch = Offset(size.width - 30, size.height / 2);
    canvas.drawCircle(patch, 28, Paint()..color = AppColors.skin);
    canvas.drawCircle(
        patch,
        28,
        Paint()
          ..color = AppColors.skinBorder
          ..style = PaintingStyle.stroke);
    canvas.drawCircle(patch, 6, Paint()..color = const Color(0xFFDD7A66));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Simple illustrated bottle used as a product image placeholder.
///
/// FUTURE BACKEND INTEGRATION: replace with the product image URL.
class ProductBottle extends StatelessWidget {
  const ProductBottle({super.key, required this.color, this.height = 72});

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final w = height * 0.62;
    return SizedBox(
      width: w,
      height: height,
      child: Column(
        children: [
          Container(
            width: w * 0.42,
            height: height * 0.16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
            ),
          ),
          Expanded(
            child: Container(
              width: w,
              decoration: BoxDecoration(
                color: Color.lerp(color, Colors.white, 0.78),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color, width: 2),
              ),
              alignment: Alignment.center,
              child: Container(
                width: w * 0.45,
                height: w * 0.4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
