class QualityCheckModel {
  final bool isSharp;
  final bool isDaylight;
  final bool isSkyVisible;

  const QualityCheckModel({
    required this.isSharp,
    required this.isDaylight,
    required this.isSkyVisible,
  });

  bool get canAnalyze => isSharp && isDaylight && isSkyVisible;

  QualityCheckModel copyWith({
    bool? isSharp,
    bool? isDaylight,
    bool? isSkyVisible,
  }) {
    return QualityCheckModel(
      isSharp: isSharp ?? this.isSharp,
      isDaylight: isDaylight ?? this.isDaylight,
      isSkyVisible: isSkyVisible ?? this.isSkyVisible,
    );
  }
}