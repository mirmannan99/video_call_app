import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/services/agora_config.dart';
import '../../../../core/services/permissions_service.dart';

final videoCallProvider = ChangeNotifierProvider<VideoCallProvider>(
  (ref) => VideoCallProvider(),
);

class VideoCallProvider extends ChangeNotifier {
  RtcEngine? _engine;

  int? _remoteUid;
  bool _localUserJoined = false;
  bool _muted = false;
  bool _videoOff = false;
  bool _usingFrontCamera = true;
  bool _speakerOn = true;
  bool _remoteVideoOn = false;
  bool _isSharing = false;
  int? _dataStreamId;
  bool _remoteEndRequested = false;

  // Getters for UI
  RtcEngine? get engine => _engine;
  int? get remoteUid => _remoteUid;
  bool get localUserJoined => _localUserJoined;
  bool get muted => _muted;
  bool get videoOff => _videoOff;
  bool get usingFrontCamera => _usingFrontCamera;
  bool get speakerOn => _speakerOn;
  bool get remoteVideoOn => _remoteVideoOn;
  bool get isSharing => _isSharing;
  bool get remoteEndRequested => _remoteEndRequested;

  Future<void> init() async {
    if (_engine != null) return;
    await AppPermissions.requestVideoCallPermissions();

    final engine = createAgoraRtcEngine();
    await engine.initialize(const RtcEngineContext(appId: AgoraConfig.appId));

    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) async {
          debugPrint("Local user joined channel");
          _localUserJoined = true;
          // Create a reliable, ordered data stream for simple signaling (end call, etc.)
          try {
            _dataStreamId = await engine.createDataStream(
              const DataStreamConfig(ordered: true, syncWithAudio: false),
            );
          } catch (e) {
            debugPrint('createDataStream failed: $e');
          }
          notifyListeners();
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          debugPrint("Remote user joined: $remoteUid");
          _remoteUid = remoteUid;
          notifyListeners();
        },
        onUserOffline: (connection, remoteUid, reason) {
          debugPrint("Remote user left: $remoteUid");
          _remoteUid = null;
          _remoteVideoOn = false;
          notifyListeners();
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
                _remoteVideoOn = isOn;
                notifyListeners();
              }
            },
        onStreamMessage:
            (connection, remoteUid, streamId, data, length, sentTs) {
              try {
                final message = utf8.decode(data);
                if (message == 'END_CALL') {
                  _remoteEndRequested = true;
                  notifyListeners();
                }
              } catch (e) {
                debugPrint('onStreamMessage decode error: $e');
              }
            },
      ),
    );

    await engine.enableVideo();
    await engine.enableLocalVideo(true);
    await engine.enableAudio();
    await engine.enableLocalAudio(true);
    await engine.setDefaultAudioRouteToSpeakerphone(true);
    await engine.setAudioProfile(
      profile: AudioProfileType.audioProfileDefault,
      scenario: AudioScenarioType.audioScenarioDefault,
    );
    await engine.startPreview();

    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await engine.joinChannel(
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

    await engine.adjustPlaybackSignalVolume(100);
    await engine.adjustRecordingSignalVolume(100);

    _engine = engine;
    notifyListeners();
  }

  Future<void> disposeEngine() async {
    try {
      await _engine?.leaveChannel();
    } catch (_) {}
    try {
      await _engine?.release();
    } catch (_) {}
    _engine = null;
    _remoteUid = null;
    _localUserJoined = false;
    _muted = false;
    _videoOff = false;
    _usingFrontCamera = true;
    _speakerOn = true;
    _remoteVideoOn = false;
    _isSharing = false;
    _dataStreamId = null;
    _remoteEndRequested = false;
    notifyListeners();
  }

  void toggleMute() {
    _muted = !_muted;
    _engine?.muteLocalAudioStream(_muted);
    notifyListeners();
  }

  void toggleVideo() {
    _videoOff = !_videoOff;
    _engine?.enableLocalVideo(!_videoOff);
    _engine?.muteLocalVideoStream(_videoOff);
    notifyListeners();
  }

  Future<void> switchCamera() async {
    await _engine?.switchCamera();
    _usingFrontCamera = !_usingFrontCamera;
    notifyListeners();
  }

  void toggleSpeaker() {
    _speakerOn = !_speakerOn;
    _engine?.setDefaultAudioRouteToSpeakerphone(_speakerOn);
    notifyListeners();
  }

  Future<void> toggleScreenShare(BuildContext context) async {
    if (!_isSharing) {
      try {
        final params = ScreenCaptureParameters2(
          captureAudio: true,
          audioParams: ScreenAudioParameters(
            sampleRate: 48000,
            channels: 2,
            captureSignalVolume: 100,
          ),
          captureVideo: true,
          videoParams: ScreenVideoParameters(
            dimensions: const VideoDimensions(width: 1280, height: 720),
            frameRate: 15,
            bitrate: 1200,
            contentHint: VideoContentHint.contentHintMotion,
          ),
        );

        await _engine?.startScreenCapture(params);
        await _engine?.updateChannelMediaOptions(
          const ChannelMediaOptions(
            publishScreenCaptureVideo: true,
            publishScreenCaptureAudio: true,
            publishCameraTrack: false,
          ),
        );
        _isSharing = true;
        notifyListeners();
      } catch (e) {
        final msg =
            'Screen share failed: $e'
            '${Platform.isIOS ? " — ensure ReplayKit Broadcast Extension is set up" : ""}';
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } else {
      try {
        await _engine?.stopScreenCapture();
        await _engine?.updateChannelMediaOptions(
          ChannelMediaOptions(
            publishScreenCaptureVideo: false,
            publishScreenCaptureAudio: false,
            publishCameraTrack: !_videoOff,
          ),
        );
      } catch (_) {}
      _isSharing = false;
      notifyListeners();
    }
  }

  Future<void> endCall(BuildContext context) async {
    try {
      if (_dataStreamId != null) {
        final bytes = Uint8List.fromList(utf8.encode('END_CALL'));
        await _engine?.sendStreamMessage(
          streamId: _dataStreamId!,
          data: bytes,
          length: bytes.length,
        );
      }
    } catch (e) {
      debugPrint('sendStreamMessage failed: $e');
    }

    await disposeEngine();
    if (Navigator.canPop(context)) {
      // Pop back to previous screen
      Navigator.of(context).pop();
    }
  }
}
