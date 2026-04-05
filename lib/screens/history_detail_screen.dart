import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/date_utils.dart' as app_date;

class HistoryDetailScreen extends StatelessWidget {
  final dynamic entry;

  const HistoryDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final isParked = entry.status == 'parked';
    final duration =
        entry.durationMinutes ??
        app_date.DateUtils.calculateDurationMinutes(
          entry.entryTime,
          entry.exitTime,
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entry Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isParked ? Icons.local_parking : Icons.check_circle,
                          color: isParked
                              ? AppColors.warning
                              : AppColors.success,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.vehicleNumber,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(entry.vehicleType),
                            ],
                          ),
                        ),
                        Chip(
                          label: Text(
                            entry.status.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: isParked
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    _buildDetailRow('Ticket ID', entry.ticketId),
                    _buildDetailRow(
                      'Entry Time',
                      app_date.DateUtils.formatDateTime(entry.entryTime),
                    ),
                    if (entry.exitTime != null)
                      _buildDetailRow(
                        'Exit Time',
                        app_date.DateUtils.formatDateTime(entry.exitTime!),
                      ),
                    _buildDetailRow(
                      'Duration',
                      app_date.DateUtils.formatDuration(duration),
                    ),
                    if (entry.amount != null)
                      _buildDetailRow('Amount', '₹${entry.amount}'),
                    if (entry.passId != null && entry.passId!.isNotEmpty)
                      _buildDetailRow('Pass ID', entry.passId),
                    if (entry.slotNumber != null)
                      _buildDetailRow('Slot', entry.slotNumber),
                    if (entry.paymentType != null)
                      _buildDetailRow('Payment', entry.paymentType),
                    if (entry.notes != null && entry.notes!.isNotEmpty)
                      _buildDetailRow('Notes', entry.notes),
                    if (entry.qrCode != null)
                      _buildDetailRow('QR Code', entry.qrCode),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
