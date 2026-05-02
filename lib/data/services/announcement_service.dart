import 'package:cloud_firestore/cloud_firestore.dart';
import './notification_service.dart';

class AnnouncementService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> publishAnnouncement({
    required String title,
    required String description,
    required String time,
    required String location,
    required DateTime dateTime,
    required List<String> invitedSections,
    required String targetType,
    required String authorName,
    required String authorRole,
  }) async {
    final docRef = _db.collection('Announcements').doc();
    
    final data = {
      'id': docRef.id,
      'title': title,
      'description': description,
      'time': time,
      'location': location,
      'dateTime': Timestamp.fromDate(dateTime),
      'invitedSections': invitedSections,
      'targetType': targetType,
      'authorName': authorName,
      'authorRole': authorRole,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(data);

    // Also broadcast via Socket.io for real-time alerts
    String room = invitedSections.contains('ALL') ? 'ALL' : (invitedSections.isNotEmpty ? invitedSections.first : 'ALL');
    NotificationService.simulateNotification(
      'New Announcement: $title',
      description,
      type: 'announcement',
      room: room,
    );
  }

  static Stream<List<Map<String, dynamic>>> streamAnnouncements(String section) {
    return _db
        .collection('Announcements')
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.where((doc) {
        final data = doc.data();
        final invited = List<String>.from(data['invitedSections'] ?? []);
        final target = data['targetType'] as String?;

        // Filter: ALL, or specific section, or for students generally
        if (target == 'Only Teachers') return false;
        
        return invited.contains('ALL') || invited.contains(section) || invited.isEmpty;
      }).map((doc) {
        final data = doc.data();
        // Convert Timestamp to DateTime for UI compatibility
        if (data['dateTime'] is Timestamp) {
          data['dateTime'] = (data['dateTime'] as Timestamp).toDate();
        }
        return data;
      }).toList();
    });
  }
}
