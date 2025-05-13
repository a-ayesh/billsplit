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

const List<Currency> currencies = [
  Currency(code: 'PKR', name: 'Pakistani Rupee', symbol: 'Rs'),
  Currency(code: 'USD', name: 'US Dollar', symbol: '\$'),
  Currency(code: 'EUR', name: 'Euro', symbol: '€'),
  Currency(code: 'GBP', name: 'British Pound', symbol: '£'),
  Currency(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
  Currency(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$'),
  Currency(code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$'),
];
