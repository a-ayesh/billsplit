class Currency {
  final String code;
  final String name;
  final String symbol;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
  });
}

final List<Currency> currencies = [
  const Currency(code: 'PKR', name: 'Pakistani Rupee', symbol: '₨'),
  const Currency(code: 'USD', name: 'US Dollar', symbol: '\$'),
  const Currency(code: 'EUR', name: 'Euro', symbol: '€'),
  const Currency(code: 'GBP', name: 'British Pound', symbol: '£'),
  const Currency(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
  const Currency(code: 'AED', name: 'UAE Dirham', symbol: 'د.إ'),
  const Currency(code: 'SAR', name: 'Saudi Riyal', symbol: '﷼'),
  const Currency(code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$'),
  const Currency(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$'),
  const Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
]; 