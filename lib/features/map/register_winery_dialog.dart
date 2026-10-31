import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:winery_finder/data/auth_repository.dart';
import 'package:winery_finder/data/winery_repository.dart';
import 'package:winery_finder/domain/winery.dart';

class RegisterWineryDialog extends StatefulWidget {
  const RegisterWineryDialog({super.key});

  @override
  State<RegisterWineryDialog> createState() => _RegisterWineryDialogState();
}

class _RegisterWineryDialogState extends State<RegisterWineryDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController(text: 'Bento Gonçalves');
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _responsibleController = TextEditingController();
  final TextEditingController _sommelierController = TextEditingController();
  final TextEditingController _grapesController = TextEditingController(text: 'Cabernet Sauvignon, Merlot, Chardonnay');
  final TextEditingController _distanceController = TextEditingController(text: '3.0');
  final TextEditingController _ratingController = TextEditingController(text: '4.8');
  
  final Set<WineType> _selectedTypes = <WineType>{WineType.tinto};

  final ImagePicker _picker = ImagePicker();
  String? _logoPath;
  Uint8List? _logoBytes;
  
  final List<String> _photoPaths = <String>[];
  final List<Uint8List> _photoBytesList = <Uint8List>[];

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _responsibleController.dispose();
    _sommelierController.dispose();
    _grapesController.dispose();
    _distanceController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _logoPath = image.path;
        _logoBytes = bytes;
      });
    }
  }

  Future<void> _pickPhotos() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      for (final img in images) {
        final bytes = await img.readAsBytes();
        setState(() {
          _photoPaths.add(img.path);
          _photoBytesList.add(bytes);
        });
      }
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione ao menos um tipo de vinho.')),
      );
      return;
    }

    final random = Random();
    final double lat = -29.1683 + (random.nextDouble() - 0.5) * 0.08;
    final double lng = -51.5204 + (random.nextDouble() - 0.5) * 0.08;

    final logoUrl = _logoPath ?? 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3';
    final photos = _photoPaths.isNotEmpty ? _photoPaths : <String>[];

    final grapes = _grapesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final currentUser = AuthRepository.instance.currentUser;

    final winery = Winery(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      city: _cityController.text.trim(),
      wineTypes: _selectedTypes,
      distanceKm: double.tryParse(_distanceController.text.replaceAll(',', '.')) ?? 3.0,
      rating: double.tryParse(_ratingController.text.replaceAll(',', '.')) ?? 4.8,
      latitude: lat,
      longitude: lng,
      address: _addressController.text.trim(),
      logoUrl: logoUrl,
      photoUrls: photos,
      responsibleName: _responsibleController.text.trim(),
      sommelierName: _sommelierController.text.trim(),
      cultivatedGrapes: grapes,
      creatorEmail: currentUser?.email ?? 'admin@winery.com',
    );

    WineryRepository.instance.addWinery(winery);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vinícola "${winery.name}" cadastrada com sucesso por ${winery.creatorEmail}!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Cadastrar Nova Vinícola'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 1. Logo da Vinícola (em primeiro)
                Text('Logo da Vinícola *:', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pickLogo,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Escolher Logo'),
                    ),
                    const SizedBox(width: 12),
                    if (_logoBytes != null)
                      ClipOval(
                        child: Image.memory(
                          _logoBytes!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      const Text('Nenhum logo selecionado'),
                  ],
                ),
                const SizedBox(height: 16),
                // 2. Nome do Proprietário / Responsável (em segundo)
                TextFormField(
                  controller: _responsibleController,
                  decoration: const InputDecoration(labelText: 'Nome do Proprietário / Responsável *'),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Informe o responsável' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nome da Vinícola *'),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'Cidade / Região *'),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Informe a cidade' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Endereço Completo'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _distanceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Distância (km)'),
                        validator: (val) => double.tryParse(val?.replaceAll(',', '.') ?? '') == null ? 'Inválido' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _ratingController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Avaliação (1-5)'),
                        validator: (val) {
                          final d = double.tryParse(val?.replaceAll(',', '.') ?? '');
                          if (d == null || d < 1 || d > 5) return 'Entre 1 e 5';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _sommelierController,
                  decoration: const InputDecoration(labelText: 'Sommelier'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _grapesController,
                  decoration: const InputDecoration(labelText: 'Uvas Cultivadas (separadas por vírgula)'),
                ),
                const SizedBox(height: 16),
                Text('Fotos da Vinícola:', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _pickPhotos,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Adicionar Fotos'),
                ),
                const SizedBox(height: 8),
                if (_photoBytesList.isNotEmpty)
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _photoBytesList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              _photoBytesList[index],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                Text('Tipos de Vinho *:', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: WineType.values.map((type) {
                    final isSelected = _selectedTypes.contains(type);
                    return FilterChip(
                      label: Text(type.label),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTypes.add(type);
                          } else {
                            _selectedTypes.remove(type);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Cadastrar'),
        ),
      ],
    );
  }
}
