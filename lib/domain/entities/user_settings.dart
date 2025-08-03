import 'package:equatable/equatable.dart';

class UserSettings extends Equatable {
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

  const UserSettings({
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

  UserSettings copyWith({
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
    return UserSettings(
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