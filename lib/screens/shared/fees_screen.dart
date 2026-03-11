import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/mock_data_service.dart';

/// Fees Screen – fee overview, payment history, and pay button.
class FeesScreen extends StatelessWidget {
  const FeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fee = MockDataService.demoFeeRecord;
    return Scaffold(
      appBar: const GradientAppBar(title: 'Fees & Payments', showBackButton: true),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Fee Overview Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppConstants.radiusXl),
              ),
              child: Column(
                children: [
                  const Text('Total Fees', style: TextStyle(color: AppColors.textOnDarkMuted, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('₹ ${fee.totalFees.toStringAsFixed(0)}',
                    style: const TextStyle(color: AppColors.textOnDark, fontSize: 32, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: fee.paidPercentage / 100,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _col('Paid', '₹ ${fee.paidFees.toStringAsFixed(0)}', AppColors.success),
                      Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.2)),
                      _col('Pending', '₹ ${fee.pendingFees.toStringAsFixed(0)}', AppColors.warning),
                      Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.2)),
                      _col('Progress', '${fee.paidPercentage.round()}%', AppColors.accent),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Pay Fees Button
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _showPaymentDialog(context),
                icon: const Icon(Icons.payment),
                label: const Text('Pay Fees Now'),
              ),
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Payment History'),
            ...fee.payments.map((p) => _paymentCard(p)),
          ],
        ),
      ),
    );
  }

  Widget _col(String label, String value, Color color) {
    return Column(children: [
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 16)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: AppColors.textOnDarkMuted, fontSize: 11)),
    ]);
  }

  Widget _paymentCard(dynamic payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.check_circle, color: AppColors.success, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('₹ ${payment.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          Text('${payment.date.day}/${payment.date.month}/${payment.date.year} • ${payment.method.toUpperCase()}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSubtle)),
        ])),
        Text(payment.receiptId, style: const TextStyle(fontSize: 11, color: AppColors.textSubtle)),
      ]),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Payment Gateway'),
      content: const Text('Placeholder for Razorpay/Stripe integration.\nConfigure API keys during deployment.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
    ));
  }
}
