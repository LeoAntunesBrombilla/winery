import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:winery_finder/data/winery_repository.dart';
import 'package:winery_finder/domain/winery.dart';

/// Diálogo para edição das contribuições/vinícolas pelo usuário criador.
class EditWineryDialog extends StatefulWidget {
  const EditWineryDialog({required this.winery, super.key});

  final Winery winery;

  @override
  State<EditWineryDialog> createState() => _EditWineryDialogState();
}

class _EditWineryDialogState extends State<EditWineryDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _cityController;
  late final TextEditingController _addressController;
  late final TextEditingController _responsibleController;
  late final TextEditingController _sommelierController;
  late final TextEditingController _grapesController;
  late final TextEditingController _distanceController;
  late final TextEditingController _ratingController;

  late Set<WineType> _selectedTypes;
  final ImagePicker _picker = ImagePicker();

  String? _newLogoPath;
  Uint8List? _newLogoBytes;

  List<String> _photoPaths = [];
  final List<Uint8List> _newPhotoBytesList = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.winery.name);
    _cityController = TextEditingController(text: widget.winery.city);
    _addressController = TextEditingController(text: widget.winery.address);
    _responsibleController = TextEditingController(text: widget.winery.responsibleName);
    _sommelierController = TextEditingController(text: widget.winery.sommelierName);
    _grapesController = TextEditingController(text: widget.winery.cultivatedGrapes.join(', '));
    _distanceController = TextEditingController(text: widget.winery.distanceKm.toStringAsFixed(1));
    _ratingController = TextEditingController(text: widget.winery.rating.toStringAsFixed(1));
    _selectedTypes = Set<WineType>.from(widget.winery.wineTypes);
    _photoPaths = List<String>.from(widget.winery.photoUrls);
  }

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

  Future<void> _pickNewLogo() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _newLogoPath = image.path;
        _newLogoBytes = bytes;
      });
    }
  }

  Future<void> _pickNewPhotos() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      for (final img in images) {
        final bytes = await img.readAsBytes();
        setState(() {
          _photoPaths.add(img.path);
          _newPhotoBytesList.add(bytes);
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

    final logo = _newLogoPath ?? widget.winery.logoUrl;
    final grapes = _grapesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final updated = widget.winery.copyWith(
      name: _nameController.text.trim(),
      city: _cityController.text.trim(),
      address: _addressController.text.trim(),
      responsibleName: _responsibleController.text.trim(),
      sommelierName: _sommelierController.text.trim(),
      cultivatedGrapes: grapes,
      distanceKm: double.tryParse(_distanceController.text.replaceAll(',', '.')) ?? widget.winery.distanceKm,
      rating: double.tryParse(_ratingController.text.replaceAll(',', '.')) ?? widget.winery.rating,
      logoUrl: logo,
      photoUrls: _photoPaths,
      wineTypes: _selectedTypes,
    );

    WineryRepository.instance.updateWinery(updated);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vinícola "${updated.name}" atualizada com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text('Editar Vinícola: ${widget.winery.name}'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Logo da Vinícola:', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pickNewLogo,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Alterar Logo'),
                    ),
                    const SizedBox(width: 12),
                    if (_newLogoBytes != null)
                      ClipOval(
                        child: Image.memory(_newLogoBytes!, width: 50, height: 50, fit: BoxFit.cover),
                      )
                    else if (widget.winery.logoUrl.isNotEmpty)
                      ClipOval(
                        child: widget.winery.logoUrl.startsWith('http')
                            ? Image.network(widget.winery.logoUrl, width: 50, height: 50, fit: BoxFit.cover)
                            : Image.file(File(widget.winery.logoUrl), width: 50, height: 50, fit: BoxFit.cover),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
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
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _ratingController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Avaliação (1-5)'),
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
                  onPressed: _pickNewPhotos,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Adicionar Fotos'),
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
          child: const Text('Salvar Alterações'),
        ),
      ],
    );
  }
}
