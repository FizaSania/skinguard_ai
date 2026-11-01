import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ImageServiceException implements Exception {
  const ImageServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Camera / gallery boundary. Widgets never call image_picker directly, so
/// the capture implementation can be swapped (e.g. for the `camera` package
/// with a live preview and real lighting checks) without touching the UI.
abstract class ImageService {
  /// Returns a path/URL of the captured photo, or null if cancelled.
  Future<String?> capturePhoto();

  /// Returns a path/URL of the chosen photo, or null if cancelled.
  Future<String?> pickFromGallery();
}

/// Uses the system camera / photo picker via `image_picker`.
///
/// FUTURE IMAGE UPLOAD INTEGRATION:
/// Compress the returned file, upload it securely and store the returned
/// reference on `ScanImage.remoteReference` (see ScanService.uploadImage).
class DeviceImageService implements ImageService {
  DeviceImageService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<String?> capturePhoto() async {
    if (!_supportsCamera) {
      throw const ImageServiceException(
          'Camera capture is not available on this device.');
    }
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 2048,
        imageQuality: 90,
      );
      return file?.path;
    } catch (e) {
      throw ImageServiceException('Could not open the camera ($e).');
    }
  }

  @override
  Future<String?> pickFromGallery() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        imageQuality: 90,
      );
      return file?.path;
    } catch (e) {
      throw ImageServiceException('Could not open the gallery ($e).');
    }
  }

  bool get _supportsCamera =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
}
