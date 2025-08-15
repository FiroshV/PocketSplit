import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../services/currency_location_service.dart';
import '../constants/currencies.dart';
import 'currency_utils.dart';

class CurrencyTestUtils {
  /// Test currency detection and log detailed results
  static Future<void> testCurrencyDetection() async {
    // Use both debugPrint and developer.log for better visibility
    _log('=== Currency Detection Test Started ===');
    
    // 1. Show raw platform info
    _log('Platform.localeName: ${Platform.localeName}');
    _log('Platform.operatingSystem: ${Platform.operatingSystem}');
    
    // 2. Test CurrencyUtils directly
    _log('--- Testing CurrencyUtils ---');
    final detectedCode = CurrencyUtils.getCurrencyCode();
    final detectedSymbol = CurrencyUtils.getCurrencySymbol();
    _log('CurrencyUtils detected: $detectedCode ($detectedSymbol)');
    
    // 3. Test CurrencyLocationService
    _log('--- Testing CurrencyLocationService ---');
    // Clear cache first
    CurrencyLocationService.clearCache();
    final serviceCurrency = await CurrencyLocationService.detectCurrencyFromLocation();
    _log('CurrencyLocationService detected: $serviceCurrency');
    
    // 4. Show what currency this maps to in our constants
    final currency = CurrencyConstants.getCurrencyByCode(serviceCurrency);
    if (currency != null) {
      _log('Currency details: ${currency.name} (${currency.symbol}) - ${currency.country}');
      
      // Test getLocaleSymbol
      final localeSymbol = currency.getLocaleSymbol();
      _log('Locale-specific symbol: $localeSymbol');
    }
    
    // 5. Test country code extraction
    final parts = Platform.localeName.split('_');
    if (parts.length >= 2) {
      final countryCode = parts[1].toUpperCase();
      final mappedCurrency = CurrencyConstants.countryToCurrency[countryCode];
      _log('Country code: $countryCode -> Mapped currency: $mappedCurrency');
    }
    
    _log('=== Currency Detection Test Completed ===');
  }
  
  static void _log(String message) {
    // Use multiple logging methods to ensure visibility
    debugPrint('CURRENCY_TEST: $message');
    developer.log(message, name: 'CurrencyTest');
  }
  
  /// Force specific currency for testing
  static void forceTestCurrency(String currencyCode) {
    debugPrint('CurrencyTestUtils: Forcing currency to $currencyCode for testing');
    CurrencyLocationService.setCurrencyOverride(currencyCode);
  }
  
  /// Reset to automatic detection
  static Future<String> resetToAutoDetection() async {
    debugPrint('CurrencyTestUtils: Resetting to automatic detection');
    CurrencyLocationService.clearCache();
    return await CurrencyLocationService.detectCurrencyFromLocation();
  }
}