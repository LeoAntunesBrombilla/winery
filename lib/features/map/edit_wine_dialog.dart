import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:winery_finder/data/wine_repository.dart';
import 'package:winery_finder/domain/wine_product.dart';
import 'package:winery_finder/domain/winery.dart';

/// Diálogo para edição completa do vinho, incluindo alteração de preço e novas fotos.
class EditWineDialog extends StatefulWidget {
  const EditWineDialog({required this.wine, super.key});

  final WineProduct wine;

  @override
  State<EditWineDialog> createState() => _EditWineDialogState();
}

class _EditWineDialogState extends State<EditWineDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _grapeController;
  late final TextEditingController _vintageController;
  late final TextEditingController _priceController;
  late final TextEditingController _paymentLinkController;
  late final TextEditingController _descriptionController;

  late WineType _selectedType;
  final ImagePicker _picker = ImagePicker();
  String? _newPhotoPath;
  Uint8List? _newPhotoBytes;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wine.name);
    _grapeController = TextEditingController(text: widget.wine.grape);
    _vintageController = TextEditingController(text: widget.wine.vintage);
    _priceController = TextEditingController(text: widget.wine.price.toStringAsFixed(2));
    _paymentLinkController = TextEditingController(text: widget.wine.paymentLink);
    _descriptionController = TextEditingController(text: widget.wine.description);
    _selectedType = widget.wine.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _grapeController.dispose();
    _vintageController.dispose();
    _priceController.dispose();
    _paymentLinkController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickNewPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _newPhotoPath = image.path;
        _newPhotoBytes = bytes;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? widget.wine.price;
    final photo = _newPhotoPath ?? widget.wine.imageUrl;

    final updated = widget.wine.copyWith(
      name: _nameController.text.trim(),
      type: _selectedType,
      grape: _grapeController.text.trim(),
      vintage: _vintageController.text.trim(),
      price: price,
      paymentLink: _paymentLinkController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: photo,
    );

    WineRepository.instance.updateWine(updated);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vinho e preço atualizados com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text('Editar Vinho: ${widget.wine.name}'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nome do Vinho *'),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<WineType>(
                        initialValue: _selectedType,
                        decoration: const InputDecoration(labelText: 'Tipo de Vinho'),
                        items: WineType.values.map((t) {
                          return DropdownMenuItem(value: t, child: Text(t.label));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedType = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _grapeController,
                        decoration: const InputDecoration(labelText: 'Uva Utilizada'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _vintageController,
                        decoration: const InputDecoration(labelText: 'Safra'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Preço de Venda (R\$) *'),
                        validator: (val) {
                          if (val == null || double.tryParse(val.replaceAll(',', '.')) == null) {
                            return 'Preço inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _paymentLinkController,
                  decoration: const InputDecoration(
                    labelText: 'Link de Pagamento / Checkout',
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Nova Foto do Vinho:', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pickNewPhoto,
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Carregar Foto do Computador'),
                    ),
                    const SizedBox(width: 12),
                    if (_newPhotoBytes != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.memory(_newPhotoBytes!, width: 50, height: 50, fit: BoxFit.cover),
                      )
                    else if (widget.wine.imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: widget.wine.imageUrl.startsWith('http')
                            ? Image.network(widget.wine.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                            : Image.file(File(widget.wine.imageUrl), width: 50, height: 50, fit: BoxFit.cover),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Descrição do Vinho'),
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
