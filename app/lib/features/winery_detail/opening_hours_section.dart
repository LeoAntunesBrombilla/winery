import 'package:flutter/material.dart';
import 'package:winery_finder/domain/weekly_hours.dart';

/// Horário de cada dia da semana na ficha (US05), com o dia de hoje
/// destacado e "Fechado" nos dias sem funcionamento.
class OpeningHoursSection extends StatelessWidget {
  const OpeningHoursSection({
    required this.hours,
    required this.today,
    super.key,
  });

  final WeeklyHours hours;

  /// Dia da semana atual ([DateTime.weekday]: 1 = segunda).
  final int today;

  static const String closedLabel = 'Fechado';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Horário de funcionamento', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        for (
          int weekday = DateTime.monday;
          weekday <= DateTime.sunday;
          weekday++
        )
          _DayRow(
            key: ValueKey<int>(weekday),
            label: WeeklyHours.labels[weekday - 1],
            value: hours.on(weekday)?.format() ?? closedLabel,
            isToday: weekday == today,
          ),
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.label,
    required this.value,
    required this.isToday,
    super.key,
  });

  final String label;
  final String value;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? style = isToday
        ? theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          )
        : theme.textTheme.bodyLarge;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isToday ? theme.colorScheme.primaryContainer : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(isToday ? '$label (hoje)' : label, style: style),
            ),
            Text(value, style: style),
          ],
        ),
      ),
    );
  }
}
