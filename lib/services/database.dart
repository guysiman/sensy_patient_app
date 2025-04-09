import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  // collection reference
  final CollectionReference userCollection =
  FirebaseFirestore.instance.collection('user_data');

  // Get electrode mapping by email
  Future<String?> getElectrodeMappingByEmail(String email) async {
    try {
      QuerySnapshot snapshot = await userCollection
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      } else {
        var data = snapshot.docs.first.data() as Map<String, dynamic>;
        return data['electrode_mapping'];
      }
    } catch (e) {
      print('Error fetching electrode mapping: $e');
      return null;
    }
  }

  // Save user settings to Firestore
  Future<void> saveUserSettings(String email, Map<String, dynamic> settings) async {
    try {
      // Query Firestore to find a document where 'email' matches
      QuerySnapshot snapshot = await userCollection
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isEmpty) {
        // No user found, create a new document
        await userCollection.add({
          'email': email,
          'settings': settings,
          'last_updated': FieldValue.serverTimestamp(),
        });
      } else {
        // User found, update the existing document
        await snapshot.docs.first.reference.update({
          'settings': settings,
          'last_updated': FieldValue.serverTimestamp(),
        });
      }
      print('Settings saved successfully for $email');
    } catch (e) {
      print('Error saving settings: $e');
      throw e;
    }
  }

  // Load user settings from Firestore
  Future<Map<String, dynamic>?> getUserSettings(String email) async {
    try {
      QuerySnapshot snapshot = await userCollection
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isEmpty) {
        return null; // No user found with the given email
      } else {
        // Return the settings map from the document
        Map<String, dynamic> data = snapshot.docs.first.data() as Map<String, dynamic>;
        return data.containsKey('settings') ? data['settings'] : null;
      }
    } catch (e) {
      print('Error loading settings: $e');
      return null;
    }
  }

  // Save specific session settings (intensity level and paradigm)
  Future<void> saveSessionSettings(String email, int intensityLevel, String paradigm, bool isDefault) async {
    try {
      // Use a consistent path - store in user_data collection
      final userDocRef = userCollection.doc(email);

      // First check if document exists
      final docSnapshot = await userDocRef.get();

      if (docSnapshot.exists) {
        // Update existing document
        await userDocRef.update({
          'session_settings': {
            'intensity_level': intensityLevel,
            'paradigm': paradigm,
            'is_default': isDefault,
            'timestamp': FieldValue.serverTimestamp(),
          }
        });
      } else {
        // Create new document
        await userDocRef.set({
          'email': email,
          'session_settings': {
            'intensity_level': intensityLevel,
            'paradigm': paradigm,
            'is_default': isDefault,
            'timestamp': FieldValue.serverTimestamp(),
          }
        });
      }
      print('Session settings saved for $email');
    } catch (e) {
      print('Error saving session settings: $e');
      throw e;
    }
  }

  // Get session settings
  Future<Map<String, dynamic>?> getSessionSettings(String email) async {
    try {
      // Use same path as saving - user_data collection with document ID = email
      final docSnapshot = await userCollection.doc(email).get();

      if (!docSnapshot.exists) {
        return null;
      } else {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        return data.containsKey('session_settings') ? data['session_settings'] : null;
      }
    } catch (e) {
      print('Error loading session settings: $e');
      return null;
    }
  }
}