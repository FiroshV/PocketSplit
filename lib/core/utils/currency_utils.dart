import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../constants/currencies.dart';
import '../services/currency_location_service.dart';

class CurrencyUtils {
  /// Get currency symbol using location-based detection with locale fallback
  static Future<String> getCurrencySymbolFromLocation([String? locale]) async {
    try {
      // First try to get currency based on actual location
      final locationCurrency = await _getCurrencyFromLocationService();
      if (locationCurrency != null) {
        final currency = CurrencyConstants.getCurrencyByCode(locationCurrency);
        if (currency != null) {
          final localeSymbol = currency.getLocaleSymbol(locale);
          debugPrint('CurrencyUtils.getCurrencySymbolFromLocation: using location-based currency $locationCurrency = $localeSymbol');
          return localeSymbol;
        }
      }
      
      // Fallback to locale-based detection
      return getCurrencySymbol(locale);
    } catch (e) {
      debugPrint('CurrencyUtils.getCurrencySymbolFromLocation: Error, falling back to locale-based: $e');
      // Fallback to locale-based detection
      return getCurrencySymbol(locale);
    }
  }

  /// Get currency symbol using intl package based on device locale (legacy method)
  static String getCurrencySymbol([String? locale]) {
    try {
      // Use provided locale or device locale
      final String deviceLocale = locale ?? Platform.localeName;
      
      debugPrint('CurrencyUtils.getCurrencySymbol: deviceLocale = $deviceLocale');
      
      // First, detect the currency code for this locale
      final currencyCode = getCurrencyCode(deviceLocale);
      debugPrint('CurrencyUtils.getCurrencySymbol: detected currencyCode = $currencyCode');
      
      // Find the currency in our constants and use its getLocaleSymbol method
      final currency = CurrencyConstants.getCurrencyByCode(currencyCode);
      if (currency != null) {
        final localeSymbol = currency.getLocaleSymbol(deviceLocale);
        debugPrint('CurrencyUtils.getCurrencySymbol: using Currency.getLocaleSymbol = $localeSymbol');
        return localeSymbol;
      }
      
      // Fallback: Use NumberFormat directly
      final NumberFormat format = NumberFormat.simpleCurrency(locale: deviceLocale);
      debugPrint('CurrencyUtils.getCurrencySymbol: fallback format.currencySymbol = ${format.currencySymbol}');
      return format.currencySymbol;
    } catch (e) {
      debugPrint('CurrencyUtils.getCurrencySymbol: Error getting currency symbol for locale: $e');
      // Fallback to USD symbol
      return '\$';
    }
  }

  /// Helper method to get currency from location service
  static Future<String?> _getCurrencyFromLocationService() async {
    try {
      // Use the CurrencyLocationService to detect currency based on location
      final detectedCurrency = await CurrencyLocationService.detectCurrencyFromLocation();
      debugPrint('CurrencyUtils._getCurrencyFromLocationService: detected = $detectedCurrency');
      return detectedCurrency;
    } catch (e) {
      debugPrint('CurrencyUtils._getCurrencyFromLocationService: error = $e');
      return null;
    }
  }

  /// Get currency code using intl package based on device locale
  static String getCurrencyCode([String? locale]) {
    try {
      // Use provided locale or device locale
      final String deviceLocale = locale ?? Platform.localeName;
      
      debugPrint('CurrencyUtils.getCurrencyCode: deviceLocale = $deviceLocale');
      
      // Try multiple methods to detect currency
      String? detectedCurrency;
      
      // Method 1: Use NumberFormat.simpleCurrency
      try {
        final NumberFormat format = NumberFormat.simpleCurrency(locale: deviceLocale);
        detectedCurrency = format.currencyName;
        debugPrint('CurrencyUtils.getCurrencyCode: simpleCurrency detected = $detectedCurrency (${format.currencySymbol})');
      } catch (e) {
        debugPrint('CurrencyUtils.getCurrencyCode: simpleCurrency failed: $e');
      }
      
      // Method 2: If simpleCurrency failed or returned null, try with specific currency codes
      if (detectedCurrency == null || detectedCurrency.isEmpty || detectedCurrency == 'USD') {
        debugPrint('CurrencyUtils.getCurrencyCode: Trying locale-specific detection...');
        
        // Extract country code from locale
        final parts = deviceLocale.split('_');
        if (parts.length >= 2) {
          final countryCode = parts[1].toUpperCase();
          debugPrint('CurrencyUtils.getCurrencyCode: Country code = $countryCode');
          
          // Test common currencies for this country using NumberFormat
          final countryToCurrency = {
            'GB': 'GBP', 'UK': 'GBP',
            'US': 'USD',
            'DE': 'EUR', 'FR': 'EUR', 'IT': 'EUR', 'ES': 'EUR',
            'IN': 'INR',
            'CA': 'CAD',
            'AU': 'AUD',
            'JP': 'JPY',
          };
          
          final expectedCurrency = countryToCurrency[countryCode];
          if (expectedCurrency != null) {
            // Test if this currency works with the locale
            try {
              final testFormat = NumberFormat.currency(locale: deviceLocale, name: expectedCurrency);
              if (testFormat.currencySymbol.isNotEmpty) {
                detectedCurrency = expectedCurrency;
                debugPrint('CurrencyUtils.getCurrencyCode: Country-based detection successful = $detectedCurrency (${testFormat.currencySymbol})');
              }
            } catch (e) {
              debugPrint('CurrencyUtils.getCurrencyCode: Country-based test failed for $expectedCurrency: $e');
            }
          }
        }
      }
      
      // Method 3: Final fallback using our constants
      if (detectedCurrency == null || detectedCurrency.isEmpty) {
        final parts = deviceLocale.split('_');
        if (parts.length >= 2) {
          final countryCode = parts[1].toUpperCase();
          detectedCurrency = CurrencyConstants.countryToCurrency[countryCode];
          debugPrint('CurrencyUtils.getCurrencyCode: Constants fallback = $detectedCurrency for country $countryCode');
        }
      }
      
      // Ultimate fallback
      final finalCurrency = detectedCurrency ?? 'USD';
      debugPrint('CurrencyUtils.getCurrencyCode: Final result = $finalCurrency');
      return finalCurrency;
    } catch (e) {
      debugPrint('CurrencyUtils.getCurrencyCode: Error getting currency code for locale: $e');
      // Fallback to USD
      return 'USD';
    }
  }

  /// Get currency symbol and code combination
  static String getCurrencySymbolWithCode([String? locale]) {
    final symbol = getCurrencySymbol(locale);
    final code = getCurrencyCode(locale);
    return '$symbol ($code)';
  }

  /// Format amount with proper currency symbol and locale formatting
  static String formatCurrency(double amount, [String? locale, String? currencyCode]) {
    try {
      // Use provided locale or device locale
      final String deviceLocale = locale ?? Platform.localeName;
      
      // Create NumberFormat with specified currency or auto-detect
      final NumberFormat format;
      if (currencyCode != null) {
        format = NumberFormat.currency(locale: deviceLocale, name: currencyCode);
      } else {
        format = NumberFormat.simpleCurrency(locale: deviceLocale);
      }
      
      return format.format(amount);
    } catch (e) {
      debugPrint('Error formatting currency: $e');
      // Fallback formatting
      final symbol = getCurrencySymbol(locale);
      return '$symbol${amount.toStringAsFixed(2)}';
    }
  }

  /// Format compact currency (e.g., $1.2K, $1.5M)
  static String formatCompactCurrency(double amount, [String? locale, String? currencyCode]) {
    try {
      final String deviceLocale = locale ?? Platform.localeName;
      
      final NumberFormat format;
      if (currencyCode != null) {
        format = NumberFormat.compactCurrency(locale: deviceLocale, name: currencyCode);
      } else {
        format = NumberFormat.compactSimpleCurrency(locale: deviceLocale);
      }
      
      return format.format(amount);
    } catch (e) {
      debugPrint('Error formatting compact currency: $e');
      // Fallback to regular formatting
      return formatCurrency(amount, locale, currencyCode);
    }
  }

  /// Get currency information from locale
  static CurrencyInfo getCurrencyInfoFromLocale([String? locale]) {
    final String deviceLocale = locale ?? Platform.localeName;
    debugPrint('CurrencyUtils.getCurrencyInfoFromLocale: deviceLocale = $deviceLocale');
    
    final symbol = getCurrencySymbol(deviceLocale);
    final code = getCurrencyCode(deviceLocale);
    
    debugPrint('CurrencyUtils.getCurrencyInfoFromLocale: detected symbol = $symbol, code = $code');
    
    // Try to find the currency in our constants
    final currency = CurrencyConstants.getCurrencyByCode(code);
    debugPrint('CurrencyUtils.getCurrencyInfoFromLocale: found currency in constants = ${currency?.code}');
    
    final countryFromLocale = _getCountryFromLocale(deviceLocale);
    debugPrint('CurrencyUtils.getCurrencyInfoFromLocale: country from locale = $countryFromLocale');
    
    return CurrencyInfo(
      code: code,
      symbol: symbol,
      name: currency?.name ?? code,
      country: currency?.country ?? countryFromLocale,
      locale: deviceLocale,
    );
  }

  /// Extract country from locale string
  static String _getCountryFromLocale(String locale) {
    try {
      final parts = locale.split('_');
      if (parts.length >= 2) {
        return parts[1].toUpperCase();
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  /// Check if a currency code is supported by the intl package
  static bool isCurrencySupported(String currencyCode, [String? locale]) {
    try {
      final String deviceLocale = locale ?? Platform.localeName;
      NumberFormat.currency(locale: deviceLocale, name: currencyCode);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get all available currency codes for a locale
  static List<String> getAvailableCurrencies([String? locale]) {
    final String deviceLocale = locale ?? Platform.localeName;
    final List<String> availableCurrencies = [];
    
    // Test common currencies to see which ones are supported
    for (final currency in CurrencyConstants.supportedCurrencies) {
      if (isCurrencySupported(currency.code, deviceLocale)) {
        availableCurrencies.add(currency.code);
      }
    }
    
    return availableCurrencies;
  }

  /// Get currency suggestions based on locale and common currencies
  static List<CurrencyInfo> getCurrencySuggestions([String? locale]) {
    final String deviceLocale = locale ?? Platform.localeName;
    final detectedCurrency = getCurrencyInfoFromLocale(deviceLocale);
    final List<CurrencyInfo> suggestions = [detectedCurrency];
    
    // Add common currencies that are different from detected one
    const commonCodes = ['USD', 'EUR', 'GBP', 'INR', 'CAD', 'AUD'];
    for (final code in commonCodes) {
      if (code != detectedCurrency.code) {
        final currency = CurrencyConstants.getCurrencyByCode(code);
        if (currency != null) {
          // Get symbol using intl if possible, fallback to hardcoded
          String symbol;
          try {
            symbol = NumberFormat.currency(locale: deviceLocale, name: code).currencySymbol;
          } catch (e) {
            symbol = currency.symbol;
          }
          
          suggestions.add(CurrencyInfo(
            code: code,
            symbol: symbol,
            name: currency.name,
            country: currency.country,
            locale: deviceLocale,
          ));
        }
      }
    }
    
    return suggestions;
  }
}

/// Enhanced currency information class that includes locale data
class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;
  final String country;
  final String locale;

  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
    required this.country,
    required this.locale,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyInfo &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => '$symbol $code - $name';

  /// Get formatted display string with location context
  String toDisplayString({bool showDetected = false}) {
    if (showDetected) {
      return '$symbol $code - $name (Detected)';
    }
    return '$symbol $code - $name ($country)';
  }

  /// Convert to Currency object for backward compatibility
  Currency toCurrency() {
    return Currency(
      code: code,
      name: name,
      symbol: symbol,
      country: country,
    );
  }
}