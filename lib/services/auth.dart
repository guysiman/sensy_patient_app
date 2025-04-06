import 'package:firebase_auth/firebase_auth.dart';
import 'package:sensy_patient_app/services/database.dart';


class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  void getPatientElectrodeMapping(String username) async {
  DatabaseService db = DatabaseService();
  String? electrodeMapping = await db.getElectrodeMappingByUsername(username);
  if (electrodeMapping != null) {
    print('Electrode Mapping: $electrodeMapping');
  
  } else {
    print('Electrode mapping not found for user: $username');
  }
}


  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
