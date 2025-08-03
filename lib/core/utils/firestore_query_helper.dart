import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreQueryHelper {
  /// Helper method to handle queries that might require indexes
  /// Falls back to simpler queries if compound queries fail
  static Future<QuerySnapshot> safeQuery({
    required CollectionReference collection,
    String? whereField,
    dynamic whereValue,
    String? arrayContainsField,
    dynamic arrayContainsValue,
    String? orderByField,
    bool descending = false,
    int? limit,
  }) async {
    try {
      // Try the full query first
      Query query = collection;
      
      if (whereField != null && whereValue != null) {
        query = query.where(whereField, isEqualTo: whereValue);
      }
      
      if (arrayContainsField != null && arrayContainsValue != null) {
        query = query.where(arrayContainsField, arrayContains: arrayContainsValue);
      }
      
      if (orderByField != null) {
        query = query.orderBy(orderByField, descending: descending);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      return await query.get();
    } catch (e) {
      // If the query fails (likely due to missing index), try a simpler version
      if (e.toString().contains('requires an index') || 
          e.toString().contains('failed-precondition')) {
        return await _fallbackQuery(
          collection: collection,
          whereField: whereField,
          whereValue: whereValue,
          arrayContainsField: arrayContainsField,
          arrayContainsValue: arrayContainsValue,
          limit: limit,
        );
      }
      rethrow;
    }
  }
  
  static Future<QuerySnapshot> _fallbackQuery({
    required CollectionReference collection,
    String? whereField,
    dynamic whereValue,
    String? arrayContainsField,
    dynamic arrayContainsValue,
    int? limit,
  }) async {
    // Try with only one condition at a time
    Query query = collection;
    
    // Prioritize arrayContains over where for user-specific queries
    if (arrayContainsField != null && arrayContainsValue != null) {
      query = query.where(arrayContainsField, arrayContains: arrayContainsValue);
    } else if (whereField != null && whereValue != null) {
      query = query.where(whereField, isEqualTo: whereValue);
    }
    
    if (limit != null) {
      query = query.limit(limit);
    }
    
    return await query.get();
  }
  
  /// Helper for real-time queries with similar fallback strategy
  static Stream<QuerySnapshot> safeSnapshotQuery({
    required CollectionReference collection,
    String? whereField,
    dynamic whereValue,
    String? arrayContainsField,
    dynamic arrayContainsValue,
    String? orderByField,
    bool descending = false,
    int? limit,
  }) {
    try {
      Query query = collection;
      
      if (whereField != null && whereValue != null) {
        query = query.where(whereField, isEqualTo: whereValue);
      }
      
      if (arrayContainsField != null && arrayContainsValue != null) {
        query = query.where(arrayContainsField, arrayContains: arrayContainsValue);
      }
      
      if (orderByField != null) {
        query = query.orderBy(orderByField, descending: descending);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      return query.snapshots();
    } catch (e) {
      // Fallback to simpler stream query
      Query query = collection;
      
      if (arrayContainsField != null && arrayContainsValue != null) {
        query = query.where(arrayContainsField, arrayContains: arrayContainsValue);
      } else if (whereField != null && whereValue != null) {
        query = query.where(whereField, isEqualTo: whereValue);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      return query.snapshots();
    }
  }
}