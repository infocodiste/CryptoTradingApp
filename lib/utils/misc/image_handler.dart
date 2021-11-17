import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../theme_data.dart';
import 'permission_manager.dart';

class ImageHandler {
  static final _instance = ImageHandler._internal();

  ImageHandler._internal();

  static ImageHandler get() {
    return _instance;
  }

  Future<File> getImage(BuildContext context, {bool isCamera: false}) async {
    bool isGranted = await PermissionManager.get().requestStoragePermission();
    if (isGranted) {
      XFile pickedFile = await ImagePicker().pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      return File(pickedFile.path);
    } else {
      showToast("Please grant storage permission to access images.");
      return null;
    }
  }

  /// Crop Image
  Future<File> cropImage(filePath) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: filePath,
      maxWidth: 1080,
      maxHeight: 1080,
    );
    return croppedImage;
  }

  Future<File> getVideo(BuildContext context, {bool isCamera: false}) async {
    bool isGranted = await PermissionManager.get().requestStoragePermission();
    if (isGranted) {
      PickedFile pickedFile = await ImagePicker().getVideo(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
      );
      return File(pickedFile.path);
    } else {
      showToast("Please grant storage permission to access video.");
      return null;
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: AppTheme.purpleSelected,
        textColor: Colors.white,
        fontSize: 14.0);
  }

  Future<File> pickImageGifFile() async {
    bool isGranted = await PermissionManager.get().requestStoragePermission();
    if (isGranted) {
      FilePickerResult result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gif', 'png', 'jpg'],
      );
      if (result != null) {
        File file = File(result.files.single.path);
        return file;
      } else {
        showToast("Cancelled Picker");
        return null;
      }
    } else {
      showToast("Please grant storage permission to access images.");
      return null;
    }
  }
}
