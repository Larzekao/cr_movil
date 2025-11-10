import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/clinical_record_entity.dart';
import '../bloc/clinical_record_bloc.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as custom;
import 'package:intl/intl.dart';

class ClinicalRecordDetailPage extends StatefulWidget {
  final String clinicalRecordId;

  const ClinicalRecordDetailPage({
    Key? key,
    required this.clinicalRecordId,
  }) : super(key: key);

  @override
  State<ClinicalRecordDetailPage> createState() =>
      _ClinicalRecordDetailPageState();
}

class _ClinicalRecordDetailPageState extends State<ClinicalRecordDetailPage> {
  @override
  void initState() {
    super.initState();
    // Cargar detalle de la historia clínica
    context.read<ClinicalRecordBloc>().add(
          GetClinicalRecordDetailEvent(widget.clinicalRecordId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Historia Clínica'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/clinical-record-edit',
                arguments: widget.clinicalRecordId,
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ClinicalRecordBloc, ClinicalRecordState>(
        listener: (context, state) {
          if (state is ClinicalRecordError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ClinicalRecordLoading) {
            return const LoadingWidget();
          }

          if (state is ClinicalRecordError) {
            return custom.ErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<ClinicalRecordBloc>().add(
                      GetClinicalRecordDetailEvent(widget.clinicalRecordId),
                    );
              },
            );
          }

          if (state is ClinicalRecordDetailLoaded) {
            return _buildDetailContent(context, state.record);
          }

          return const Center(
            child: Text('No se pudo cargar la información'),
          );
        },
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, ClinicalRecordEntity record) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ClinicalRecordBloc>().add(
              GetClinicalRecordDetailEvent(widget.clinicalRecordId),
            );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información básica
            _buildInfoCard(
              icon: Icons.folder_copy_outlined,
              title: 'Información General',
              children: [
                _buildInfoRow('Número de Historia', record.recordNumber),
                _buildInfoRow('Estado', _getStatusText(record.status)),
                _buildInfoRow(
                  'Fecha de Creación',
                  dateFormat.format(record.createdAt),
                ),
                _buildInfoRow(
                  'Última Actualización',
                  dateFormat.format(record.updatedAt),
                ),
                if (record.createdByName != null)
                  _buildInfoRow('Creado por', record.createdByName!),
              ],
            ),

            const SizedBox(height: 16),

            // Información del paciente
            if (record.patientInfo != null)
              _buildInfoCard(
                icon: Icons.person,
                title: 'Información del Paciente',
                children: [
                  _buildInfoRow(
                    'Nombre Completo',
                    record.patientInfo!.fullName,
                  ),
                  _buildInfoRow(
                    'Identificación',
                    record.patientInfo!.identification,
                  ),
                  _buildInfoRow(
                    'Fecha de Nacimiento',
                    dateFormat.format(record.patientInfo!.dateOfBirth),
                  ),
                  _buildInfoRow('Género', record.patientInfo!.gender),
                ],
              ),

            const SizedBox(height: 16),

            // Información médica
            _buildInfoCard(
              icon: Icons.medical_services,
              title: 'Información Médica',
              children: [
                if (record.bloodType != null)
                  _buildInfoRow('Tipo de Sangre', record.bloodType!),
                _buildInfoRow(
                  'Alergias',
                  record.allergies.isEmpty
                      ? 'Ninguna'
                      : record.allergies
                          .map((a) => a.allergen)
                          .join(', '),
                ),
                _buildInfoRow(
                  'Condiciones Crónicas',
                  record.chronicConditions.isEmpty
                      ? 'Ninguna'
                      : record.chronicConditions.join(', '),
                ),
                _buildInfoRow(
                  'Medicamentos Actuales',
                  record.medications.isEmpty
                      ? 'Ninguno'
                      : record.medications
                          .map((m) => m.name)
                          .join(', '),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Alergias detalladas
            if (record.allergies.isNotEmpty) ...[
              _buildSectionTitle('Alergias Detalladas'),
              ...record.allergies.map((allergy) => _buildAllergyCard(allergy)),
              const SizedBox(height: 16),
            ],

            // Medicamentos detallados
            if (record.medications.isNotEmpty) ...[
              _buildSectionTitle('Medicamentos Detallados'),
              ...record.medications
                  .map((medication) => _buildMedicationCard(medication)),
              const SizedBox(height: 16),
            ],

            // Historial familiar
            if (record.familyHistory != null &&
                record.familyHistory!.isNotEmpty) ...[
              _buildInfoCard(
                icon: Icons.family_restroom,
                title: 'Historial Familiar',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(record.familyHistory!),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Historial social
            if (record.socialHistory != null &&
                record.socialHistory!.isNotEmpty) ...[
              _buildInfoCard(
                icon: Icons.people,
                title: 'Historial Social',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(record.socialHistory!),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Estadísticas
            _buildInfoCard(
              icon: Icons.analytics,
              title: 'Estadísticas',
              children: [
                _buildInfoRow(
                  'Total de Documentos',
                  record.documentsCount.toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAllergyCard(Allergy allergy) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.warning_amber, color: Colors.orange),
        title: Text(allergy.allergen),
        subtitle: Text('Reacción: ${allergy.reaction}'),
        trailing: Chip(
          label: Text(allergy.severity),
          backgroundColor: _getSeverityColor(allergy.severity),
        ),
      ),
    );
  }

  Widget _buildMedicationCard(Medication medication) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.medication, color: Colors.blue),
        title: Text(medication.name),
        subtitle: Text('Dosis: ${medication.dose}'),
        trailing: Text(medication.frequency),
      ),
    );
  }

  String _getStatusText(ClinicalRecordStatus status) {
    switch (status) {
      case ClinicalRecordStatus.active:
        return 'Activa';
      case ClinicalRecordStatus.closed:
        return 'Cerrada';
      case ClinicalRecordStatus.archived:
        return 'Archivada';
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'alta':
      case 'high':
        return Colors.red.withOpacity(0.2);
      case 'media':
      case 'medium':
        return Colors.orange.withOpacity(0.2);
      case 'baja':
      case 'low':
        return Colors.yellow.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }
}
