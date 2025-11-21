import 'package:equatable/equatable.dart';

class DiabetesPredictionEntity extends Equatable {
  final String id;
  final String patientId;
  final String patientName;
  final bool hasDiabetesRisk;
  final double probability;
  final String riskLevel; // 'low', 'medium', 'high', 'very_high'
  final String modelVersion;
  final Map<String, dynamic> featuresUsed;
  final List<String>? contributingFactors;
  final List<String>? recommendations;
  final DateTime predictionDate;

  const DiabetesPredictionEntity({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.hasDiabetesRisk,
    required this.probability,
    required this.riskLevel,
    required this.modelVersion,
    required this.featuresUsed,
    this.contributingFactors,
    this.recommendations,
    required this.predictionDate,
  });

  /// Obtener color según nivel de riesgo
  String get riskColor {
    switch (riskLevel) {
      case 'low':
        return '#4CAF50'; // Verde
      case 'medium':
        return '#FF9800'; // Naranja
      case 'high':
        return '#F44336'; // Rojo
      case 'very_high':
        return '#D32F2F'; // Rojo oscuro
      default:
        return '#9E9E9E'; // Gris
    }
  }

  /// Obtener texto del nivel de riesgo
  String get riskLevelText {
    switch (riskLevel) {
      case 'low':
        return 'Bajo';
      case 'medium':
        return 'Medio';
      case 'high':
        return 'Alto';
      case 'very_high':
        return 'Muy Alto';
      default:
        return 'Desconocido';
    }
  }

  /// Probabilidad como porcentaje
  String get probabilityPercentage => '${(probability * 100).toStringAsFixed(1)}%';

  @override
  List<Object?> get props => [
        id,
        patientId,
        hasDiabetesRisk,
        probability,
        riskLevel,
        modelVersion,
        predictionDate,
      ];
}
