import 'app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> getCurrentUser();
  Future<AppUser> signInDebug();
  Future<void> signInWith(AuthProvider provider);
  Future<void> clearUser();
}

enum AuthProvider { google, microsoft, apple }

class AuthProviderNotConfiguredException implements Exception {
  const AuthProviderNotConfiguredException(this.provider);

  final AuthProvider provider;

  @override
  String toString() => '${provider.name} authentication is not configured yet.';
}
