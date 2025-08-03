import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/user_settings_repository.dart';
import '../models/user_settings_model.dart';

class FirebaseUserSettingsRepository implements UserSettingsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'user_settings';

  @override
  Future<UserSettings?> getUserSettings(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      
      if (!doc.exists) {
        return null;
      }

      return _mapUserSettingsModelToEntity(UserSettingsModel.fromFirestore(doc));
    } catch (e) {
      throw Exception('Failed to get user settings: $e');
    }
  }

  @override
  Future<void> createUserSettings(UserSettings userSettings) async {
    try {
      final userSettingsModel = UserSettingsModel(
        userId: userSettings.userId,
        baseCurrency: userSettings.baseCurrency,
        displayName: userSettings.displayName,
        email: userSettings.email,
        photoUrl: userSettings.photoUrl,
        notificationsEnabled: userSettings.notificationsEnabled,
        theme: userSettings.theme,
        language: userSettings.language,
        createdAt: userSettings.createdAt,
        updatedAt: userSettings.updatedAt,
      );

      await _firestore
          .collection(_collection)
          .doc(userSettings.userId)
          .set(userSettingsModel.toFirestore());
    } catch (e) {
      throw Exception('Failed to create user settings: $e');
    }
  }

  @override
  Future<void> updateUserSettings(UserSettings userSettings) async {
    try {
      final userSettingsModel = UserSettingsModel(
        userId: userSettings.userId,
        baseCurrency: userSettings.baseCurrency,
        displayName: userSettings.displayName,
        email: userSettings.email,
        photoUrl: userSettings.photoUrl,
        notificationsEnabled: userSettings.notificationsEnabled,
        theme: userSettings.theme,
        language: userSettings.language,
        createdAt: userSettings.createdAt,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(userSettings.userId)
          .update(userSettingsModel.toFirestore());
    } catch (e) {
      throw Exception('Failed to update user settings: $e');
    }
  }

  @override
  Future<void> updateBaseCurrency(String userId, String currencyCode) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(userId)
          .update({
            'baseCurrency': currencyCode,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });
    } catch (e) {
      throw Exception('Failed to update base currency: $e');
    }
  }

  @override
  Stream<UserSettings?> watchUserSettings(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            return null;
          }
          return _mapUserSettingsModelToEntity(UserSettingsModel.fromFirestore(doc));
        });
  }

  UserSettings _mapUserSettingsModelToEntity(UserSettingsModel model) {
    return UserSettings(
      userId: model.userId,
      baseCurrency: model.baseCurrency,
      displayName: model.displayName,
      email: model.email,
      photoUrl: model.photoUrl,
      notificationsEnabled: model.notificationsEnabled,
      theme: model.theme,
      language: model.language,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}