import 'package:hive/hive.dart';
import 'package:video_call_app/data/hive/hive_keys.dart';

class HiveHelper {
  HiveHelper._();

  static Future<void> saveAccessToken({required String accessToken}) async {
    try {
      final token = Hive.box(HiveBoxNames.userBox);
      await token.put(HiveKeys.accessToken, accessToken);
    } catch (e) {
      rethrow;
    }
  }

  static Future<String?> getAuthToken() async {
    try {
      final token = Hive.box(HiveBoxNames.userBox);
      return await token.get(HiveKeys.accessToken);
    } catch (e) {
      rethrow;
    }
  }
}
