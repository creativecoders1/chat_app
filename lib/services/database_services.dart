import 'package:chat_app/models/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  final CollectionReference<UserProfile> _usersCollection;

  DatabaseService()
      : _usersCollection = FirebaseFirestore.instance
            .collection('users')
            .withConverter<UserProfile>(
              fromFirestore: (snapshots, _) =>
                  UserProfile.fromJson(snapshots.data()!),
              toFirestore: (userProfile, _) => userProfile.toJson(),
            );

  Future<void> createUserProfile({required UserProfile userProfile}) async {
    try {
      await _usersCollection.doc(userProfile.uid).set(userProfile);
    } catch (e) {
      print('Error creating user profile: $e');
      // Optionally, rethrow or handle error
    }
  }
}
