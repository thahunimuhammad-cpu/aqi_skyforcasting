import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/quality_check_model.dart';

class SkyAqiProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath;
  bool _isPickingImage = false;
  int _loadingStepIndex = 0;

  QualityCheckModel _qualityCheck = const QualityCheckModel(
    isSharp: true,
    isDaylight: true,
    isSkyVisible: true,
  );

  String? get selectedImagePath => _selectedImagePath;
  bool get isPickingImage => _isPickingImage;
  int get loadingStepIndex => _loadingStepIndex;
  QualityCheckModel get qualityCheck => _qualityCheck;

  void toggleSharpnessCheck() {
    _qualityCheck = _qualityCheck.copyWith(isSharp: !_qualityCheck.isSharp);
    notifyListeners();
  }

  Future<bool> pickSkyPhoto(ImageSource source) async {
    if (_isPickingImage) return false;
    _isPickingImage = true;
    notifyListeners();

    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (photo != null) {
        _selectedImagePath = photo.path;
        _qualityCheck = const QualityCheckModel(
          isSharp: true,
          isDaylight: true,
          isSkyVisible: true,
        );
        _isPickingImage = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }

    _isPickingImage = false;
    notifyListeners();
    return false;
  }
Future<void> startAnalysisPipeline(VoidCallback onCompleted) async {
  try {
    _loadingStepIndex = 0;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200));
    _loadingStepIndex = 1;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1400));
    _loadingStepIndex = 2;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200));
    _loadingStepIndex = 3; // sab steps complete
    notifyListeners();

    onCompleted();
  } catch (e, st) {
    debugPrint('Pipeline error: $e\n$st');
  }
}
 
}