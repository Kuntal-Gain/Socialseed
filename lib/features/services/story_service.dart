import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'dart:io';

import 'package:ffmpeg_kit_flutter/return_code.dart';

Future<void> sliceVideoIntoSegments(
    String inputFilePath, String outputDirectory) async {
  const int segmentDuration = 30; // Duration of each segment in seconds

  // Ensure output directory exists
  Directory(outputDirectory).createSync(recursive: true);

  // Run the FFmpeg command
  String command =
      '-i $inputFilePath -c copy -map 0 -segment_time $segmentDuration -f segment '
      '-reset_timestamps 1 $outputDirectory/output_%03d.mp4';

  await FFmpegKit.executeAsync(command, (session) async {
    final returnCode = await session.getReturnCode();
    if (ReturnCode.isSuccess(returnCode)) {
      print("Slicing successful");
    } else {
      print("Error slicing video: ${await session.getFailStackTrace()}");
    }
  });
}
