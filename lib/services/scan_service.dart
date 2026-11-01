import '../data/mock/mock_scan_data.dart';
import '../models/skin_scan.dart';

/// Stores scan sessions and their images.
abstract class ScanService {
  Future<List<ScanSession>> fetchHistory();

  Future<void> saveScan(ScanSession session);

  /// Uploads one image and returns its remote reference.
  Future<String> uploadImage(ScanImage image);
}

/// In-memory scan storage used by the demo.
///
/// FUTURE DATABASE INTEGRATION:
/// `fetchHistory` → `GET /scans`, `saveScan` → `POST /scans` with
/// `session.toJson()` (answers, regions, image references, status).
class MockScanService implements ScanService {
  @override
  Future<List<ScanSession>> fetchHistory() async =>
      MockScanData.seededHistory();

  @override
  Future<void> saveScan(ScanSession session) async {
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<String> uploadImage(ScanImage image) async {
    // FUTURE IMAGE UPLOAD INTEGRATION:
    // Upload the selected image securely (multipart / pre-signed URL) and
    // return the storage reference that the analysis API expects.
    await Future.delayed(const Duration(milliseconds: 200));
    return 'local://${image.path}';
  }
}
