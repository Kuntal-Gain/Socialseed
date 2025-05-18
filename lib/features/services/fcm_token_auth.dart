import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;
import 'package:socialseed/utils/constants/firebase_const.dart';

class NotificationService {
  static Future<String> getAccessToken() async {
    // Load the keys.json from assets
    final jsonString = await rootBundle.loadString('keys.json');
    final jsonMap = json.decode(jsonString);

    // Grab the email and private key from the JSON
    final accountEmail = jsonMap['client_email'] as String;
    final privateKey = jsonMap['private_key'] as String;

    // Create the ServiceAccountCredentials
    final credentials = ServiceAccountCredentials(
      accountEmail,
      ClientId('', ''), // Usually empty for service accounts
      privateKey,
    );

    // The scope required for Firebase Cloud Messaging API
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    // Authenticate and get an authenticated HTTP client
    final client = await clientViaServiceAccount(credentials, scopes);

    // Extract the access token string
    final accessToken = client.credentials.accessToken.data;

    client.close();

    return accessToken;
  }

  static Future<void> sendNotification(
      String uid, String label, String notification) async {
    final token = await NotificationService.getAccessToken();
    final userCollection =
        FirebaseFirestore.instance.collection(FirebaseConst.users);
    final userRef = await userCollection.doc(uid).get();

    final fcmToken = userRef.get('fcmToken');

    debugPrint('FCM Token: $fcmToken');

    await http.post(
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/socialseed-609fa/messages:send'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'message': {
          'token': fcmToken,
          'notification': {
            'title': label,
            'body': notification,
          },
        },
      }),
    );
  }
}
