import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  // collection reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('user_data');

  Future<String?> getEmailByUsername(String username) async {
    try {
      // Query Firestore to find a document where 'username' matches
      QuerySnapshot snapshot =
          await userCollection.where('username', isEqualTo: username).get();

      if (snapshot.docs.isEmpty) {
        return null; // No user found with the given username
      } else {
        // Assuming there's only one user with this username
        return snapshot.docs.first['email'];
      }
    } catch (e) {
      return null;
    }
  }
  Future<String?> getElectrodeMappingByUsername(String username) async {
  try {
    QuerySnapshot snapshot = await userCollection
        .where('username', isEqualTo: username)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    } else {
      return snapshot.docs.first['electrode_mapping'];
    }
  } catch (e) {
    print('Error fetching electrode mapping: $e');
    return null;
  }
}

}
