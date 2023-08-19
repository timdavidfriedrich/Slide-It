import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:log/log.dart';
import 'package:rating/features/overview/models/item.dart';

class StorageService {
  static StorageService instance = StorageService();

  final String _bucketName = FirebaseStorage.instance.bucket;
  final Reference _itemImages = FirebaseStorage.instance.ref().child("item_images");

  Reference _getImageRefOfItem(Item item) {
    return _itemImages.child(item.group.id).child(item.id);
  }

  Future<void> uploadItemImage({required Uint8List imageData, required Item item}) async {
    try {
      await _getImageRefOfItem(item).putData(imageData);
    } catch (e) {
      Log.error(e);
    }
  }

  String getItemImageDownloadUrl({required Item item}) {
    // try {
    //   final String downloadUrl = await getImageRefOfItem(item).getDownloadURL();
    //   return downloadUrl;
    // } catch (e) {
    //   Log.error(e);
    //   return null;
    // }
    return "gs://$_bucketName/${_getImageRefOfItem(item).fullPath}";
  }

  Future<Uint8List?> downloadItemImage({required Item item}) async {
    try {
      final Uint8List? imageData = await _getImageRefOfItem(item).getData();
      return imageData;
    } catch (e) {
      Log.error(e);
      return null;
    }
  }
}
