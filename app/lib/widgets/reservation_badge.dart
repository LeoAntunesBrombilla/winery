import 'package:flutter/material.dart';

/// Selo que diz se a visita exige reserva antecipada (US07). Usado na ficha
/// e no card do pin do mapa.
class ReservationBadge extends StatelessWidget {
  const ReservationBadge({required this.requiresReservation, super.key});

  static const String requiredLabel = 'Reserva obrigatória';
  static const String notRequiredLabel = 'Sem necessidade de reserva';

  final bool requiresReservation;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(
        requiresReservation ? Icons.event_busy : Icons.event_available,
        size: 18,
        color: requiresReservation ? colors.onErrorContainer : colors.primary,
      ),
      label: Text(requiresReservation ? requiredLabel : notRequiredLabel),
      backgroundColor: requiresReservation
          ? colors.errorContainer
          : colors.surfaceContainerHighest,
      visualDensity: VisualDensity.compact,
    );
  }
}
