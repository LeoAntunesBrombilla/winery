import 'package:flutter/material.dart';

/// Logotipo realista sem bordas do Winery Finder, em formato de cacho de uvas roxas fotográficas com brilho 3D.
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
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: RealisticGrapeLogoPainter(),
      ),
    );
  }
}

class RealisticGrapeLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.width / 2;
    final cy = size.height * 0.52;
    final radius = size.width * 0.11;

    // Desenha uma baga de uva realista com brilho/sombra 3D
    void drawBerry(double bx, double by, double r) {
      final rect = Rect.fromCircle(center: Offset(bx, by), radius: r);
      final gradient = RadialGradient(
        center: const Alignment(-0.35, -0.4),
        radius: 0.85,
        colors: const [
          Color(0xFFE1BEE7), // Brilho de foto (Highlight)
          Color(0xFF8E24AA), // Roxo Vibrante
          Color(0xFF4A148C), // Roxo Profundo Sombra
        ],
        stops: const [0.0, 0.45, 1.0],
      );

      final paint = Paint()..shader = gradient.createShader(rect);
      canvas.drawCircle(Offset(bx, by), r, paint);

      // Borda de profundidade
      final borderPaint = Paint()
        ..color = const Color(0xFF2A0845).withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      canvas.drawCircle(Offset(bx, by), r, borderPaint);
    }

    // 1. Folha Verde Realista no Topo
    final leafPath = Path()
      ..moveTo(center + size.width * 0.05, cy * 0.35)
      ..quadraticBezierTo(center + size.width * 0.28, cy * 0.10, center + size.width * 0.38, cy * 0.30)
      ..quadraticBezierTo(center + size.width * 0.20, cy * 0.45, center + size.width * 0.05, cy * 0.35);

    final leafGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [Color(0xFF66BB6A), Color(0xFF2E7D32)],
    );
    final leafPaint = Paint()..shader = leafGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(leafPath, leafPaint);

    // Cabinho
    final stemPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final stemPath = Path()
      ..moveTo(center, cy * 0.45)
      ..quadraticBezierTo(center, cy * 0.25, center + size.width * 0.18, cy * 0.20);
    canvas.drawPath(stemPath, stemPaint);

    // 2. Camadas do Cacho de Uvas Roxas Realistas
    // Camada traseira
    drawBerry(center - radius * 0.9, cy * 0.65, radius * 0.9);
    drawBerry(center + radius * 0.9, cy * 0.65, radius * 0.9);
    drawBerry(center - radius * 1.5, cy * 0.85, radius * 0.95);
    drawBerry(center + radius * 1.5, cy * 0.85, radius * 0.95);

    // Camada principal frontal
    drawBerry(center - radius * 0.8, cy * 0.72, radius);
    drawBerry(center + radius * 0.8, cy * 0.72, radius);
    drawBerry(center - radius * 1.4, cy * 0.92, radius);
    drawBerry(center, cy * 0.88, radius * 1.05);
    drawBerry(center + radius * 1.4, cy * 0.92, radius);

    // Camada inferior
    drawBerry(center - radius * 0.75, cy * 1.10, radius);
    drawBerry(center + radius * 0.75, cy * 1.10, radius);
    drawBerry(center, cy * 1.08, radius * 1.08);

    // Ponta do cacho
    drawBerry(center - radius * 0.4, cy * 1.28, radius * 0.9);
    drawBerry(center + radius * 0.4, cy * 1.28, radius * 0.9);
    drawBerry(center, cy * 1.44, radius * 0.85);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
