import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialseed/core/network/api_endpoint.dart';
import 'package:socialseed/core/provider/user_provider.dart';
import 'package:socialseed/core/usecases/usecases_impl.dart';
import 'package:socialseed/features/auth_module/data/auth/auth_usecase.dart';
import 'package:socialseed/features/auth_module/data/cred/creds_usecase.dart';
import 'package:socialseed/features/auth_module/model/user_model.dart';
import 'package:socialseed/core/network/locator.dart';

class CredsUseCasesImpl implements CredsUseCase {
  final _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createUser(User user) async {
    final payload = {
      'uid': user.uid,
      'email': user.email,
      'fullName': user.fullName,
      'username': user.username,
      'avatar': user.avatar,
      'cover': "",
      'bio': "",
      'followers': <String>[],
      'following': <String>[],
      'dateOfBirth': user.dateOfBirth,
      'address': user.address?.toJson(),
      'profileHistory': user.profileHistory?.toJson(),
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'isProfileCompleted': false,
      'isVerified': false,
      'isOnline': true,
    };

    try {
      await _firestore.collection(Collections.users).doc(user.uid).set(payload);
    } on FirebaseException catch (e) {
      throw Exception(
        'Firestore error [${e.code}]: ${e.message}',
      );
    } catch (e) {
      throw Exception('Unknown error while creating user: $e');
    }
  }

  @override
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(Collections.users).doc(uid).delete();
    } on FirebaseException catch (e) {
      throw Exception(
        'Firestore error [${e.code}]: ${e.message}',
      );
    } catch (e) {
      throw Exception('Unknown error while deleting user: $e');
    }
  }

  @override
  Future<List<User>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
    } on FirebaseException catch (e) {
      throw Exception('Firestore error [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error while fetching users: $e');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    final uid = await getCurrentUid();

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return User.fromJson(doc.data()!);
    } on FirebaseException catch (e) {
      throw Exception('Firestore error [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error while fetching current user: $e');
    }
  }

  @override
  Future<User?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return User.fromJson(doc.data()!);
    } on FirebaseException catch (e) {
      throw Exception('Firestore error [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error while fetching user: $e');
    }
  }

  @override
  Future<List<User>> searchUser(String query) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return snapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
    } on FirebaseException catch (e) {
      throw Exception('Firestore error [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error while searching users: $e');
    }
  }

  @override
  Future<void> updateProfile(User user) {
    throw UnimplementedError();
  }

  @override
  Future<void> toggleOnlineStatus(String uid) async {
    try {
      final docRef = _firestore.collection(Collections.users).doc(uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception("User not found");
      }

      final currentStatus = doc.data()?['isOnline'] as bool? ?? false;
      final payload = {'isOnline': !currentStatus}; // toggle

      await docRef.update(payload);
    } on FirebaseException catch (e) {
      throw Exception('Firestore error [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error while toggling online status: $e');
    }
  }
}
