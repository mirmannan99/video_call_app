import 'package:permission_handler/permission_handler.dart';

class AppPermissions {
  static Future<void> requestVideoCallPermissions() async {
    await [Permission.camera, Permission.microphone].request();
  }
}
