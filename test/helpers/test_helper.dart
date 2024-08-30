import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  FirebaseRepository
], customMocks: [
  MockSpec<FirebaseAuth>(as: #MockFirebaseAuth),
  MockSpec<FirebaseFirestore>(as: #MockFirebaseFirestore),
])
void main() {}
