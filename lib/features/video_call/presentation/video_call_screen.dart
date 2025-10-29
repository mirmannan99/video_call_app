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
  bool _usingFrontCamera = true;
  bool _speakerOn = true;
  bool _remoteVideoOn = false;

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
          setState(() {
            _remoteUid = null;
            _remoteVideoOn = false;
          });
        },
        onError: (err, msg) {
          debugPrint('Agora onError: $err - $msg');
        },
        onConnectionStateChanged: (connection, state, reason) {
          debugPrint('Connection state: $state, reason: $reason');
        },
        onRemoteAudioStateChanged: (connection, uid, state, reason, elapsed) {
          debugPrint('Remote audio state for $uid: $state, reason: $reason');
        },
        onRemoteVideoStateChanged:
            (connection, remoteUid, state, reason, elapsed) {
              debugPrint(
                'Remote video state for $remoteUid: $state, reason: $reason',
              );
              if (_remoteUid == remoteUid) {
                final bool isOn =
                    state == RemoteVideoState.remoteVideoStateDecoding ||
                    state == RemoteVideoState.remoteVideoStateStarting;
                setState(() => _remoteVideoOn = isOn);
              }
            },
      ),
    );

    await _engine.enableVideo();
    await _engine.enableLocalVideo(true);
    await _engine.enableAudio();
    await _engine.enableLocalAudio(true);
    await _engine.setDefaultAudioRouteToSpeakerphone(true);
    await _engine.setAudioProfile(
      profile: AudioProfileType.audioProfileDefault,
      scenario: AudioScenarioType.audioScenarioDefault,
    );
    await _engine.startPreview();

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
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

    await _engine.adjustPlaybackSignalVolume(100);
    await _engine.adjustRecordingSignalVolume(100);
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  Widget _remoteVideo() {
    if (_remoteUid != null && _remoteVideoOn) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: AgoraConfig.channelName),
        ),
      );
    }
    if (_remoteUid != null && !_remoteVideoOn) {
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
    if (_localUserJoined && !_videoOff) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine,
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

  void _toggleMute() {
    setState(() => _muted = !_muted);
    _engine.muteLocalAudioStream(_muted);
  }

  void _toggleVideo() {
    setState(() => _videoOff = !_videoOff);
    _engine.enableLocalVideo(!_videoOff);
    _engine.muteLocalVideoStream(_videoOff);
  }

  Future<void> _switchCamera() async {
    await _engine.switchCamera();
    setState(() => _usingFrontCamera = !_usingFrontCamera);
  }

  void _toggleSpeaker() {
    setState(() => _speakerOn = !_speakerOn);
    _engine.setDefaultAudioRouteToSpeakerphone(_speakerOn);
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
            _controlButton(Icons.cameraswitch, _switchCamera),
            const SizedBox(width: 20),
            _controlButton(
              _speakerOn ? Icons.volume_up : Icons.volume_off,
              _toggleSpeaker,
              active: !_speakerOn,
            ),
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
