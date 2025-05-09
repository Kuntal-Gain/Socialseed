import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:socialseed/app/widgets/profile_widget.dart';
import 'package:socialseed/features/services/theme_service.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/firebase_const.dart';
import 'package:socialseed/utils/constants/page_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';

class RequestForVerificationScreen extends StatefulWidget {
  final String uid;
  const RequestForVerificationScreen({Key? key, required this.uid})
      : super(key: key);

  @override
  State<RequestForVerificationScreen> createState() =>
      _RequestForVerificationScreenState();
}

class _RequestForVerificationScreenState
    extends State<RequestForVerificationScreen> {
  int followers = 0;
  double progressValue = 0.0;
  bool isVerify = false;

  @override
  void initState() {
    super.initState();
    getRequest();
  }

  Future<void> getRequest() async {
    followers = await getFollowers(widget.uid);
    isVerify = await getVerifyStatus(widget.uid);
    setState(() {
      progressValue = followers / 100;
    });
  }

  Future<int> getFollowers(String uid) async {
    final userDoc = await FirebaseFirestore.instance
        .collection(FirebaseConst.users)
        .doc(uid)
        .get();
    final followerCount = userDoc.data()?['followerCount'] ?? 0;
    return followerCount;
  }

  Future<bool> getVerifyStatus(String uid) async {
    final userDoc = await FirebaseFirestore.instance
        .collection(FirebaseConst.users)
        .doc(uid)
        .get();
    final status = userDoc.data()?['isVerified'] ?? 0;
    return status;
  }

  Future<void> sendRequest(String uid, String message) async {
    // Get a reference to the Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Define the document data
    Map<String, dynamic> requestData = {
      'uid': uid, // Store the current user ID for verification
      'message': message, // Store the user's message
      'timestamp': FieldValue
          .serverTimestamp(), // Add a timestamp for when the request was made
    };

    try {
      // Add the request to the "QA" collection
      await firestore.collection('QA').add(requestData);
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final bg = Provider.of<ThemeService>(context).isDarkMode
        ? AppColor.bgDark
        : AppColor.whiteColor;

    final secondaryColor = Provider.of<ThemeService>(context).isDarkMode
        ? AppColor.secondaryDark
        : AppColor.whiteColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Request Verification'),
        backgroundColor: bg,
      ),
      body: Column(
        children: [
          sizeVar(100),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: Stack(
                children: [
                  if (isVerify)
                    Container(
                      height: 200,
                      width: 200,
                      margin: const EdgeInsets.all(10),
                      child: const CircularProgressIndicator(
                        value: 1,
                        strokeWidth: 15,
                        strokeCap: StrokeCap.round,
                        color: AppColor.redColor,
                      ),
                    ),
                  if (!isVerify)
                    Container(
                      height: 200,
                      width: 200,
                      margin: const EdgeInsets.all(10),
                      child: const CircularProgressIndicator(
                        value: 1,
                        strokeWidth: 15,
                        strokeCap: StrokeCap.round,
                        color: AppColor.greyShadowColor,
                      ),
                    ),
                  if (!isVerify)
                    Container(
                      height: 200,
                      width: 200,
                      margin: const EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        value: progressValue,
                        strokeWidth: 15,
                        strokeCap: StrokeCap.round,
                        color: AppColor.redColor,
                      ),
                    ),
                  Positioned(
                    top: !isVerify ? 100 : 85,
                    left: 50,
                    right: 50,
                    child: Center(
                        child: !isVerify
                            ? Text(
                                'Followers',
                                style: TextConst.headingStyle(
                                  22,
                                  AppColor.redColor,
                                ),
                              )
                            : const Icon(
                                Icons.verified,
                                size: 50,
                                color: AppColor.redColor,
                              )),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 65,
                    child: Container(
                      width: 100,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color:
                              !isVerify ? Colors.redAccent : AppColor.redColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColor.greyShadowColor,
                          )),
                      child: Center(
                          child: Text(
                        !isVerify ? '$followers / 100' : "Verifed",
                        style: TextConst.headingStyle(14, AppColor.whiteColor),
                      )),
                    ),
                  )
                ],
              ),
            ),
          ),
          sizeVar(40),
          if (isVerify)
            Container(
              height: 60,
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Provider.of<ThemeService>(context).isDarkMode
                          ? AppColor.blackColor
                          : AppColor.greyShadowColor,
                      blurRadius: 5,
                    ),
                  ]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "You are Verified ",
                    style: TextConst.headingStyle(
                      18,
                      AppColor.redColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Icon(
                    Icons.check_circle,
                    color: AppColor.redColor,
                  )
                ],
              ),
            ),
          if (!isVerify)
            getButton(
              (followers >= 100)
                  ? "Request for Verification"
                  : "Not Eligible for Verification",
              (followers >= 100)
                  ? () => sendRequest(
                      widget.uid, "${widget.uid} is Requested for verification")
                  : () {
                      debugPrint("User is not eligible");
                    },
              (followers >= 100) ? false : true,
              context,
            ),
        ],
      ),
    );
  }
}
