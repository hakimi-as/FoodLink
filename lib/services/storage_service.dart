import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import '../core/config/cloudinary_config.dart';

class StorageService {
  static final CloudinaryPublic _cloudinary = CloudinaryPublic(
    CloudinaryConfig.cloudName,
    CloudinaryConfig.uploadPreset,
    cache: false,
  );

  Future<String> uploadProfilePhoto(XFile file, String uid) async {
    final bytes = await file.readAsBytes();
    final response = await _cloudinary.uploadFile(
      CloudinaryFile.fromBytesData(
        bytes,
        identifier: 'profile_$uid',
        resourceType: CloudinaryResourceType.Image,
        folder: 'foodlink/profiles',
      ),
    );
    return response.secureUrl;
  }

  Future<String> uploadFoodImage(XFile file, String itemId) async {
    final bytes = await file.readAsBytes();
    final response = await _cloudinary.uploadFile(
      CloudinaryFile.fromBytesData(
        bytes,
        identifier: 'food_$itemId',
        resourceType: CloudinaryResourceType.Image,
        folder: 'foodlink/food',
      ),
    );
    return response.secureUrl;
  }
}
