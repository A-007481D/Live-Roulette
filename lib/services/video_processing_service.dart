import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:share_plus/share_plus.dart';
import 'firebase_service.dart';

class VideoProcessingService extends ChangeNotifier {
  bool _isProcessing = false;
  double _progress = 0.0;

  bool get isProcessing => _isProcessing;
  double get progress => _progress;

  Future<String?> createViralClip({
    required String inputVideoPath,
    required String dareTitle,
    required bool wasSuccessful,
    required String performerName,
  }) async {
    try {
      _isProcessing = true;
      _progress = 0.0;
      notifyListeners();

      final outputPath = '${Directory.systemTemp.path}/viral_clip_${DateTime.now().millisecondsSinceEpoch}.mp4';
      
      // Create viral clip with FFmpeg
      final command = _buildFFmpegCommand(
        inputPath: inputVideoPath,
        outputPath: outputPath,
        title: dareTitle,
        performerName: performerName,
        wasSuccessful: wasSuccessful,
      );

      _progress = 0.3;
      notifyListeners();

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        _progress = 0.7;
        notifyListeners();

        // Upload to Firebase Storage
        final file = File(outputPath);
        final bytes = await file.readAsBytes();
        final downloadUrl = await FirebaseService.uploadFile(
          'viral_clips/${DateTime.now().millisecondsSinceEpoch}.mp4',
          bytes,
        );

        _progress = 0.9;
        notifyListeners();

        // Save clip metadata to Firestore
        await FirebaseService.saveViralClip({
          'title': dareTitle,
          'performerName': performerName,
          'wasSuccessful': wasSuccessful,
          'videoUrl': downloadUrl,
          'views': 0,
          'shares': 0,
          'likes': 0,
          'duration': await _getVideoDuration(outputPath),
        });

        _progress = 1.0;
        notifyListeners();

        return downloadUrl;
      } else {
        throw Exception('FFmpeg processing failed');
      }
    } catch (e) {
      debugPrint('Error creating viral clip: $e');
      return null;
    } finally {
      _isProcessing = false;
      _progress = 0.0;
      notifyListeners();
    }
  }

  String _buildFFmpegCommand({
    required String inputPath,
    required String outputPath,
    required String title,
    required String performerName,
    required bool wasSuccessful,
  }) {
    final statusText = wasSuccessful ? 'COMPLETED' : 'FAILED';
    final statusColor = wasSuccessful ? 'green' : 'red';
    
    return '''
      -i "$inputPath"
      -vf "
        scale=1080:1920:force_original_aspect_ratio=increase,
        crop=1080:1920,
        drawtext=text='$title':fontcolor=white:fontsize=60:x=(w-text_w)/2:y=100:fontfile=/system/fonts/Roboto-Bold.ttf,
        drawtext=text='@$performerName':fontcolor=white:fontsize=40:x=(w-text_w)/2:y=200:fontfile=/system/fonts/Roboto-Regular.ttf,
        drawtext=text='$statusText':fontcolor=$statusColor:fontsize=80:x=(w-text_w)/2:y=h-200:fontfile=/system/fonts/Roboto-Bold.ttf,
        drawtext=text='Could you survive? Download Chaos Dare':fontcolor=white:fontsize=30:x=(w-text_w)/2:y=h-100:fontfile=/system/fonts/Roboto-Regular.ttf
      "
      -c:v libx264
      -preset fast
      -crf 23
      -c:a aac
      -b:a 128k
      -t 60
      "$outputPath"
    '''.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Future<int> _getVideoDuration(String videoPath) async {
    try {
      final session = await FFmpegKit.execute('-i "$videoPath" -f null -');
      final output = await session.getOutput();
      
      // Parse duration from FFmpeg output
      final durationRegex = RegExp(r'Duration: (\d{2}):(\d{2}):(\d{2})');
      final match = durationRegex.firstMatch(output ?? '');
      
      if (match != null) {
        final hours = int.parse(match.group(1)!);
        final minutes = int.parse(match.group(2)!);
        final seconds = int.parse(match.group(3)!);
        return hours * 3600 + minutes * 60 + seconds;
      }
    } catch (e) {
      debugPrint('Error getting video duration: $e');
    }
    return 0;
  }

  Future<void> shareViralClip(String videoPath, String title) async {
    try {
      await Share.shareXFiles(
        [XFile(videoPath)],
        text: '$title - Could you survive? Download Chaos Dare!',
      );
    } catch (e) {
      debugPrint('Error sharing viral clip: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTrendingClips() async {
    return await FirebaseService.getTrendingClips();
  }
}