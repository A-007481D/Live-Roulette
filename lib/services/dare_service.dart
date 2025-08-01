import 'package:flutter/material.dart';
import '../models/dare_model.dart';
import 'firebase_service.dart';

class DareService extends ChangeNotifier {
  List<Dare> _liveDares = [];
  List<Dare> _pendingDares = [];
  bool _isLoading = false;

  List<Dare> get liveDares => _liveDares;
  List<Dare> get pendingDares => _pendingDares;
  bool get isLoading => _isLoading;

  DareService() {
    _initializeStreams();
  }

  void _initializeStreams() {
    // Listen to live dares
    FirebaseService.getLiveDares().listen((dares) {
      _liveDares = dares;
      notifyListeners();
    });

    // Listen to pending dares
    FirebaseService.getPendingDares().listen((dares) {
      _pendingDares = dares;
      notifyListeners();
    });
  }

  Future<String?> submitDare({
    required String title,
    required String description,
    required DareType type,
    required DareDifficulty difficulty,
    required String submitterId,
    List<String> tags = const [],
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final submissionFee = _getSubmissionFee(difficulty);
      
      final dare = Dare(
        id: '',
        title: title,
        description: description,
        type: type,
        difficulty: difficulty,
        submissionFee: submissionFee,
        submitterId: submitterId,
        createdAt: DateTime.now(),
        tags: tags,
      );

      await FirebaseService.createDare(dare);
      return null;
    } catch (e) {
      return 'Failed to submit dare: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> voteForDare(String dareId) async {
    await FirebaseService.voteForDare(dareId);
  }

  Future<void> tipDare(String dareId, double amount) async {
    await FirebaseService.addTipToDare(dareId, amount);
  }

  Future<void> acceptDare(String dareId, String performerId) async {
    await FirebaseService.updateDare(dareId, {
      'performerId': performerId,
      'status': DareStatus.live.index,
    });
  }

  Future<void> completeDare(String dareId, bool success) async {
    await FirebaseService.updateDare(dareId, {
      'status': success ? DareStatus.completed.index : DareStatus.failed.index,
    });
  }

  double _getSubmissionFee(DareDifficulty difficulty) {
    switch (difficulty) {
      case DareDifficulty.easy:
        return 1.0;
      case DareDifficulty.medium:
        return 2.5;
      case DareDifficulty.hard:
        return 5.0;
      case DareDifficulty.extreme:
        return 10.0;
      case DareDifficulty.insane:
        return 25.0;
    }
  }

  String getDifficultyLabel(DareDifficulty difficulty) {
    switch (difficulty) {
      case DareDifficulty.easy:
        return 'EASY';
      case DareDifficulty.medium:
        return 'MEDIUM';
      case DareDifficulty.hard:
        return 'HARD';
      case DareDifficulty.extreme:
        return 'EXTREME';
      case DareDifficulty.insane:
        return 'INSANE';
    }
  }

  Color getDifficultyColor(DareDifficulty difficulty) {
    switch (difficulty) {
      case DareDifficulty.easy:
        return Colors.green;
      case DareDifficulty.medium:
        return Colors.orange;
      case DareDifficulty.hard:
        return Colors.red;
      case DareDifficulty.extreme:
        return Colors.purple;
      case DareDifficulty.insane:
        return Colors.pink;
    }
  }
}