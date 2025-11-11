import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadProfileImage(Uint8List imageBytes) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      // Create a unique file name
      final fileName =
          '${user.uid}_profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('profile_images/$fileName');

      // Upload the data
      final uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final snapshot = await uploadTask.whenComplete(() => null);

      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> deleteOldProfileImage(String? oldImageUrl) async {
    if (oldImageUrl == null || !oldImageUrl.contains('firebase')) return;

    try {
      // Extract the path from the URL
      final uri = Uri.parse(oldImageUrl);
      final path = uri.pathSegments
          .sublist(1)
          .join('/'); // Remove 'v0/b/bucket/o/'
      final ref = _storage.ref().child(
        path.split('?')[0],
      ); // Remove query params
      await ref.delete();
    } catch (e) {
      print('Error deleting old image: $e');
      // Don't throw error as this is not critical
    }
  }
}
