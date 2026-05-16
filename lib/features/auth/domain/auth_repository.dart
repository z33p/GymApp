import 'app_user.dart';

abstract class AuthRepository {
  Future<AppUser> ensureMockUser();
  Future<AppUser?> getCurrentUser();
  Future<void> clearUser();
}
