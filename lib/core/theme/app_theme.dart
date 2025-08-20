import 'package:flutter/material.dart';

class AppTheme {
  // PocketSplit Color Palette
  static const Color primary1 = Color(0xFFD2FF72); // Trust, Clarity
  static const Color primary2 = Color(0xFF73EC8B); // Energy, Optimism
  static const Color secondary1 = Color(0xFF54C392); // Balance, Freshness
  static const Color secondary2 = Color(0xFF15B392); // Stability, Growth
  static const Color white = Color(0xFFFFFFFF); // Simplicity
  static const Color black = Color(0xFF000000); // Elegance
  static const Color lightGray = Color(0xFFF0F0F0); // Cleanliness
  static const Color darkGray = Color(0xFF2C3E50); // Sophistication
  static const Color neutralGray = Color(0xFF7F8C8D); // Professionalism

  
  // static const Color purpleDark1 = Color(0xFF433878); 
  static const Color purpleDark2 = Color(0xFF7E60BF); 
  static const Color purpleLight1 = Color(0xFFFFE100); 

  // static const Color purpleLight1 = Color(0xFFE4B1F0); 
  // static const Color purpleLight2 = Color(0xFFFFE1FF);
  static const Color purpleLight2 = Color(0xFFF6FB7A);

  
  // Light Pastel Vibrant Colors
  // Cotton Candy palette (soft pink-blue)
  static const Color cottonCandyDark1 = Color(0xFFFF9EC7);   // Vibrant cotton candy
  static const Color cottonCandyDark2 = Color(0xFFFFB3D1);   // Soft cotton candy
  static const Color cottonCandyLight1 = Color(0xFFFFCCE1);  // Light cotton candy
  static const Color cottonCandyLight2 = Color(0xFFFFF0F8);  // Pale cotton candy
  
  // Peach Sorbet palette (warm coral-orange)
  static const Color peachDark1 = Color(0xFFFF8A65);        // Vibrant peach
  static const Color peachDark2 = Color(0xFFFFA07A);        // Soft peach
  static const Color peachLight1 = Color(0xFFFFCC9A);       // Light peach
  static const Color peachLight2 = Color(0xFFFFF4E6);       // Pale peach
  
  // Mint Breeze palette (fresh green-blue)
  static const Color mintDark1 = Color(0xFF4ECDC4);         // Vibrant mint
  static const Color mintDark2 = Color(0xFF7FDBDA);         // Soft mint
  static const Color mintLight1 = Color(0xFFB2E8E6);        // Light mint
  static const Color mintLight2 = Color(0xFFE6F9F8);        // Pale mint
  
  // Lavender Dreams palette (soft purple)
  static const Color lavenderDark1 = Color(0xFFB39DDB);     // Vibrant lavender
  static const Color lavenderDark2 = Color(0xFFC5B5E8);     // Soft lavender
  static const Color lavenderLight1 = Color(0xFFD7CDF4);    // Light lavender
  static const Color lavenderLight2 = Color(0xFFF3F0FF);    // Pale lavender
  
  // Sunshine palette (bright yellow-orange)
  static const Color sunshineDark1 = Color(0xFFFFD54F);     // Vibrant sunshine
  static const Color sunshineDark2 = Color(0xFFFFE082);     // Soft sunshine
  static const Color sunshineLight1 = Color(0xFFFFF59D);    // Light sunshine
  static const Color sunshineLight2 = Color(0xFFFFFDE7);    // Pale sunshine
  
  // Ocean Blue palette (blue theme)
  static const Color oceanDark1 = Color(0xFF1E40AF);        // Deep ocean blue
  static const Color oceanDark2 = Color(0xFF3B82F6);        // Ocean blue
  static const Color oceanLight1 = Color(0xFF93C5FD);       // Light ocean
  static const Color oceanLight2 = Color(0xFFDDEAFE);       // Pale ocean 



  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: secondary2,
        primary: secondary2,
        secondary: secondary1,
        surface: white,
        onSurface: darkGray,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: darkGray),
        titleTextStyle: TextStyle(
          color: darkGray,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary2,
          foregroundColor: white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkGray,
          side: const BorderSide(color: neutralGray, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: darkGray,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: darkGray,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          color: darkGray,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: darkGray,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: darkGray,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: darkGray,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: neutralGray,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: neutralGray,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: neutralGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: neutralGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: black, width: 2),
        ),
        filled: true,
        fillColor: lightGray,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: black),
        floatingLabelStyle: const TextStyle(color: black),
        hintStyle: const TextStyle(color: neutralGray),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return secondary2;
          }
          return null;
        }),
        checkColor: WidgetStateProperty.all(white),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return secondary2;
          }
          return null;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return secondary2;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return secondary2.withValues(alpha: 0.5);
          }
          return null;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: secondary2,
        thumbColor: secondary2,
        overlayColor: secondary2.withValues(alpha: 0.2),
        inactiveTrackColor: neutralGray.withValues(alpha: 0.3),
      ),
    );
  }
}