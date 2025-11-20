import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/diabetes_bloc.dart';
import '../bloc/diabetes_event.dart';
import '../bloc/diabetes_state.dart';
import '../../domain/entities/diabetes_prediction_entity.dart';
import '../../../help/presentation/widgets/help_chat_button.dart';

class DiabetesPredictionPage extends StatefulWidget {
  final String patientId;
  final String patientName;

  const DiabetesPredictionPage({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<DiabetesPredictionPage> createState() => _DiabetesPredictionPageState();
}

class _DiabetesPredictionPageState extends State<DiabetesPredictionPage> {
  @override
  void initState() {
    super.initState();
    _loadPredictionHistory();
  }

  void _loadPredictionHistory() {
    context.read<DiabetesBloc>().add(
          GetPredictionHistoryRequested(widget.patientId),
        );
  }

  void _makeNewPrediction() {
    context.read<DiabetesBloc>().add(
          PredictDiabetesRequested(widget.patientId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predicción de Diabetes'),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          BlocConsumer<DiabetesBloc, DiabetesState>(
            listener: (context, state) {
              if (state is DiabetesError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is DiabetesPredictionLoaded) {
                // Mostrar diálogo con el resultado
                _showPredictionDialog(state.prediction);
                // Recargar historial
                _loadPredictionHistory();
              }
            },
            builder: (context, state) {
              if (state is DiabetesLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is DiabetesPredictionHistoryLoaded) {
                return _buildContent(state.predictions);
              }

              if (state is DiabetesPredictionLoaded) {
                return _buildSinglePrediction(state.prediction);
              }

              // Estado inicial
              return _buildInitialState();
            },
          ),
          // Botón de ayuda flotante
          const HelpChatButtonMini(alignment: Alignment.bottomLeft),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _makeNewPrediction,
        icon: const Icon(Icons.analytics),
        label: const Text('Nueva Predicción'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.analytics_outlined,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          Text(
            'Predicción de Diabetes',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Utiliza IA para predecir el riesgo de diabetes del paciente ${widget.patientName}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _makeNewPrediction,
            icon: const Icon(Icons.analytics),
            label: const Text('Realizar Predicción'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<DiabetesPredictionEntity> predictions) {
    if (predictions.isEmpty) {
      return _buildInitialState();
    }

    return RefreshIndicator(
      onRefresh: () async => _loadPredictionHistory(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Última predicción destacada
          _buildLatestPredictionCard(predictions.first),
          const SizedBox(height: 24),

          // Historial
          if (predictions.length > 1) ...[
            Text(
              'Historial de Predicciones',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...predictions.skip(1).map(_buildHistoryItem),
          ],
        ],
      ),
    );
  }

  Widget _buildSinglePrediction(DiabetesPredictionEntity prediction) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildLatestPredictionCard(prediction),
    );
  }

  Widget _buildLatestPredictionCard(DiabetesPredictionEntity prediction) {
    final riskColor = _getRiskColor(prediction.riskLevel);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              riskColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Ícono y título
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getRiskIcon(prediction.riskLevel),
                    size: 32,
                    color: riskColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Última Predicción',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        prediction.hasDiabetesRisk
                            ? 'RIESGO DETECTADO'
                            : 'RIESGO BAJO',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: riskColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 32),

            // Probabilidad grande
            Column(
              children: [
                const Text(
                  'Probabilidad de Diabetes',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  prediction.probabilityPercentage,
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: riskColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Nivel de riesgo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: riskColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber, color: riskColor),
                  const SizedBox(width: 8),
                  Text(
                    'Riesgo ${prediction.riskLevelText}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: riskColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Información adicional
            _buildInfoRow(
              'Modelo',
              'v${prediction.modelVersion}',
              Icons.psychology,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Fecha',
              _formatDate(prediction.predictionDate),
              Icons.calendar_today,
            ),

            // Factores contribuyentes
            if (prediction.contributingFactors != null &&
                prediction.contributingFactors!.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Factores Contribuyentes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...prediction.contributingFactors!.take(3).map(
                    (factor) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 8, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              factor,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],

            // Recomendaciones
            if (prediction.recommendations != null &&
                prediction.recommendations!.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Recomendaciones',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...prediction.recommendations!.take(3).map(
                    (rec) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              size: 16, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              rec,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(DiabetesPredictionEntity prediction) {
    final riskColor = _getRiskColor(prediction.riskLevel);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: riskColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(_getRiskIcon(prediction.riskLevel), color: riskColor),
        ),
        title: Text(
          prediction.probabilityPercentage,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: riskColor,
          ),
        ),
        subtitle: Text(_formatDate(prediction.predictionDate)),
        trailing: Chip(
          label: Text(
            prediction.riskLevelText,
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: riskColor.withOpacity(0.2),
          labelStyle: TextStyle(color: riskColor),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey[600]),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  void _showPredictionDialog(DiabetesPredictionEntity prediction) {
    final riskColor = _getRiskColor(prediction.riskLevel);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getRiskIcon(prediction.riskLevel), color: riskColor),
            const SizedBox(width: 12),
            const Expanded(child: Text('Predicción Completada')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                prediction.probabilityPercentage,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: riskColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Riesgo ${prediction.riskLevelText}',
                style: TextStyle(
                  fontSize: 20,
                  color: riskColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'very_high':
        return Colors.red[900]!;
      default:
        return Colors.grey;
    }
  }

  IconData _getRiskIcon(String riskLevel) {
    switch (riskLevel) {
      case 'low':
        return Icons.check_circle;
      case 'medium':
        return Icons.warning_amber;
      case 'high':
        return Icons.error;
      case 'very_high':
        return Icons.dangerous;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
