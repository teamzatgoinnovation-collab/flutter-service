import 'package:flutter/material.dart';

import '../models/service_models.dart';

class TicketStatusChip extends StatelessWidget {
  const TicketStatusChip({super.key, required this.status});

  final TicketStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      TicketStatus.open => ('Open', const Color(0xFF64748B)),
      TicketStatus.scheduled => ('Scheduled', const Color(0xFF2563EB)),
      TicketStatus.inProgress => ('In progress', const Color(0xFFD97706)),
      TicketStatus.awaitingSignature => (
        'Awaiting sign-off',
        const Color(0xFF7C3AED),
      ),
      TicketStatus.closed => ('Closed', const Color(0xFF15803D)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
    );
  }
}

class PriorityChip extends StatelessWidget {
  const PriorityChip({super.key, required this.priority});

  final TicketPriority priority;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (priority) {
      TicketPriority.low => ('Low', const Color(0xFF64748B)),
      TicketPriority.normal => ('Normal', const Color(0xFF0F766E)),
      TicketPriority.high => ('High', const Color(0xFFD97706)),
      TicketPriority.urgent => ('Urgent', const Color(0xFFB91C1C)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
    );
  }
}
