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

  // Controllers
  final _bloodTypeController = TextEditingController();
  final _familyHistoryController = TextEditingController();
  final _socialHistoryController = TextEditingController();

  // Listas dinámicas
  final List<Map<String, String>> _allergies = [];
  final List<String> _chronicConditions = [];
  final List<Map<String, String>> _medications = [];

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
    _familyHistoryController.dispose();
    _socialHistoryController.dispose();
    super.dispose();
  }

  void _loadRecordData(ClinicalRecordEntity record) {
    setState(() {
      _currentRecord = record;
      _bloodTypeController.text = record.bloodType ?? '';
      _familyHistoryController.text = record.familyHistory ?? '';
      _socialHistoryController.text = record.socialHistory ?? '';

      // Cargar alergias
      _allergies.clear();
      for (var allergy in record.allergies) {
        _allergies.add({
          'allergen': allergy.allergen,
          'severity': allergy.severity,
          'reaction': allergy.reaction,
        });
      }

      // Cargar condiciones crónicas
      _chronicConditions.clear();
      _chronicConditions.addAll(record.chronicConditions);

      // Cargar medicamentos
      _medications.clear();
      for (var med in record.medications) {
        _medications.add({
          'name': med.name,
          'dose': med.dose,
          'frequency': med.frequency,
        });
      }
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
        'allergies': _allergies,
        'chronic_conditions': _chronicConditions,
        'medications': _medications,
        if (_familyHistoryController.text.trim().isNotEmpty)
          'family_history': _familyHistoryController.text.trim(),
        if (_socialHistoryController.text.trim().isNotEmpty)
          'social_history': _socialHistoryController.text.trim(),
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
                      // Selector/Info de paciente
                      if (!_isEditMode) _buildPatientSelector(),
                      if (_isEditMode && _currentRecord?.patientInfo != null)
                        _buildPatientInfo(),

                      const SizedBox(height: 24),

                      // Tipo de sangre
                      TextFormField(
                        controller: _bloodTypeController,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Sangre',
                          hintText: 'Ej: O+, A-, AB+, etc.',
                          prefixIcon: Icon(Icons.bloodtype),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Alergias
                      _buildSection(
                        'Alergias',
                        Icons.warning_amber,
                        _allergies.isEmpty
                            ? const Text('No hay alergias registradas')
                            : Column(
                                children: _allergies.asMap().entries.map((e) {
                                  final allergy = e.value;
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      title: Text(allergy['allergen'] ?? ''),
                                      subtitle: Text(
                                        '${allergy['severity']} - ${allergy['reaction']}',
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          setState(() => _allergies.removeAt(e.key));
                                        },
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                        () => _addAllergy(),
                      ),

                      const SizedBox(height: 24),

                      // Condiciones crónicas
                      _buildSection(
                        'Condiciones Crónicas',
                        Icons.health_and_safety,
                        _chronicConditions.isEmpty
                            ? const Text('No hay condiciones crónicas')
                            : Column(
                                children: _chronicConditions.asMap().entries.map((e) {
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      title: Text(e.value),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          setState(() => _chronicConditions.removeAt(e.key));
                                        },
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                        () => _addChronicCondition(),
                      ),

                      const SizedBox(height: 24),

                      // Medicamentos
                      _buildSection(
                        'Medicamentos Actuales',
                        Icons.medication,
                        _medications.isEmpty
                            ? const Text('No hay medicamentos registrados')
                            : Column(
                                children: _medications.asMap().entries.map((e) {
                                  final med = e.value;
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      title: Text(med['name'] ?? ''),
                                      subtitle: Text(
                                        'Dosis: ${med['dose']} - ${med['frequency']}',
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          setState(() => _medications.removeAt(e.key));
                                        },
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                        () => _addMedication(),
                      ),

                      const SizedBox(height: 24),

                      // Historial familiar
                      TextFormField(
                        controller: _familyHistoryController,
                        decoration: const InputDecoration(
                          labelText: 'Historial Familiar',
                          hintText: 'Enfermedades hereditarias, antecedentes...',
                          prefixIcon: Icon(Icons.family_restroom),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                      ),

                      const SizedBox(height: 16),

                      // Historial social
                      TextFormField(
                        controller: _socialHistoryController,
                        decoration: const InputDecoration(
                          labelText: 'Historial Social',
                          hintText: 'Estilo de vida, hábitos, ocupación...',
                          prefixIcon: Icon(Icons.people),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                      ),

                      const SizedBox(height: 32),

                      // Botón guardar
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

  Widget _buildSection(
    String title,
    IconData icon,
    Widget child,
    VoidCallback onAdd,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  color: Theme.of(context).primaryColor,
                  onPressed: onAdd,
                ),
              ],
            ),
            const Divider(),
            child,
          ],
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

  // Diálogos para agregar items
  void _addAllergy() {
    final allergenController = TextEditingController();
    final reactionController = TextEditingController();
    String severity = 'Baja';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Agregar Alergia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: allergenController,
                decoration: const InputDecoration(labelText: 'Alérgeno'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: severity,
                decoration: const InputDecoration(labelText: 'Severidad'),
                items: ['Baja', 'Media', 'Alta'].map((s) {
                  return DropdownMenuItem(value: s, child: Text(s));
                }).toList(),
                onChanged: (val) => setDialogState(() => severity = val!),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reactionController,
                decoration: const InputDecoration(labelText: 'Reacción'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (allergenController.text.isNotEmpty) {
                  setState(() {
                    _allergies.add({
                      'allergen': allergenController.text,
                      'severity': severity,
                      'reaction': reactionController.text,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _addChronicCondition() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar Condición Crónica'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Condición'),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => _chronicConditions.add(controller.text));
                Navigator.pop(context);
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _addMedication() {
    final nameController = TextEditingController();
    final doseController = TextEditingController();
    final frequencyController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar Medicamento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: doseController,
              decoration: const InputDecoration(labelText: 'Dosis'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: frequencyController,
              decoration: const InputDecoration(labelText: 'Frecuencia'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  _medications.add({
                    'name': nameController.text,
                    'dose': doseController.text,
                    'frequency': frequencyController.text,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}
