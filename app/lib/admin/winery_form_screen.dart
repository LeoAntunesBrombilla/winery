import 'package:flutter/material.dart';
import 'package:winery_finder/admin/admin_services.dart';
import 'package:winery_finder/admin/winery_form_data.dart';
import 'package:winery_finder/domain/coordinates.dart';
import 'package:winery_finder/domain/tasting_price.dart';
import 'package:winery_finder/domain/weekly_hours.dart';
import 'package:winery_finder/domain/winery.dart';

/// Cadastro e edição de vinícola (US17). Campos obrigatórios vazios
/// impedem salvar e mostram a mensagem no próprio campo.
class WineryFormScreen extends StatefulWidget {
  const WineryFormScreen({required this.store, this.editing, super.key});

  final AdminWineryStore store;

  /// Vinícola em edição, ou `null` para cadastrar uma nova.
  final Winery? editing;

  @override
  State<WineryFormScreen> createState() => _WineryFormScreenState();
}

class _WineryFormScreenState extends State<WineryFormScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  late final Winery? _editing = widget.editing;

  late final TextEditingController _name = _text(_editing?.name);
  late final TextEditingController _city = _text(_editing?.city);
  late final TextEditingController _address = _text(_editing?.address);
  late final TextEditingController _latitude = _text(
    _editing?.coordinates.latitude.toString(),
  );
  late final TextEditingController _longitude = _text(
    _editing?.coordinates.longitude.toString(),
  );
  late final List<TextEditingController> _days = <TextEditingController>[
    for (int weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++)
      _text(
        _editing == null
            ? null
            : WineryFormValidators.dayInput(_editing.hours.on(weekday)),
      ),
  ];
  late final TextEditingController _price = _text(
    _editing == null
        ? null
        : TastingPrice.formatInput(_editing.tastingPriceCents),
  );
  late final TextEditingController _rating = _text(
    _editing?.rating?.toString(),
  );
  late final TextEditingController _phone = _text(_editing?.phone);
  late final TextEditingController _website = _text(_editing?.website);
  late bool _requiresReservation = _editing?.requiresReservation ?? false;
  late final Set<WineType> _wineTypes = <WineType>{...?_editing?.wineTypes};
  bool _saving = false;

  static TextEditingController _text(String? value) =>
      TextEditingController(text: value ?? '');

  @override
  void dispose() {
    for (final TextEditingController controller in <TextEditingController>[
      _name,
      _city,
      _address,
      _latitude,
      _longitude,
      ..._days,
      _price,
      _rating,
      _phone,
      _website,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  WineryFormData _data() {
    String? optional(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();
    return WineryFormData(
      name: _name.text.trim(),
      city: _city.text.trim(),
      address: _address.text.trim(),
      location: Coordinates(
        WineryFormValidators.parseDecimal(_latitude.text)!,
        WineryFormValidators.parseDecimal(_longitude.text)!,
      ),
      wineTypes: _wineTypes,
      hours: WeeklyHours(<int, OpeningInterval>{
        for (int i = 0; i < _days.length; i++)
          if (WineryFormValidators.parseDay(_days[i].text)
              case final OpeningInterval interval)
            i + 1: interval,
      }),
      tastingPriceCents: TastingPrice.parseCents(_price.text)!,
      requiresReservation: _requiresReservation,
      rating: optional(_rating) == null
          ? null
          : WineryFormValidators.parseDecimal(_rating.text),
      phone: optional(_phone),
      website: optional(_website),
    );
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) {
      return;
    }
    setState(() => _saving = true);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final NavigatorState navigator = Navigator.of(context);
    try {
      final Winery? editing = _editing;
      if (editing == null) {
        await widget.store.create(_data());
      } else {
        await widget.store.update(editing.id, _data());
      }
      navigator.pop(true);
    } on AdminException catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
    String? hint,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, hintText: hint),
        validator: validator,
        keyboardType: keyboard,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    const TextInputType decimal = TextInputType.numberWithOptions(
      decimal: true,
      signed: true,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing == null ? 'Nova vinícola' : 'Editar vinícola'),
      ),
      // Column (e não ListView) para todos os campos ficarem montados: o
      // Form só valida campos montados, e um ListView descarta os que saem
      // da tela.
      body: Form(
        key: _form,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _field(_name, 'Nome *', validator: WineryFormValidators.required),
              _field(
                _city,
                'Cidade *',
                validator: WineryFormValidators.required,
              ),
              _field(
                _address,
                'Endereço *',
                validator: WineryFormValidators.required,
              ),
              _field(
                _latitude,
                'Latitude *',
                hint: '-29.1756',
                keyboard: decimal,
                validator: WineryFormValidators.latitude,
              ),
              _field(
                _longitude,
                'Longitude *',
                hint: '-51.5577',
                keyboard: decimal,
                validator: WineryFormValidators.longitude,
              ),
              const SizedBox(height: 8),
              Text('Tipos de vinho', style: theme.textTheme.titleSmall),
              Wrap(
                spacing: 8,
                children: <Widget>[
                  for (final WineType type in WineType.values)
                    FilterChip(
                      label: Text(type.label),
                      selected: _wineTypes.contains(type),
                      onSelected: (bool selected) => setState(
                        () => selected
                            ? _wineTypes.add(type)
                            : _wineTypes.remove(type),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Horários *', style: theme.textTheme.titleSmall),
              for (int i = 0; i < _days.length; i++)
                _field(
                  _days[i],
                  WeeklyHours.labels[i],
                  hint: '09:00-17:00 ou fechado',
                  validator: WineryFormValidators.day,
                ),
              _field(
                _price,
                r'Degustação por pessoa (R$) *',
                hint: '85,00',
                keyboard: decimal,
                validator: WineryFormValidators.price,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Exige reserva'),
                value: _requiresReservation,
                onChanged: (bool value) =>
                    setState(() => _requiresReservation = value),
              ),
              _field(
                _rating,
                'Nota da equipe (0 a 5)',
                keyboard: decimal,
                validator: WineryFormValidators.rating,
              ),
              _field(_phone, 'Telefone', keyboard: TextInputType.phone),
              _field(_website, 'Site', keyboard: TextInputType.url),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
