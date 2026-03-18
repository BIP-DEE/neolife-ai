import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.compact = false,
    this.showTagline = true,
  });

  final bool compact;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final titleStyle = (compact
            ? Theme.of(context).textTheme.titleLarge
            : Theme.of(context).textTheme.headlineSmall)
        ?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: -0.7,
      color: AppTheme.primaryDeep,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandSymbol(compact: compact),
        SizedBox(width: compact ? 10 : 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'NeoLife',
                    style: titleStyle,
                  ),
                  TextSpan(
                    text: ' AI',
                    style: titleStyle?.copyWith(
                      color: AppTheme.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (!compact && showTagline) ...[
              const SizedBox(height: 4),
              Text(
                'Intelligent infant wellness monitoring',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                    ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class BrandSymbol extends StatelessWidget {
  const BrandSymbol({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compact ? 66 : 94,
      height: compact ? 22 : 30,
      child: CustomPaint(
        painter: _NeoPulsePainter(),
      ),
    );
  }
}

class _NeoPulsePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = size.height * 0.34
      ..shader = const LinearGradient(
        colors: [
          AppTheme.primaryDeep,
          AppTheme.primary,
          AppTheme.secondary,
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Offset.zero & size);

    final path = Path()
      ..moveTo(size.width * 0.02, size.height * 0.84)
      ..quadraticBezierTo(
        size.width * 0.22,
        size.height * 0.46,
        size.width * 0.43,
        size.height * 0.72,
      )
      ..lineTo(size.width * 0.59, size.height * 0.08)
      ..lineTo(size.width * 0.70, size.height * 0.76)
      ..lineTo(size.width * 0.98, size.height * 0.22);

    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
