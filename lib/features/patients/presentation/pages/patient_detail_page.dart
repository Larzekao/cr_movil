import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';
import '../bloc/patient_state.dart';
import '../../domain/entities/patient_entity.dart';
import 'patient_form_page.dart';

class PatientDetailPage extends StatefulWidget {
  final String patientId;

  const PatientDetailPage({super.key, required this.patientId});

  @override
  State<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadPatient();
  }

  void _loadPatient() {
    context.read<PatientBloc>().add(
      GetPatientDetailRequested(widget.patientId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Paciente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(),
          ),
        ],
      ),
      body: BlocConsumer<PatientBloc, PatientState>(
        listener: (context, state) {
          if (state is PatientError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is PatientDeleted) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is PatientLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PatientDetailLoaded) {
            return _buildPatientDetail(state.patient);
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No se pudo cargar el paciente'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadPatient,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPatientDetail(PatientEntity patient) {
    // Obtener inicial de forma segura
    String getInitial() {
      if (patient.firstName.isNotEmpty) {
        return patient.firstName[0].toUpperCase();
      } else if (patient.fullName.isNotEmpty) {
        return patient.fullName[0].toUpperCase();
      }
      return '?';
    }

    return RefreshIndicator(
      onRefresh: () async => _loadPatient(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar y nombre
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: patient.gender == 'M'
                        ? Colors.blue
                        : Colors.pink,
                    child: Text(
                      getInitial(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    patient.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Información personal
            _buildSectionTitle('Información Personal'),
            _buildInfoCard([
              _buildInfoRow('Documento', patient.identityDocument, Icons.badge),
              _buildInfoRow(
                'Género',
                patient.gender == 'M' ? 'Masculino' : 'Femenino',
                Icons.person,
              ),
              _buildInfoRow(
                'Fecha de Nacimiento',
                DateFormat('dd/MM/yyyy').format(patient.dateOfBirth),
                Icons.cake,
              ),
              _buildInfoRow(
                'Edad',
                '${DateTime.now().year - patient.dateOfBirth.year} años',
                Icons.calendar_today,
              ),
            ]),

            const SizedBox(height: 24),

            // Información de contacto
            _buildSectionTitle('Información de Contacto'),
            _buildInfoCard([
              _buildInfoRow('Teléfono', patient.phone, Icons.phone),
              if (patient.email != null)
                _buildInfoRow('Email', patient.email!, Icons.email),
              if (patient.address != null)
                _buildInfoRow('Dirección', patient.address!, Icons.location_on),
            ]),

            const SizedBox(height: 24),

            // Contacto de emergencia
            if (patient.emergencyContactName != null ||
                patient.emergencyContactPhone != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Contacto de Emergencia'),
                  _buildInfoCard([
                    if (patient.emergencyContactName != null)
                      _buildInfoRow(
                        'Nombre',
                        patient.emergencyContactName!,
                        Icons.person_outline,
                      ),
                    if (patient.emergencyContactPhone != null)
                      _buildInfoRow(
                        'Teléfono',
                        patient.emergencyContactPhone!,
                        Icons.phone_outlined,
                      ),
                  ]),
                  const SizedBox(height: 24),
                ],
              ),

            // Información médica
            _buildSectionTitle('Información Médica'),
            _buildInfoCard([
              if (patient.bloodType != null)
                _buildInfoRow(
                  'Tipo de Sangre',
                  patient.bloodType!,
                  Icons.bloodtype,
                ),
              if (patient.allergies != null)
                _buildInfoRow(
                  'Alergias',
                  patient.allergies!,
                  Icons.warning_amber,
                ),
              if (patient.chronicConditions != null)
                _buildInfoRow(
                  'Condiciones Crónicas',
                  patient.chronicConditions!,
                  Icons.health_and_safety,
                ),
            ]),

            const SizedBox(height: 24),

            // Fechas
            _buildSectionTitle('Registro'),
            _buildInfoCard([
              _buildInfoRow(
                'Fecha de Registro',
                DateFormat('dd/MM/yyyy HH:mm').format(patient.createdAt),
                Icons.access_time,
              ),
              if (patient.updatedAt != null)
                _buildInfoRow(
                  'Última Actualización',
                  DateFormat('dd/MM/yyyy HH:mm').format(patient.updatedAt!),
                  Icons.update,
                ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit() async {
    final state = context.read<PatientBloc>().state;
    if (state is PatientDetailLoaded) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PatientFormPage(patient: state.patient),
        ),
      );
      _loadPatient();
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Paciente'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este paciente? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<PatientBloc>().add(
                DeletePatientRequested(widget.patientId),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
