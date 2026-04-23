import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType { user, admin }

class User {
  final String? uid;
  final String? email;
  final String? fullName;
  final String? username;
  final String? avatar;
  final String? cover;
  final String? bio;
  final Address? address;
  final ProfileHistory? profileHistory;
  final List<String>? followers;
  final List<String>? following;
  final Timestamp? dateOfBirth;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final bool? isProfileCompleted;
  final bool? isVerified;
  final bool? isOnline;
  final UserType? userType;

  User(
      {required this.uid,
      required this.email,
      required this.fullName,
      required this.username,
      this.avatar = "",
      this.cover = "",
      this.bio = "",
      this.address,
      this.profileHistory,
      this.followers = const [],
      this.following = const [],
      this.dateOfBirth,
      this.createdAt,
      this.updatedAt,
      this.isProfileCompleted = false,
      this.isVerified = false,
      this.isOnline = true,
      this.userType});

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'username': username,
      'avatar': avatar,
      'cover': cover,
      'bio': bio,
      'address': address?.toJson(),
      'profileHistory': profileHistory?.toJson(),
      'followers': followers,
      'following': following,
      'dateOfBirth': dateOfBirth,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isProfileCompleted': isProfileCompleted,
      'isVerified': isVerified,
      'isOnline': isOnline,
      'type': userType?.name,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String?,
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      username: json['username'] as String?,
      avatar: json['avatar'] as String?,
      cover: json['cover'] as String?,
      bio: json['bio'] as String?,
      address: json['address'] != null
          ? Address.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      profileHistory: json['profileHistory'] != null
          ? ProfileHistory.fromJson(
              json['profileHistory'] as Map<String, dynamic>)
          : null,
      followers: (json['followers'] as List?)?.cast<String>() ?? const [],
      following: (json['following'] as List?)?.cast<String>() ?? const [],
      dateOfBirth: json['dateOfBirth'] as Timestamp?,
      createdAt: json['createdAt'] as Timestamp?,
      updatedAt: json['updatedAt'] as Timestamp?,
      isProfileCompleted: json['isProfileCompleted'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      isOnline: json['isOnline'] as bool? ?? true,
      userType: json['type'] != null
          ? UserType.values.firstWhere((e) => e.name == json['type'])
          : UserType.user,
    );
  }

  User copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? username,
    String? avatar,
    String? cover,
    String? bio,
    Address? address,
    ProfileHistory? profileHistory,
    List<String>? followers,
    List<String>? following,
    Timestamp? dateOfBirth,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    bool? isProfileCompleted,
    bool? isVerified,
    bool? isOnline,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      cover: cover ?? this.cover,
      bio: bio ?? this.bio,
      address: address ?? this.address,
      profileHistory: profileHistory ?? this.profileHistory,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

class Address {
  final String? city;
  final String? state;
  final String? country;

  Address(this.city, this.state, this.country);

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'state': state,
      'country': country,
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      json['city'],
      json['state'],
      json['country'],
    );
  }
}

class ProfileHistory {
  final String? school;
  final String? college;
  final String? workspace;

  ProfileHistory(this.school, this.college, this.workspace);

  Map<String, dynamic> toJson() {
    return {
      'school': school,
      'college': college,
      'workspace': workspace,
    };
  }

  factory ProfileHistory.fromJson(Map<String, dynamic> json) {
    return ProfileHistory(
      json['school'],
      json['college'],
      json['workspace'],
    );
  }
}
