import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  StorageService();

  Future<String?> uploadUserPfp(
      {required File file, required String uid}) async {
    try {
      final fileRef = _firebaseStorage
          .ref("users/pfps")
          .child("$uid${p.extension(file.path)}");

      final UploadTask task = fileRef.putFile(file);

      final TaskSnapshot snapshot = await task;
      if (snapshot.state == TaskState.success) {
        final downloadUrl = await fileRef.getDownloadURL();
        print("Upload successful, download URL: $downloadUrl");
        return downloadUrl;
      } else {
        print("Upload failed with state: ${snapshot.state}");
        return null;
      }
    } on FirebaseException catch (e) {
      print("Firebase error during upload: ${e.message}");
      return null;
    } catch (e) {
      print("Unexpected error during upload: $e");
      return null;
    }
  }
}
