import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class VideoProcessor {
  Future<String?> adjustAudio({
    required String inputPath,
    required double volumeMultiplier,
    required double bassMultiplier,
    required String outputFileName,
    required bool smoothTransition,
  }) async {
    // Ensure that the input file exists
    final inputFile = File(inputPath);
    if (!await inputFile.exists()) {
      print("Input file does not exist: $inputPath");
      return null;
    }

    // Get the temporary directory
    final directory = await getTemporaryDirectory();
    final outputPath = path.join(directory.path, outputFileName);

    // Build the FFmpeg command
    final volumeAdjustment = volumeMultiplier; // Ensure this is in the correct range
    final bassAdjustment = bassMultiplier; // Ensure this is in the correct range

    String command = "-i $inputPath -af \"volume=${volumeAdjustment},bass=g=${bassAdjustment}\" $outputPath";

    // Execute the FFmpeg command
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    // Check the return code for success or failure
    if (returnCode!.isValueSuccess()) {
      print("Process completed successfully");
      return outputPath;
    } else {
      // Retrieve and print the logs from the FFmpeg process
      final logs = await session.getLogs();
      print("Process failed with return code ${returnCode.getValue()}");
      print("Logs: $logs");
      return null;
    }
  }
}
