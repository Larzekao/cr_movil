import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/clinical_record_entity.dart';
import '../bloc/clinical_record_bloc.dart';
import '../../../patients/presentation/bloc/patient_bloc.dart';
import '../../../patients/presentation/bloc/patient_event.dart';
import '../../../patients/presentation/bloc/patient_state.dart';
import '../../../patients/domain/entities/patient_entity.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/custom_button.dart';

class ClinicalRecordFormPage extends StatefulWidget {
  final String? clinicalRecordId;

  const ClinicalRecordFormPage({
    super.key,
    this.clinicalRecordId,
  });

  @override
  State<ClinicalRecordFormPage> createState() => _ClinicalRecordFormPageState();
}

class _ClinicalRecordFormPageState extends State<ClinicalRecordFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _bloodTypeController = TextEditingController();

  PatientEntity? _selectedPatient;
  bool _isLoading = false;
  bool _isEditMode = false;
  ClinicalRecordEntity? _currentRecord;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.clinicalRecordId != null;

    if (_isEditMode) {
      context.read<ClinicalRecordBloc>().add(
            GetClinicalRecordDetailEvent(widget.clinicalRecordId!),
          );
    } else {
      context.read<PatientBloc>().add(const GetPatientsRequested());
    }
  }

  @override
  void dispose() {
    _bloodTypeController.dispose();
    super.dispose();
  }

  void _loadRecordData(ClinicalRecordEntity record) {
    setState(() {
      _currentRecord = record;
      _bloodTypeController.text = record.bloodType ?? '';
    });
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      if (!_isEditMode && _selectedPatient == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor seleccione un paciente'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final data = {
        'patient': _isEditMode ? _currentRecord!.patientId : _selectedPatient!.id,
        if (_bloodTypeController.text.trim().isNotEmpty)
          'blood_type': _bloodTypeController.text.trim(),
        'allergies': [],
        'chronic_conditions': [],
        'medications': [],
      };

      if (_isEditMode) {
        context.read<ClinicalRecordBloc>().add(
              UpdateClinicalRecordEvent(
                id: widget.clinicalRecordId!,
                data: data,
              ),
            );
      } else {
        context.read<ClinicalRecordBloc>().add(
              CreateClinicalRecordEvent(data),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode
            ? 'Editar Historia Clínica'
            : 'Nueva Historia Clínica'),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ClinicalRecordBloc, ClinicalRecordState>(
            listener: (context, state) {
              if (state is ClinicalRecordLoading) {
                setState(() => _isLoading = true);
              } else if (state is ClinicalRecordDetailLoaded) {
                setState(() => _isLoading = false);
                _loadRecordData(state.record);
              } else if (state is ClinicalRecordCreated) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Historia clínica creada exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              } else if (state is ClinicalRecordUpdated) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Historia clínica actualizada exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              } else if (state is ClinicalRecordError) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: _isLoading
            ? const LoadingWidget()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_isEditMode) _buildPatientSelector(),
                      if (_isEditMode && _currentRecord?.patientInfo != null)
                        _buildPatientInfo(),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _bloodTypeController,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Sangre',
                          hintText: 'Ej: O+, A-, etc.',
                          prefixIcon: Icon(Icons.bloodtype),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 32),
                      CustomButton(
                        text: _isEditMode ? 'Actualizar' : 'Crear Historia Clínica',
                        onPressed: _saveForm,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildPatientSelector() {
    return BlocBuilder<PatientBloc, PatientState>(
      builder: (context, state) {
        if (state is PatientsLoaded) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Seleccionar Paciente',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<PatientEntity>(
                    decoration: const InputDecoration(
                      hintText: 'Seleccione un paciente',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    items: state.patients.map((patient) {
                      return DropdownMenuItem(
                        value: patient,
                        child: Text(patient.fullName),
                      );
                    }).toList(),
                    onChanged: (patient) {
                      setState(() => _selectedPatient = patient);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor seleccione un paciente';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          );
        }
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Cargando pacientes...'),
          ),
        );
      },
    );
  }

  Widget _buildPatientInfo() {
    final patient = _currentRecord!.patientInfo!;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(patient.fullName),
        subtitle: Text('ID: ${patient.identification}'),
      ),
    );
  }
}
