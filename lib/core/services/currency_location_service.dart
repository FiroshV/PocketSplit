import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import '../constants/currencies.dart';
import '../utils/currency_utils.dart';

class CurrencyLocationService {
  static String? _cachedCurrency;
  
  /// Get currency based on device location/locale
  static Future<String> detectCurrencyFromLocation() async {
    if (_cachedCurrency != null) {
      debugPrint('CurrencyLocationService: Using cached currency: $_cachedCurrency');
      return _cachedCurrency!;
    }

    try {
      debugPrint('CurrencyLocationService: Starting currency detection...');
      
      // First try actual location-based detection (GPS/IP)
      final deviceCurrency = await _getCurrencyFromDevice();
      if (deviceCurrency != null) {
        _cachedCurrency = deviceCurrency;
        debugPrint('CurrencyLocationService: Location-based detection successful: $deviceCurrency');
        return deviceCurrency;
      }

      // Fallback to system locale only if location fails
      final currency = _getCurrencyFromLocale();
      if (currency != null) {
        _cachedCurrency = currency;
        debugPrint('CurrencyLocationService: Fallback to locale-based detection: $currency');
        return currency;
      }

      // Ultimate fallback
      _cachedCurrency = CurrencyConstants.defaultCurrency.code;
      debugPrint('CurrencyLocationService: Using default currency fallback: $_cachedCurrency');
      return _cachedCurrency!;
    } catch (e) {
      debugPrint('CurrencyLocationService: Error detecting currency from location: $e');
      _cachedCurrency = CurrencyConstants.defaultCurrency.code;
      debugPrint('CurrencyLocationService: Error fallback to default currency: $_cachedCurrency');
      return _cachedCurrency!;
    }
  }

  /// Get currency from device locale using intl package
  static String? _getCurrencyFromLocale() {
    try {
      if (kIsWeb) {
        // For web, we could use browser APIs but for now return null
        debugPrint('CurrencyLocationService: Running on web, skipping locale detection');
        return null;
      }

      debugPrint('CurrencyLocationService: Starting currency detection from locale');
      debugPrint('CurrencyLocationService: Platform.localeName = ${Platform.localeName}');
      
      // Use intl package to get currency from locale
      final currencyInfo = CurrencyUtils.getCurrencyInfoFromLocale();
      debugPrint('CurrencyLocationService: Device locale: ${currencyInfo.locale}');
      debugPrint('CurrencyLocationService: Detected currency: ${currencyInfo.code} (${currencyInfo.symbol})');
      
      // Validate that the detected currency is in our supported list
      final supportedCurrency = CurrencyConstants.getCurrencyByCode(currencyInfo.code);
      if (supportedCurrency != null) {
        debugPrint('CurrencyLocationService: Successfully detected currency from locale: ${currencyInfo.code}');
        return currencyInfo.code;
      } else {
        debugPrint('CurrencyLocationService: Detected currency ${currencyInfo.code} not in supported list, trying fallback');
        
        // Fallback to manual country mapping for unsupported currencies
        final locale = Platform.localeName;
        final parts = locale.split('_');
        
        debugPrint('CurrencyLocationService: Locale parts: $parts');
        
        if (parts.length >= 2) {
          final countryCode = parts[1].toUpperCase();
          final currency = CurrencyConstants.countryToCurrency[countryCode];
          
          debugPrint('CurrencyLocationService: Fallback - Country code: $countryCode, Mapped currency: $currency');
          
          if (currency != null) {
            debugPrint('CurrencyLocationService: Successfully detected currency from fallback mapping: $currency ($countryCode)');
            return currency;
          }
        } else {
          debugPrint('CurrencyLocationService: Locale does not have country code, parts: $parts');
        }
      }

      debugPrint('CurrencyLocationService: No currency detected from locale');
      return null;
    } catch (e) {
      debugPrint('CurrencyLocationService: Error getting currency from locale: $e');
      return null;
    }
  }

  /// Get currency from device location (GPS or IP-based)
  static Future<String?> _getCurrencyFromDevice() async {
    try {
      debugPrint('CurrencyLocationService: Starting location-based currency detection...');
      
      // First try GPS location
      final gpsCountry = await _getCountryFromGPS();
      if (gpsCountry != null) {
        final currency = CurrencyConstants.countryToCurrency[gpsCountry];
        if (currency != null) {
          debugPrint('CurrencyLocationService: GPS detection successful - Country: $gpsCountry, Currency: $currency');
          return currency;
        }
      }

      // Fallback to IP geolocation
      final ipCountry = await _getCountryFromIP();
      if (ipCountry != null) {
        final currency = CurrencyConstants.countryToCurrency[ipCountry];
        if (currency != null) {
          debugPrint('CurrencyLocationService: IP detection successful - Country: $ipCountry, Currency: $currency');
          return currency;
        }
      }

      debugPrint('CurrencyLocationService: No location-based currency detected');
      return null;
    } catch (e) {
      debugPrint('CurrencyLocationService: Error getting currency from device location: $e');
      return null;
    }
  }

  /// Get country code from GPS location using reverse geocoding
  static Future<String?> _getCountryFromGPS() async {
    try {
      debugPrint('CurrencyLocationService: Checking GPS location permissions...');
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('CurrencyLocationService: Location services are disabled');
        return null;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('CurrencyLocationService: Requesting location permission...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('CurrencyLocationService: Location permission denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('CurrencyLocationService: Location permission permanently denied');
        return null;
      }

      // Get current position
      debugPrint('CurrencyLocationService: Getting GPS position...');
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
      
      debugPrint('CurrencyLocationService: GPS position - Lat: ${position.latitude}, Lng: ${position.longitude}');

      // Get country from coordinates using reverse geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final country = placemarks.first.isoCountryCode?.toUpperCase();
        debugPrint('CurrencyLocationService: Reverse geocoding result - Country: $country');
        return country;
      }

      debugPrint('CurrencyLocationService: No placemarks found from GPS coordinates');
      return null;
    } catch (e) {
      debugPrint('CurrencyLocationService: GPS location error: $e');
      return null;
    }
  }

  /// Get country code from IP geolocation as fallback
  static Future<String?> _getCountryFromIP() async {
    try {
      debugPrint('CurrencyLocationService: Attempting IP geolocation...');
      
      // Use ipapi.co free service (1000 requests/month)
      final response = await http.get(
        Uri.parse('https://ipapi.co/json/'),
        headers: {'User-Agent': 'PocketSplit/1.0'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final countryCode = data['country_code']?.toString().toUpperCase();
        
        debugPrint('CurrencyLocationService: IP geolocation result - Country: $countryCode');
        debugPrint('CurrencyLocationService: IP geolocation full response: ${data['country']}, ${data['region']}, ${data['city']}');
        
        return countryCode;
      } else {
        debugPrint('CurrencyLocationService: IP geolocation API error - Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('CurrencyLocationService: IP geolocation error: $e');
      return null;
    }
  }

  /// Manual override for testing or specific regions
  static void setCurrencyOverride(String currencyCode) {
    debugPrint('CurrencyLocationService: Setting currency override to: $currencyCode');
    _cachedCurrency = currencyCode;
  }
  
  /// Force detection refresh (clears cache and re-detects)
  static Future<String> forceDetection() async {
    debugPrint('CurrencyLocationService: Forcing currency re-detection...');
    clearCache();
    return await detectCurrencyFromLocation();
  }

  /// Clear cached currency (useful for testing)
  static void clearCache() {
    _cachedCurrency = null;
  }

  /// Get the currently detected/cached currency
  static String? getDetectedCurrency() {
    return _cachedCurrency;
  }

  /// Get currency suggestions based on common patterns
  static List<String> getCurrencySuggestions() {
    final detected = _cachedCurrency;
    final suggestions = <String>[];

    if (detected != null) {
      suggestions.add(detected);
    }

    // Add commonly used currencies
    const commonCurrencies = ['USD', 'EUR', 'GBP', 'INR', 'CAD', 'AUD'];
    for (final currency in commonCurrencies) {
      if (!suggestions.contains(currency)) {
        suggestions.add(currency);
      }
    }

    return suggestions;
  }

  /// Get enhanced currency suggestions with intl formatting
  static List<CurrencyInfo> getEnhancedCurrencySuggestions() {
    return CurrencyUtils.getCurrencySuggestions();
  }

  /// Get formatted currency display with location context
  static String getFormattedCurrencyWithLocation(String currencyCode) {
    final currency = CurrencyConstants.getCurrencyByCode(currencyCode);
    if (currency == null) {
      return currencyCode;
    }

    if (_cachedCurrency == currencyCode) {
      return '${currency.symbol} ${currency.code} (Detected)';
    }

    return '${currency.symbol} ${currency.code} - ${currency.country}';
  }

  /// Get currency symbol using intl package
  static String getCurrencySymbol([String? currencyCode]) {
    if (currencyCode != null) {
      // Try to get symbol for specific currency using intl
      try {
        return CurrencyUtils.getCurrencySymbol();
      } catch (e) {
        // Fallback to our constants
        final currency = CurrencyConstants.getCurrencyByCode(currencyCode);
        return currency?.symbol ?? currencyCode;
      }
    }
    
    // Get symbol for detected currency
    return CurrencyUtils.getCurrencySymbol();
  }

  /// Format amount with proper currency formatting
  static String formatCurrency(double amount, [String? currencyCode]) {
    return CurrencyUtils.formatCurrency(amount, null, currencyCode);
  }

  /// Format compact currency (e.g., $1.2K)
  static String formatCompactCurrency(double amount, [String? currencyCode]) {
    return CurrencyUtils.formatCompactCurrency(amount, null, currencyCode);
  }

  /// Get detailed currency information
  static CurrencyInfo getCurrencyInfo([String? currencyCode]) {
    if (currencyCode != null) {
      final currency = CurrencyConstants.getCurrencyByCode(currencyCode);
      if (currency != null) {
        // Get locale-specific symbol if possible
        String symbol;
        try {
          symbol = CurrencyUtils.getCurrencySymbol();
        } catch (e) {
          symbol = currency.symbol;
        }
        
        return CurrencyInfo(
          code: currency.code,
          symbol: symbol,
          name: currency.name,
          country: currency.country,
          locale: Platform.localeName,
        );
      }
    }
    
    // Return detected currency info
    return CurrencyUtils.getCurrencyInfoFromLocale();
  }
}