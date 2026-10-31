import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:winery_finder/data/wine_repository.dart';
import 'package:winery_finder/domain/wine_product.dart';
import 'package:winery_finder/domain/winery.dart';

class RegisterWineDialog extends StatefulWidget {
  const RegisterWineDialog({required this.winery, super.key});

  final Winery winery;

  @override
  State<RegisterWineDialog> createState() => _RegisterWineDialogState();
}

class _RegisterWineDialogState extends State<RegisterWineDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _grapeController = TextEditingController();
  final TextEditingController _vintageController = TextEditingController(text: '2022');
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _paymentLinkController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  WineType _selectedType = WineType.tinto;

  final ImagePicker _picker = ImagePicker();
  String? _winePhotoPath;
  Uint8List? _winePhotoBytes;

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

  Future<void> _pickWinePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _winePhotoPath = image.path;
        _winePhotoBytes = bytes;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0;

    final wine = WineProduct(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      wineryId: widget.winery.id,
      name: _nameController.text.trim(),
      type: _selectedType,
      grape: _grapeController.text.trim(),
      vintage: _vintageController.text.trim(),
      price: price,
      paymentLink: _paymentLinkController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: _winePhotoPath ?? '',
    );

    WineRepository.instance.addWine(wine);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vinho "${wine.name}" cadastrado e vinculado a "${widget.winery.name}" por R\$ ${price.toStringAsFixed(2)}!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Postar Vinho para Venda'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Card de Vinculação com a Vinícola
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wine_bar, color: Color(0xFF722F37)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Vinícola Vinculada:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(widget.winery.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nome do Vinho *'),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Informe o nome do vinho' : null,
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
                        decoration: const InputDecoration(labelText: 'Uva Utilizada (ex: Merlot, Tannat)'),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Informe a uva' : null,
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
                        decoration: const InputDecoration(labelText: 'Safra (ex: 2021, NV)'),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Informe a safra' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Preço (R\$) *'),
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
                    labelText: 'Link de Pagamento / Compra (MercadoPago, WhatsApp, Loja)',
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Foto do Vinho:', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pickWinePhoto,
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Selecionar Foto do Vinho'),
                    ),
                    const SizedBox(width: 12),
                    if (_winePhotoBytes != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.memory(
                          _winePhotoBytes!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      const Text('Nenhuma foto selecionada'),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Breve Descrição / Notas de Degustação',
                    alignLabelWithHint: true,
                  ),
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
          child: const Text('Postar Vinho'),
        ),
      ],
    );
  }
}
