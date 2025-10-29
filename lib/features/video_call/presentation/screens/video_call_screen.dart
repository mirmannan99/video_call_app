import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/agora_config.dart';
import '../../logic/provider/video_call_provider.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  const VideoCallScreen({super.key});

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  late final VideoCallProvider _vc;
  VoidCallback? _vcListener;
  @override
  void initState() {
    super.initState();

    Future.microtask(() => ref.read(videoCallProvider).init());
    // Cache provider instance and initialize without using ref in dispose-time
    _vc = ref.read(videoCallProvider);
    Future.microtask(() => _vc.init());

    // Listen for remote-end signal and close the screen safely
    _vcListener = () async {
      if (!mounted) return;
      if (_vc.remoteEndRequested) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Call ended by the other user')),
        );
        await _vc.disposeEngine();
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      }
    };
    _vc.addListener(_vcListener!);
  }

  @override
  void dispose() {
    if (_vcListener != null) {
      _vc.removeListener(_vcListener!);
    }
    // Avoid using ref in dispose; use cached provider instance
    _vc.disposeEngine();
    super.dispose();
  }

  Widget _remoteVideo() {
    final p = ref.watch(videoCallProvider);
    if (p.engine != null && p.remoteUid != null && p.remoteVideoOn) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: p.engine!,
          canvas: VideoCanvas(uid: p.remoteUid),
          connection: RtcConnection(channelId: AgoraConfig.channelName),
        ),
      );
    }
    if (p.remoteUid != null && !p.remoteVideoOn) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: const Icon(Icons.videocam_off, color: Colors.white70, size: 56),
      );
    }
    return const Center(
      child: Text(
        'Waiting for remote user to join...',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _localPreview() {
    final p = ref.watch(videoCallProvider);
    if (p.engine != null && p.localUserJoined && !p.videoOff) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: p.engine!,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    } else {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: const Icon(Icons.videocam_off, color: Colors.white70, size: 42),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(videoCallProvider);
    if (p.remoteEndRequested) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Call ended by the other user',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            backgroundColor: Colors.redAccent,
          ),
        );
        await _vc.disposeEngine();
        if (!context.mounted) return;
        if (Navigator.canPop(context)) Navigator.of(context).pop();
      });
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(child: _remoteVideo()),
          Positioned(
            top: 40,
            right: 10,
            width: 120,
            height: 160,
            child: _localPreview(),
          ),
          bottomBar(p),
        ],
      ),
    );
  }

  Widget bottomBar(VideoCallProvider p) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 15),
        child: Row(
          children: [
            _controlButton(Icons.mic, p.toggleMute, active: p.muted),
            const SizedBox(width: 20),
            _controlButton(Icons.videocam, p.toggleVideo, active: p.videoOff),
            const SizedBox(width: 20),
            _controlButton(
              p.isSharing ? Icons.stop_screen_share : Icons.screen_share,
              () => p.toggleScreenShare(context),
              active: p.isSharing,
            ),
            const SizedBox(width: 20),
            _controlButton(Icons.cameraswitch, p.switchCamera),
            const SizedBox(width: 20),
            _controlButton(
              p.speakerOn ? Icons.volume_up : Icons.volume_off,
              p.toggleSpeaker,
              active: !p.speakerOn,
            ),
            const SizedBox(width: 20),
            _controlButton(
              Icons.call_end,
              () => _vc.endCall(context),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlButton(
    IconData icon,
    VoidCallback onTap, {
    bool active = false,
    Color color = Colors.white,
  }) {
    return Expanded(
      child: CircleAvatar(
        radius: 28,
        backgroundColor: active ? Colors.grey.shade800 : Colors.grey.shade700,
        child: IconButton(
          icon: Icon(icon, color: active ? Colors.grey : color, size: 28),
          onPressed: onTap,
        ),
      ),
    );
  }
}
