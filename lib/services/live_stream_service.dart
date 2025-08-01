import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_service.dart';

class LiveStreamService extends ChangeNotifier {
  RtcEngine? _engine;
  bool _isStreaming = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  int _viewerCount = 0;
  List<int> _remoteUsers = [];

  // Agora App ID - Replace with your actual App ID
  static const String appId = 'your_agora_app_id_here';

  bool get isStreaming => _isStreaming;
  bool get isMuted => _isMuted;
  bool get isVideoEnabled => _isVideoEnabled;
  int get viewerCount => _viewerCount;
  List<int> get remoteUsers => _remoteUsers;

  Future<void> initializeAgora() async {
    // Request permissions
    await [Permission.microphone, Permission.camera].request();

    // Create RTC engine
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    // Set up event handlers
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint('Local user joined channel: ${connection.channelId}');
          _isStreaming = true;
          notifyListeners();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint('Remote user joined: $remoteUid');
          _remoteUsers.add(remoteUid);
          _viewerCount++;
          notifyListeners();
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint('Remote user left: $remoteUid');
          _remoteUsers.remove(remoteUid);
          _viewerCount--;
          notifyListeners();
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          debugPrint('Left channel');
          _isStreaming = false;
          _remoteUsers.clear();
          _viewerCount = 0;
          notifyListeners();
        },
      ),
    );
  }

  Future<void> startLiveStream({
    required String channelName,
    required String dareId,
    required String performerId,
  }) async {
    if (_engine == null) {
      await initializeAgora();
    }

    // Enable video
    await _engine!.enableVideo();
    await _engine!.enableAudio();

    // Set client role as broadcaster
    await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    // Join channel
    await _engine!.joinChannel(
      token: null, // Use token for production
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );

    // Record live stream in Firebase
    await FirebaseService.createLiveStream({
      'channelName': channelName,
      'dareId': dareId,
      'performerId': performerId,
      'isActive': true,
      'viewerCount': 0,
      'startTime': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> joinAsViewer(String channelName) async {
    if (_engine == null) {
      await initializeAgora();
    }

    // Set client role as audience
    await _engine!.setClientRole(role: ClientRoleType.clientRoleAudience);

    // Join channel
    await _engine!.joinChannel(
      token: null,
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> toggleMute() async {
    if (_engine != null) {
      _isMuted = !_isMuted;
      await _engine!.muteLocalAudioStream(_isMuted);
      notifyListeners();
    }
  }

  Future<void> toggleVideo() async {
    if (_engine != null) {
      _isVideoEnabled = !_isVideoEnabled;
      await _engine!.muteLocalVideoStream(!_isVideoEnabled);
      notifyListeners();
    }
  }

  Future<void> switchCamera() async {
    if (_engine != null) {
      await _engine!.switchCamera();
    }
  }

  Future<void> endLiveStream() async {
    if (_engine != null) {
      await _engine!.leaveChannel();
      await _engine!.release();
      _engine = null;
    }
    
    _isStreaming = false;
    _remoteUsers.clear();
    _viewerCount = 0;
    notifyListeners();
  }

  Widget createLocalVideoView() {
    if (_engine == null) return Container();
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine!,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  Widget createRemoteVideoView(int uid) {
    if (_engine == null) return Container();
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine!,
        canvas: VideoCanvas(uid: uid),
        connection: const RtcConnection(channelId: ''),
      ),
    );
  }

  @override
  void dispose() {
    endLiveStream();
    super.dispose();
  }
}