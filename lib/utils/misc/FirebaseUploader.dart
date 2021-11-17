import 'dart:io';

import 'package:coin_analyzer/constants.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FirebaseUploader {
  static final FirebaseUploader _firebaseUploader =
      new FirebaseUploader._internal();

  static FirebaseUploader get() {
    return _firebaseUploader;
  }

  FirebaseUploader._internal();

  Future<String> uploadFileToFBBucket(File uploadFile, Function onData) async {
    String filePath = await getActualFilePath(uploadFile.path);
    uploadFile = File(filePath);
    bool isExist = await uploadFile.exists();
    if (isExist) {
      String fileName = basename(uploadFile.path);
      print("File Path : ${uploadFile.path}");
      print("File Name : $fileName");
      firebase_storage.Reference _reference;
      firebase_storage.UploadTask _uploadTask;
      _reference = firebase_storage.FirebaseStorage.instance
          .refFromURL(FIREBASE_BUCKET_URL)
          .child("$FIREBASE_BUCKET_FOLDER/$fileName");
      _uploadTask = _reference.putFile(uploadFile);

      _uploadTask.snapshotEvents.listen((event) async {
        double _progress = (event.bytesTransferred / event.totalBytes);
        onData(_progress);
      }).onError((error) {
        print("Uploading Error : ${error.toString()}");
      });
      await _uploadTask.whenComplete(() {});
      String fileURL = await _reference.getDownloadURL();
      print("contentFileUrl :$fileURL");
      return fileURL;
    } else {
      print("File not found : ${uploadFile.path.toString()}");
      return "";
    }
  }

  Future<String> getActualFilePath(String filePath) async {
    if (Platform.isIOS && filePath.contains("/$appName")) {
//      print("Old File Path : $filePath");
      String appFolderPath = filePath.substring(filePath.indexOf("/$appName"));
//      print("appFolderPath : $appFolderPath");
      Directory directory = await getApplicationDocumentsDirectory();
//      print("directory : ${directory.path}");
      String iosFilePath = "${directory.path}$appFolderPath";
//      print("New File Path : $iosFilePath");
      return iosFilePath;
    } else {
      return filePath;
    }
  }
}
