import 'package:flutter/material.dart';
import 'package:winery_finder/admin/admin_services.dart';
import 'package:winery_finder/admin/photo_rules.dart';
import 'package:winery_finder/admin/photo_services.dart';
import 'package:winery_finder/domain/winery.dart';
import 'package:winery_finder/widgets/winery_photo.dart';

/// Fotos de uma vinícola no app do admin (US18): enviar até 5 e excluir.
class WineryPhotosScreen extends StatefulWidget {
  const WineryPhotosScreen({
    required this.winery,
    required this.store,
    required this.picker,
    this.photoBuilder = _cachedPhoto,
    super.key,
  });

  final Winery winery;
  final PhotoStore store;
  final PhotoPicker picker;

  /// Desenha cada foto; injetável nos testes (sem rede).
  final Widget Function(String url) photoBuilder;

  static Widget _cachedPhoto(String url) => WineryPhoto(url: url);

  @override
  State<WineryPhotosScreen> createState() => _WineryPhotosScreenState();
}

class _WineryPhotosScreenState extends State<WineryPhotosScreen> {
  late final List<String> _urls = <String>[...widget.winery.photoUrls];
  bool _busy = false;

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _add() async {
    final PickedPhoto? photo = await widget.picker.pick();
    if (photo == null) {
      return;
    }
    final String? problem = PhotoRules.validate(
      fileName: photo.name,
      sizeBytes: photo.bytes.length,
      currentCount: _urls.length,
    );
    if (problem != null) {
      _message(problem);
      return;
    }
    await _run(() async {
      final String url = await widget.store.upload(widget.winery.id, photo);
      setState(() => _urls.add(url));
      _message('Foto enviada.');
    });
  }

  Future<void> _delete(String url) async {
    await _run(() async {
      await widget.store.delete(widget.winery.id, url);
      setState(() => _urls.remove(url));
      _message('Foto excluída.');
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } on AdminException catch (error) {
      _message(error.message);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool full = _urls.length >= PhotoRules.maxPhotos;
    return Scaffold(
      appBar: AppBar(title: Text('Fotos — ${widget.winery.name}')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy || full ? null : _add,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text('Adicionar (${_urls.length}/${PhotoRules.maxPhotos})'),
      ),
      body: Column(
        children: <Widget>[
          if (_busy) const LinearProgressIndicator(),
          Expanded(
            child: _urls.isEmpty
                ? const Center(child: Text('Nenhuma foto ainda.'))
                : GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(8),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: <Widget>[
                      for (final String url in _urls)
                        Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            widget.photoBuilder(url),
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton.filledTonal(
                                tooltip: 'Excluir foto',
                                onPressed: _busy ? null : () => _delete(url),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
