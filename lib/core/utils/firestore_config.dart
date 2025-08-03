import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreConfig {
  static void configurePersistence() {
    // Enable offline persistence
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  }
  
  /// Configure Firestore for development with useful settings
  static void configureForDevelopment() {
    configurePersistence();
    
    // Enable network first for development
    FirebaseFirestore.instance.enableNetwork();
  }
  
  /// Best practices for Firestore queries to avoid index requirements
  static const List<String> queryBestPractices = [
    '1. Use simple queries with single field filters when possible',
    '2. Avoid combining arrayContains with orderBy - sort in memory instead',
    '3. Limit compound queries and create necessary indexes manually',
    '4. Use inequality filters on the same field you order by',
    '5. Consider denormalization for complex queries',
  ];
  
  /// Common Firestore error patterns and solutions
  static String getErrorSolution(String error) {
    if (error.contains('requires an index')) {
      return 'This query requires a compound index. We\'re using a fallback strategy to sort in memory instead.';
    } else if (error.contains('failed-precondition')) {
      return 'Query failed due to index requirements. Using simplified query with in-memory sorting.';
    } else if (error.contains('permission-denied')) {
      return 'Permission denied. Check Firestore security rules.';
    } else if (error.contains('unavailable')) {
      return 'Firestore service is temporarily unavailable. Please try again.';
    }
    return 'Unknown Firestore error. Check connection and try again.';
  }
}