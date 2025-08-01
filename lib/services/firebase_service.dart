import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/dare_model.dart';
import '../models/user_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collections
  static const String usersCollection = 'users';
  static const String daresCollection = 'dares';
  static const String liveStreamsCollection = 'live_streams';
  static const String paymentsCollection = 'payments';
  static const String viralClipsCollection = 'viral_clips';

  // User Operations
  static Future<void> createUser(AppUser user) async {
    await _firestore.collection(usersCollection).doc(user.id).set(user.toMap());
  }

  static Future<AppUser?> getUser(String userId) async {
    final doc = await _firestore.collection(usersCollection).doc(userId).get();
    if (doc.exists) {
      return AppUser.fromMap(doc.data()!);
    }
    return null;
  }

  static Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore.collection(usersCollection).doc(userId).update(data);
  }

  // Dare Operations
  static Future<String> createDare(Dare dare) async {
    final docRef = await _firestore.collection(daresCollection).add(dare.toMap());
    return docRef.id;
  }

  static Stream<List<Dare>> getLiveDares() {
    return _firestore
        .collection(daresCollection)
        .where('status', isEqualTo: DareStatus.live.index)
        .orderBy('currentTips', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Dare.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  static Stream<List<Dare>> getPendingDares() {
    return _firestore
        .collection(daresCollection)
        .where('status', isEqualTo: DareStatus.pending.index)
        .orderBy('votes', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Dare.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  static Future<void> updateDare(String dareId, Map<String, dynamic> data) async {
    await _firestore.collection(daresCollection).doc(dareId).update(data);
  }

  static Future<void> addTipToDare(String dareId, double amount) async {
    await _firestore.collection(daresCollection).doc(dareId).update({
      'currentTips': FieldValue.increment(amount),
    });
  }

  static Future<void> voteForDare(String dareId) async {
    await _firestore.collection(daresCollection).doc(dareId).update({
      'votes': FieldValue.increment(1),
    });
  }

  // Live Stream Operations
  static Future<void> createLiveStream(Map<String, dynamic> streamData) async {
    await _firestore.collection(liveStreamsCollection).add(streamData);
  }

  static Stream<List<Map<String, dynamic>>> getActiveLiveStreams() {
    return _firestore
        .collection(liveStreamsCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('viewerCount', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
  }

  // Payment Operations
  static Future<void> recordPayment(Map<String, dynamic> paymentData) async {
    await _firestore.collection(paymentsCollection).add({
      ...paymentData,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Viral Clips Operations
  static Future<void> saveViralClip(Map<String, dynamic> clipData) async {
    await _firestore.collection(viralClipsCollection).add({
      ...clipData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<List<Map<String, dynamic>>> getTrendingClips() async {
    final snapshot = await _firestore
        .collection(viralClipsCollection)
        .orderBy('views', descending: true)
        .limit(20)
        .get();
    
    return snapshot.docs
        .map((doc) => {...doc.data(), 'id': doc.id})
        .toList();
  }

  // Storage Operations
  static Future<String> uploadFile(String path, List<int> fileBytes) async {
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putData(fileBytes as Uint8List);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}