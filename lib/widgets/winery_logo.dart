import 'package:flutter/material.dart';

/// Logotipo personalizado do Winery Finder em formato de cacho de uvas douradas com folha sobre fundo vinho.
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
    final logoBgColor = color ?? const Color(0xFF722F37); // Cor Vinho clássico (Burgundy)

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Fundo circular vinho com borda dourada sutil
          Container(
            decoration: BoxDecoration(
              color: logoBgColor,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF5C350), width: size > 40 ? 2.5 : 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          // Ícone em formato de cacho de uvas idêntico ao ícone do aplicativo
          CustomPaint(
            size: Size(size * 0.65, size * 0.65),
            painter: GrapeLogoPainter(),
          ),
        ],
      ),
    );
  }
}

class GrapeLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Cor das bagas de uva (Dourado/Âmbar Vibrante)
    final berryPaint = Paint()
      ..color = const Color(0xFFF5C350)
      ..style = PaintingStyle.fill;

    // Cor da folha da parreira (Verde Folha)
    final leafPaint = Paint()
      ..color = const Color(0xFF4A7C59)
      ..style = PaintingStyle.fill;

    // Cor do cabinho
    final stemPaint = Paint()
      ..color = const Color(0xFFF5C350)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = size.width / 2;
    final radius = size.width * 0.085;

    // Desenha o cacho de uvas (bagas em formato triangular)
    // Linha 1 (topo - 2 bagas)
    canvas.drawCircle(Offset(center - radius * 0.8, size.height * 0.38), radius, berryPaint);
    canvas.drawCircle(Offset(center + radius * 0.8, size.height * 0.38), radius, berryPaint);

    // Linha 2 (3 bagas)
    canvas.drawCircle(Offset(center - radius * 1.6, size.height * 0.54), radius, berryPaint);
    canvas.drawCircle(Offset(center, size.height * 0.52), radius, berryPaint);
    canvas.drawCircle(Offset(center + radius * 1.6, size.height * 0.54), radius, berryPaint);

    // Linha 3 (3 bagas)
    canvas.drawCircle(Offset(center - radius * 0.9, size.height * 0.70), radius, berryPaint);
    canvas.drawCircle(Offset(center + radius * 0.9, size.height * 0.70), radius, berryPaint);
    canvas.drawCircle(Offset(center, size.height * 0.68), radius, berryPaint);

    // Linha 4 (base - 1 baga)
    canvas.drawCircle(Offset(center, size.height * 0.86), radius * 0.85, berryPaint);

    // Cabinho da uva
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
