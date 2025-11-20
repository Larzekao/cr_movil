import '../../domain/entities/diabetes_prediction_entity.dart';

class DiabetesPredictionModel extends DiabetesPredictionEntity {
  const DiabetesPredictionModel({
    required super.id,
    required super.patientId,
    required super.patientName,
    required super.hasDiabetesRisk,
    required super.probability,
    required super.riskLevel,
    required super.modelVersion,
    required super.featuresUsed,
    super.contributingFactors,
    super.recommendations,
    required super.predictionDate,
  });

  factory DiabetesPredictionModel.fromJson(Map<String, dynamic> json) {
    return DiabetesPredictionModel(
      id: json['id'] ?? '',
      patientId: json['patient'] ?? '',
      patientName: json['patient_name'] ?? 'Paciente',
      hasDiabetesRisk: json['has_diabetes_risk'] ?? false,
      probability: (json['probability'] ?? 0.0).toDouble(),
      riskLevel: json['risk_level'] ?? 'low',
      modelVersion: json['model_version'] ?? '1.0',
      featuresUsed: json['features_used'] ?? {},
      contributingFactors: json['contributing_factors'] != null
          ? List<String>.from(json['contributing_factors'])
          : null,
      recommendations: json['recommendations'] != null
          ? List<String>.from(json['recommendations'])
          : null,
      predictionDate: json['prediction_date'] != null
          ? DateTime.parse(json['prediction_date'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient': patientId,
      'has_diabetes_risk': hasDiabetesRisk,
      'probability': probability,
      'risk_level': riskLevel,
      'model_version': modelVersion,
      'features_used': featuresUsed,
      'contributing_factors': contributingFactors,
      'recommendations': recommendations,
      'prediction_date': predictionDate.toIso8601String(),
    };
  }
}
