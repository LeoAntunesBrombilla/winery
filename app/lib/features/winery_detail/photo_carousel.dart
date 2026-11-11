import 'package:flutter/material.dart';
import 'package:winery_finder/widgets/winery_photo.dart';

/// Desenha uma foto a partir da URL; injetável nos testes (sem rede).
typedef PhotoBuilder = Widget Function(String url, BoxFit fit);

Widget cachedPhoto(String url, BoxFit fit) => WineryPhoto(url: url, fit: fit);

/// Carrossel no topo da ficha (US09). Cada foto mostra um placeholder
/// enquanto carrega; sem fotos, exibe a imagem padrão. Tocar abre em tela
/// cheia.
class PhotoCarousel extends StatefulWidget {
  const PhotoCarousel({
    required this.urls,
    this.height = 220,
    this.photoBuilder = cachedPhoto,
    super.key,
  });

  final List<String> urls;
  final double height;
  final PhotoBuilder photoBuilder;

  @override
  State<PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<PhotoCarousel> {
  int _page = 0;

  void _openFullscreen(int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (BuildContext context) => FullscreenPhotos(
          urls: widget.urls,
          initialIndex: index,
          photoBuilder: widget.photoBuilder,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.urls.isEmpty) {
      return SizedBox(height: widget.height, child: const DefaultWineryImage());
    }
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: <Widget>[
          PageView.builder(
            itemCount: widget.urls.length,
            onPageChanged: (int page) => setState(() => _page = page),
            itemBuilder: (BuildContext context, int index) => GestureDetector(
              key: ValueKey<int>(index),
              onTap: () => _openFullscreen(index),
              child: widget.photoBuilder(widget.urls[index], BoxFit.cover),
            ),
          ),
          if (widget.urls.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: _Dots(count: widget.urls.length, current: _page),
            ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int i = 0; i < count; i++)
          Container(
            key: ValueKey<String>('dot-$i'),
            width: i == current ? 10 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: i == current ? 1 : 0.5),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }
}

/// Imagem padrão para vinícolas sem foto.
class DefaultWineryImage extends StatelessWidget {
  const DefaultWineryImage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[colors.primaryContainer, colors.tertiaryContainer],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.wine_bar, size: 64, color: colors.onPrimaryContainer),
            const SizedBox(height: 8),
            Text(
              'Sem fotos ainda',
              style: TextStyle(color: colors.onPrimaryContainer),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fotos em tela cheia, com zoom e deslize entre elas.
class FullscreenPhotos extends StatelessWidget {
  const FullscreenPhotos({
    required this.urls,
    required this.initialIndex,
    this.photoBuilder = cachedPhoto,
    super.key,
  });

  final List<String> urls;
  final int initialIndex;
  final PhotoBuilder photoBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: urls.length,
        itemBuilder: (BuildContext context, int index) => InteractiveViewer(
          child: Center(child: photoBuilder(urls[index], BoxFit.contain)),
        ),
      ),
    );
  }
}
