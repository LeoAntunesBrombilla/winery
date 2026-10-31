import 'package:flutter/material.dart';

/// Logotipo personalizado do Winery Finder em formato de cacho de uvas com folha e cor vinho.
class WineryLogo extends StatelessWidget {
  const WineryLogo({
    this.size = 40.0,
    this.color,
    super.key,
  });

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? const Color(0xFF722F37); // Cor Vinho clássico (Burgundy)

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Fundo circular com borda sutil
          Container(
            decoration: BoxDecoration(
              color: logoColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: logoColor, width: 2),
            ),
          ),
          // Ícone em formato de cacho de uvas
          CustomPaint(
            size: Size(size * 0.65, size * 0.65),
            painter: GrapeLogoPainter(color: logoColor),
          ),
        ],
      ),
    );
  }
}

class GrapeLogoPainter extends CustomPainter {
  GrapeLogoPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final leafPaint = Paint()
      ..color = const Color(0xFF4A7C59) // Verde folha sutil
      ..style = PaintingStyle.fill;

    final center = size.width / 2;
    final radius = size.width * 0.085;

    // Desenha o cacho de uvas (bagas em formato triangular)
    // Linha 1 (topo - 2 bagas)
    canvas.drawCircle(Offset(center - radius * 0.8, size.height * 0.38), radius, paint);
    canvas.drawCircle(Offset(center + radius * 0.8, size.height * 0.38), radius, paint);

    // Linha 2 (3 bagas)
    canvas.drawCircle(Offset(center - radius * 1.6, size.height * 0.54), radius, paint);
    canvas.drawCircle(Offset(center, size.height * 0.52), radius, paint);
    canvas.drawCircle(Offset(center + radius * 1.6, size.height * 0.54), radius, paint);

    // Linha 3 (3 bagas)
    canvas.drawCircle(Offset(center - radius * 0.9, size.height * 0.70), radius, paint);
    canvas.drawCircle(Offset(center + radius * 0.9, size.height * 0.70), radius, paint);
    canvas.drawCircle(Offset(center, size.height * 0.68), radius, paint);

    // Linha 4 (base - 1 baga)
    canvas.drawCircle(Offset(center, size.height * 0.86), radius * 0.85, paint);

    // Cauculo do Cabinho
    final stemPaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(center, size.height * 0.30)
      ..quadraticBezierTo(center, size.height * 0.16, center + size.width * 0.22, size.height * 0.14);
    canvas.drawPath(path, stemPaint);

    // Folha da parreira
    final leafPath = Path()
      ..moveTo(center + size.width * 0.12, size.height * 0.20)
      ..quadraticBezierTo(center + size.width * 0.32, size.height * 0.06, center + size.width * 0.38, size.height * 0.22)
      ..quadraticBezierTo(center + size.width * 0.22, size.height * 0.30, center + size.width * 0.12, size.height * 0.20);
    canvas.drawPath(leafPath, leafPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
