import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

import '../../../core/services/agora_config.dart';
import '../../../core/services/permissions.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late final RtcEngine _engine;
  int? _remoteUid;
  bool _localUserJoined = false;
  bool _muted = false;
  bool _videoOff = false;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    await AppPermissions.requestVideoCallPermissions();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(appId: AgoraConfig.appId));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          debugPrint("Local user joined channel");
          setState(() => _localUserJoined = true);
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          debugPrint("Remote user joined: $remoteUid");
          setState(() => _remoteUid = remoteUid);
        },
        onUserOffline: (connection, remoteUid, reason) {
          debugPrint("Remote user left: $remoteUid");
          setState(() => _remoteUid = null);
        },
        onError: (err, msg) {
          debugPrint('Agora onError: $err - $msg');
        },
      ),
    );

    await _engine.enableVideo();
    await _engine.enableAudio();
    await _engine.setDefaultAudioRouteToSpeakerphone(true);
    await _engine.startPreview();

    await _engine.joinChannel(
      token: AgoraConfig.token,
      channelId: AgoraConfig.channelName,
      uid: 0,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: AgoraConfig.channelName),
        ),
      );
    } else {
      return const Center(
        child: Text(
          'Waiting for remote user to join...',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }

  Widget _localPreview() {
    if (_localUserJoined) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
  }

  void _toggleMute() {
    setState(() => _muted = !_muted);
    _engine.muteLocalAudioStream(_muted);
  }

  void _toggleVideo() {
    setState(() => _videoOff = !_videoOff);
    _engine.muteLocalVideoStream(_videoOff);
  }

  @override
  Widget build(BuildContext context) {
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _localPreview(),
            ),
          ),
          _bottomBar(),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _controlButton(Icons.mic, _toggleMute, active: _muted),
            const SizedBox(width: 20),
            _controlButton(Icons.videocam, _toggleVideo, active: _videoOff),
            const SizedBox(width: 20),
            _controlButton(
              Icons.call_end,
              () => Navigator.pop(context),
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
    return CircleAvatar(
      radius: 28,
      backgroundColor: active ? Colors.grey.shade800 : Colors.grey.shade700,
      child: IconButton(
        icon: Icon(icon, color: active ? Colors.grey : color, size: 28),
        onPressed: onTap,
      ),
    );
  }
}
