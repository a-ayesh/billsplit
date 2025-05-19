
// Helper function to format currency
import 'package:splitwise/notifiers/currency_notifier.dart';

String formatCurrency(double amount) {
  final currency = CurrencyNotifier().currency;
  return '${currency.symbol} ${amount.abs().toStringAsFixed(2)}';
}