import '../providers/currency_provider.dart';

String formatCurrency(double amount) {
  final currency = CurrencyNotifier().currency;
  return '${currency.symbol} ${amount.abs().toStringAsFixed(2)}';
} 