import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserSettingsModel extends Equatable {
  final String userId;
  final String baseCurrency;
  final String displayName;
  final String email;
  final String? photoUrl;
  final bool notificationsEnabled;
  final String theme; // 'light', 'dark', 'system'
  final String language;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserSettingsModel({
    required this.userId,
    required this.baseCurrency,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.notificationsEnabled = true,
    this.theme = 'system',
    this.language = 'en',
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserSettingsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserSettingsModel(
      userId: doc.id,
      baseCurrency: data['baseCurrency'] ?? 'USD',
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      theme: data['theme'] ?? 'system',
      language: data['language'] ?? 'en',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'baseCurrency': baseCurrency,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'notificationsEnabled': notificationsEnabled,
      'theme': theme,
      'language': language,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserSettingsModel copyWith({
    String? userId,
    String? baseCurrency,
    String? displayName,
    String? email,
    String? photoUrl,
    bool? notificationsEnabled,
    String? theme,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettingsModel(
      userId: userId ?? this.userId,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        userId,
        baseCurrency,
        displayName,
        email,
        photoUrl,
        notificationsEnabled,
        theme,
        language,
        createdAt,
        updatedAt,
      ];
}