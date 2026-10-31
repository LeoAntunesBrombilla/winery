import 'package:flutter/material.dart';

/// Container decorativo com uma linda imagem de fundo de videira/vinhedo e sobreposição elegante de tom vinho.
class VineyardBackground extends StatelessWidget {
  const VineyardBackground({
    required this.child,
    this.overlayOpacity = 0.85,
    super.key,
  });

  final Widget child;
  final double overlayOpacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Imagem de Fundo de Videira / Vinhedo
        Positioned.fill(
          child: Image.network(
            'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb',
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => Container(
              color: const Color(0xFF1F1215), // Fallback cor vinho escura
            ),
          ),
        ),
        // Sobreposição de Gradiente Escuro com Tom de Vinho
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF140A0C).withValues(alpha: overlayOpacity),
                  const Color(0xFF261016).withValues(alpha: overlayOpacity * 0.95),
                ],
              ),
            ),
          ),
        ),
        // Conteúdo da Tela
        Positioned.fill(child: child),
      ],
    );
  }
}
