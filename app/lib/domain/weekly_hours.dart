/// Período em que a vinícola fica aberta num dia, em minutos desde 00:00.
class OpeningInterval {
  const OpeningInterval(this.opensAt, this.closesAt)
    : assert(opensAt < closesAt, 'fecha antes de abrir');

  final int opensAt;
  final int closesAt;

  static final RegExp _pattern = RegExp(
    r'^(\d{1,2})(?:[:h](\d{2}))?h?\s*(?:-|–|a|às)\s*(\d{1,2})(?:[:h](\d{2}))?h?$',
  );

  /// Lê "09:00-17:00", "9h-17h", "9h às 17h30". Devolve `null` se o texto
  /// não for um intervalo válido.
  static OpeningInterval? tryParse(String raw) {
    final RegExpMatch? match = _pattern.firstMatch(raw.trim().toLowerCase());
    if (match == null) {
      return null;
    }
    final int? opens = _minutes(match.group(1)!, match.group(2));
    final int? closes = _minutes(match.group(3)!, match.group(4));
    if (opens == null || closes == null || opens >= closes) {
      return null;
    }
    return OpeningInterval(opens, closes);
  }

  /// Lê o formato gravado no Firestore: "HH:MM".
  static int? parseClock(String raw) {
    final List<String> parts = raw.split(':');
    if (parts.length != 2) {
      return null;
    }
    return _minutes(parts[0], parts[1]);
  }

  static int? _minutes(String hours, String? minutes) {
    final int h = int.parse(hours);
    final int m = minutes == null ? 0 : int.parse(minutes);
    if (h > 24 || m > 59 || (h == 24 && m > 0)) {
      return null;
    }
    return h * 60 + m;
  }

  static String clock(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
      '${(minutes % 60).toString().padLeft(2, '0')}';

  /// "09:00 – 17:00".
  String format() => '${clock(opensAt)} – ${clock(closesAt)}';

  bool contains(int minuteOfDay) =>
      minuteOfDay >= opensAt && minuteOfDay < closesAt;

  @override
  bool operator ==(Object other) =>
      other is OpeningInterval &&
      other.opensAt == opensAt &&
      other.closesAt == closesAt;

  @override
  int get hashCode => Object.hash(opensAt, closesAt);
}

/// Horário de cada dia da semana; dia sem intervalo = fechado.
class WeeklyHours {
  const WeeklyHours(this.days);

  /// Todos os dias fechados.
  static const WeeklyHours closed = WeeklyHours(<int, OpeningInterval>{});

  /// Chave de cada dia no Firestore, na ordem de [DateTime.monday] (1) a
  /// [DateTime.sunday] (7).
  static const List<String> keys = <String>[
    'mon',
    'tue',
    'wed',
    'thu',
    'fri',
    'sat',
    'sun',
  ];

  /// Nome de cada dia exibido na ficha, na mesma ordem de [keys].
  static const List<String> labels = <String>[
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];

  /// Intervalo de cada dia, indexado por [DateTime.weekday].
  final Map<int, OpeningInterval> days;

  /// Intervalo do dia [weekday] (1 = segunda), ou `null` se fechado.
  OpeningInterval? on(int weekday) => days[weekday];

  /// Aberta no instante [time] (hora local).
  bool isOpenAt(DateTime time) =>
      on(time.weekday)?.contains(time.hour * 60 + time.minute) ?? false;

  @override
  bool operator ==(Object other) {
    if (other is! WeeklyHours || other.days.length != days.length) {
      return false;
    }
    return days.entries.every(
      (MapEntry<int, OpeningInterval> e) => other.days[e.key] == e.value,
    );
  }

  @override
  int get hashCode => Object.hashAllUnordered(
    days.entries.map(
      (MapEntry<int, OpeningInterval> e) => Object.hash(e.key, e.value),
    ),
  );
}
