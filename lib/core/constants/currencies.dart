import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class Currency {
  final String code;
  final String name;
  final String symbol;
  final String country;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.country,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => '$code - $name ($symbol)';

  /// Get locale-specific currency symbol using intl package
  String getLocaleSymbol([String? locale]) {
    try {
      final String deviceLocale = locale ?? Platform.localeName;
      final NumberFormat format = NumberFormat.currency(
        locale: deviceLocale,
        name: code,
      );
      debugPrint('Currency.getLocaleSymbol: $code with locale $deviceLocale = ${format.currencySymbol}');

      return format.currencySymbol;
    } catch (e) {
      debugPrint('Currency.getLocaleSymbol: Error getting locale symbol for $code: $e');
      // Fallback to hardcoded symbol
      return symbol;
    }
  }

  /// Format amount with this currency using locale-specific formatting
  String formatAmount(double amount, [String? locale]) {
    try {
      final String deviceLocale = locale ?? Platform.localeName;
      final NumberFormat format = NumberFormat.currency(
        locale: deviceLocale,
        name: code,
      );
      return format.format(amount);
    } catch (e) {
      debugPrint('Error formatting amount for $code: $e');
      // Fallback formatting
      return '$symbol${amount.toStringAsFixed(2)}';
    }
  }

  /// Format compact amount (e.g., $1.2K)
  String formatCompactAmount(double amount, [String? locale]) {
    try {
      final String deviceLocale = locale ?? Platform.localeName;
      final NumberFormat format = NumberFormat.compactCurrency(
        locale: deviceLocale,
        name: code,
      );
      return format.format(amount);
    } catch (e) {
      debugPrint('Error formatting compact amount for $code: $e');
      // Fallback to regular formatting
      return formatAmount(amount, locale);
    }
  }

  /// Get display string with locale-specific symbol
  String toDisplayString([String? locale]) {
    final localeSymbol = getLocaleSymbol(locale);
    return '$localeSymbol $code - $name';
  }

  /// Get display string with country info
  String toDisplayStringWithCountry([String? locale]) {
    final localeSymbol = getLocaleSymbol(locale);
    return '$localeSymbol $code - $name ($country)';
  }
}

class CurrencyConstants {
  static const List<Currency> supportedCurrencies = [
    Currency(
      code: 'USD',
      name: 'US Dollar',
      symbol: '\$',
      country: 'United States',
    ),
    Currency(code: 'EUR', name: 'Euro', symbol: '€', country: 'European Union'),
    Currency(
      code: 'GBP',
      name: 'British Pound',
      symbol: '£',
      country: 'United Kingdom',
    ),
    Currency(code: 'INR', name: 'Indian Rupee', symbol: '₹', country: 'India'),
    Currency(
      code: 'CAD',
      name: 'Canadian Dollar',
      symbol: 'C\$',
      country: 'Canada',
    ),
    Currency(
      code: 'AUD',
      name: 'Australian Dollar',
      symbol: 'A\$',
      country: 'Australia',
    ),
    Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥', country: 'Japan'),
    Currency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥', country: 'China'),
    Currency(
      code: 'CHF',
      name: 'Swiss Franc',
      symbol: 'Fr',
      country: 'Switzerland',
    ),
    Currency(
      code: 'SGD',
      name: 'Singapore Dollar',
      symbol: 'S\$',
      country: 'Singapore',
    ),
    Currency(
      code: 'HKD',
      name: 'Hong Kong Dollar',
      symbol: 'HK\$',
      country: 'Hong Kong',
    ),
    Currency(
      code: 'NZD',
      name: 'New Zealand Dollar',
      symbol: 'NZ\$',
      country: 'New Zealand',
    ),
    Currency(
      code: 'SEK',
      name: 'Swedish Krona',
      symbol: 'kr',
      country: 'Sweden',
    ),
    Currency(
      code: 'NOK',
      name: 'Norwegian Krone',
      symbol: 'kr',
      country: 'Norway',
    ),
    Currency(
      code: 'DKK',
      name: 'Danish Krone',
      symbol: 'kr',
      country: 'Denmark',
    ),
    Currency(
      code: 'PLN',
      name: 'Polish Złoty',
      symbol: 'zł',
      country: 'Poland',
    ),
    Currency(
      code: 'CZK',
      name: 'Czech Koruna',
      symbol: 'Kč',
      country: 'Czech Republic',
    ),
    Currency(
      code: 'HUF',
      name: 'Hungarian Forint',
      symbol: 'Ft',
      country: 'Hungary',
    ),
    Currency(
      code: 'RUB',
      name: 'Russian Ruble',
      symbol: '₽',
      country: 'Russia',
    ),
    Currency(
      code: 'BRL',
      name: 'Brazilian Real',
      symbol: 'R\$',
      country: 'Brazil',
    ),
    Currency(
      code: 'MXN',
      name: 'Mexican Peso',
      symbol: '\$',
      country: 'Mexico',
    ),
    Currency(
      code: 'ARS',
      name: 'Argentine Peso',
      symbol: '\$',
      country: 'Argentina',
    ),
    Currency(
      code: 'KRW',
      name: 'South Korean Won',
      symbol: '₩',
      country: 'South Korea',
    ),
    Currency(code: 'THB', name: 'Thai Baht', symbol: '฿', country: 'Thailand'),
    Currency(
      code: 'MYR',
      name: 'Malaysian Ringgit',
      symbol: 'RM',
      country: 'Malaysia',
    ),
    Currency(
      code: 'PHP',
      name: 'Philippine Peso',
      symbol: '₱',
      country: 'Philippines',
    ),
    Currency(
      code: 'IDR',
      name: 'Indonesian Rupiah',
      symbol: 'Rp',
      country: 'Indonesia',
    ),
    Currency(
      code: 'VND',
      name: 'Vietnamese Dong',
      symbol: '₫',
      country: 'Vietnam',
    ),
    Currency(
      code: 'ZAR',
      name: 'South African Rand',
      symbol: 'R',
      country: 'South Africa',
    ),
    Currency(
      code: 'EGP',
      name: 'Egyptian Pound',
      symbol: '£',
      country: 'Egypt',
    ),
    Currency(
      code: 'AED',
      name: 'UAE Dirham',
      symbol: 'د.إ',
      country: 'United Arab Emirates',
    ),
    Currency(
      code: 'SAR',
      name: 'Saudi Riyal',
      symbol: '﷼',
      country: 'Saudi Arabia',
    ),
    Currency(code: 'QAR', name: 'Qatari Riyal', symbol: '﷼', country: 'Qatar'),
    Currency(
      code: 'KWD',
      name: 'Kuwaiti Dinar',
      symbol: 'د.ك',
      country: 'Kuwait',
    ),
    Currency(
      code: 'BHD',
      name: 'Bahraini Dinar',
      symbol: '.د.ب',
      country: 'Bahrain',
    ),
    Currency(code: 'OMR', name: 'Omani Rial', symbol: '﷼', country: 'Oman'),
    Currency(
      code: 'JOD',
      name: 'Jordanian Dinar',
      symbol: 'د.ا',
      country: 'Jordan',
    ),
    Currency(
      code: 'LBP',
      name: 'Lebanese Pound',
      symbol: '£',
      country: 'Lebanon',
    ),
    Currency(code: 'TRY', name: 'Turkish Lira', symbol: '₺', country: 'Turkey'),
    Currency(
      code: 'ILS',
      name: 'Israeli Shekel',
      symbol: '₪',
      country: 'Israel',
    ),
  ];

  // Country code to currency mapping for location-based detection
  static const Map<String, String> countryToCurrency = {
    'US': 'USD',
    'United States': 'USD',
    'EU': 'EUR',
    'DE': 'EUR',
    'FR': 'EUR',
    'IT': 'EUR',
    'ES': 'EUR',
    'NL': 'EUR',
    'AT': 'EUR',
    'BE': 'EUR',
    'FI': 'EUR',
    'IE': 'EUR',
    'PT': 'EUR',
    'GR': 'EUR',
    'LU': 'EUR',
    'MT': 'EUR',
    'CY': 'EUR',
    'SK': 'EUR',
    'SI': 'EUR',
    'EE': 'EUR',
    'LV': 'EUR',
    'LT': 'EUR',
    'GB': 'GBP',
    'UK': 'GBP',
    'United Kingdom': 'GBP',
    'IN': 'INR',
    'India': 'INR',
    'CA': 'CAD',
    'Canada': 'CAD',
    'AU': 'AUD',
    'Australia': 'AUD',
    'JP': 'JPY',
    'Japan': 'JPY',
    'CN': 'CNY',
    'China': 'CNY',
    'CH': 'CHF',
    'Switzerland': 'CHF',
    'SG': 'SGD',
    'Singapore': 'SGD',
    'HK': 'HKD',
    'Hong Kong': 'HKD',
    'NZ': 'NZD',
    'New Zealand': 'NZD',
    'SE': 'SEK',
    'Sweden': 'SEK',
    'NO': 'NOK',
    'Norway': 'NOK',
    'DK': 'DKK',
    'Denmark': 'DKK',
    'PL': 'PLN',
    'Poland': 'PLN',
    'CZ': 'CZK',
    'Czech Republic': 'CZK',
    'HU': 'HUF',
    'Hungary': 'HUF',
    'RU': 'RUB',
    'Russia': 'RUB',
    'BR': 'BRL',
    'Brazil': 'BRL',
    'MX': 'MXN',
    'Mexico': 'MXN',
    'AR': 'ARS',
    'Argentina': 'ARS',
    'KR': 'KRW',
    'South Korea': 'KRW',
    'TH': 'THB',
    'Thailand': 'THB',
    'MY': 'MYR',
    'Malaysia': 'MYR',
    'PH': 'PHP',
    'Philippines': 'PHP',
    'ID': 'IDR',
    'Indonesia': 'IDR',
    'VN': 'VND',
    'Vietnam': 'VND',
    'ZA': 'ZAR',
    'South Africa': 'ZAR',
    'EG': 'EGP',
    'Egypt': 'EGP',
    'AE': 'AED',
    'United Arab Emirates': 'AED',
    'SA': 'SAR',
    'Saudi Arabia': 'SAR',
    'QA': 'QAR',
    'Qatar': 'QAR',
    'KW': 'KWD',
    'Kuwait': 'KWD',
    'BH': 'BHD',
    'Bahrain': 'BHD',
    'OM': 'OMR',
    'Oman': 'OMR',
    'JO': 'JOD',
    'Jordan': 'JOD',
    'LB': 'LBP',
    'Lebanon': 'LBP',
    'TR': 'TRY',
    'Turkey': 'TRY',
    'IL': 'ILS',
    'Israel': 'ILS',
  };

  static Currency? getCurrencyByCode(String code) {
    try {
      return supportedCurrencies.firstWhere(
        (currency) => currency.code == code,
      );
    } catch (e) {
      return null;
    }
  }

  static Currency get defaultCurrency => supportedCurrencies.first; // USD

  static String getCurrencyForCountry(String countryCode) {
    return countryToCurrency[countryCode] ?? defaultCurrency.code;
  }
}
