import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_call_app/features/video_call/logic/provider/video_call_provider.dart';
import 'package:video_call_app/features/video_call/presentation/screens/video_call_screen.dart';

class IncomingCallScreen extends ConsumerWidget {
  final String callerName;
  final String roomId;
  const IncomingCallScreen({
    super.key,
    required this.callerName,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.videocam, color: Colors.white, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Incoming video call',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  callerName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _circleButton(
                      color: Colors.red,
                      icon: Icons.call_end,
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    _circleButton(
                      color: Colors.green,
                      icon: Icons.call,
                      onTap: () async {
                        // Prepare the engine if not already
                        await ref.read(videoCallProvider).init();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const VideoCallScreen(),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleButton({
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return CircleAvatar(
      radius: 32,
      backgroundColor: color,
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }
}
