import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';
import '../bloc/patient_state.dart';
import '../../domain/entities/patient_entity.dart';

class PatientFormPage extends StatefulWidget {
  final PatientEntity? patient; // null = crear, no-null = editar

  const PatientFormPage({super.key, this.patient});

  @override
  State<PatientFormPage> createState() => _PatientFormPageState();
}

class _PatientFormPageState extends State<PatientFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _identityDocumentController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _emergencyNameController;
  late final TextEditingController _emergencyPhoneController;
  late final TextEditingController _bloodTypeController;
  late final TextEditingController _allergiesController;
  late final TextEditingController _chronicConditionsController;

  DateTime? _dateOfBirth;
  String _gender = 'M';

  bool get isEditing => widget.patient != null;

  @override
  void initState() {
    super.initState();

    // Inicializar controllers
    _identityDocumentController = TextEditingController(
      text: widget.patient?.identityDocument ?? '',
    );
    _firstNameController = TextEditingController(
      text: widget.patient?.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.patient?.lastName ?? '',
    );
    _phoneController = TextEditingController(text: widget.patient?.phone ?? '');
    _emailController = TextEditingController(text: widget.patient?.email ?? '');
    _addressController = TextEditingController(
      text: widget.patient?.address ?? '',
    );
    _emergencyNameController = TextEditingController(
      text: widget.patient?.emergencyContactName ?? '',
    );
    _emergencyPhoneController = TextEditingController(
      text: widget.patient?.emergencyContactPhone ?? '',
    );
    _bloodTypeController = TextEditingController(
      text: widget.patient?.bloodType ?? '',
    );
    _allergiesController = TextEditingController(
      text: widget.patient?.allergies ?? '',
    );
    _chronicConditionsController = TextEditingController(
      text: widget.patient?.chronicConditions ?? '',
    );

    _dateOfBirth = widget.patient?.dateOfBirth;
    _gender = widget.patient?.gender ?? 'M';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Paciente' : 'Nuevo Paciente'),
      ),
      body: BlocConsumer<PatientBloc, PatientState>(
        listener: (context, state) {
          if (state is PatientCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Paciente creado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is PatientUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Paciente actualizado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is PatientError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is PatientLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información personal
                  _buildSectionTitle('Información Personal'),
                  _buildTextField(
                    controller: _identityDocumentController,
                    label: 'Documento de Identidad',
                    icon: Icons.badge,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo requerido';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _firstNameController,
                    label: 'Nombre',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo requerido';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _lastNameController,
                    label: 'Apellido',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo requerido';
                      }
                      return null;
                    },
                  ),

                  // Fecha de nacimiento
                  ListTile(
                    leading: const Icon(Icons.cake),
                    title: Text(
                      _dateOfBirth != null
                          ? 'Fecha de Nacimiento: ${DateFormat('dd/MM/yyyy').format(_dateOfBirth!)}'
                          : 'Seleccionar Fecha de Nacimiento',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(),
                  ),
                  if (_dateOfBirth == null)
                    Padding(
                      padding: const EdgeInsets.only(left: 72, bottom: 8),
                      child: Text(
                        'Campo requerido',
                        style: TextStyle(color: Colors.red[700], fontSize: 12),
                      ),
                    ),

                  // Género
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.people, color: Colors.grey),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _gender,
                            decoration: const InputDecoration(
                              labelText: 'Género',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'M',
                                child: Text('Masculino'),
                              ),
                              DropdownMenuItem(
                                value: 'F',
                                child: Text('Femenino'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _gender = value ?? 'M';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Información de contacto
                  _buildSectionTitle('Información de Contacto'),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Teléfono',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo requerido';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email (opcional)',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Dirección (opcional)',
                    icon: Icons.location_on,
                    maxLines: 2,
                  ),

                  const SizedBox(height: 24),

                  // Contacto de emergencia
                  _buildSectionTitle('Contacto de Emergencia'),
                  _buildTextField(
                    controller: _emergencyNameController,
                    label: 'Nombre (opcional)',
                    icon: Icons.person_outline,
                  ),
                  _buildTextField(
                    controller: _emergencyPhoneController,
                    label: 'Teléfono (opcional)',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 24),

                  // Información médica
                  _buildSectionTitle('Información Médica'),
                  _buildTextField(
                    controller: _bloodTypeController,
                    label: 'Tipo de Sangre (opcional)',
                    icon: Icons.bloodtype,
                    hint: 'Ej: O+, A-, AB+',
                  ),
                  _buildTextField(
                    controller: _allergiesController,
                    label: 'Alergias (opcional)',
                    icon: Icons.warning_amber,
                    maxLines: 3,
                  ),
                  _buildTextField(
                    controller: _chronicConditionsController,
                    label: 'Condiciones Crónicas (opcional)',
                    icon: Icons.health_and_safety,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 32),

                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _savePatient,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(isEditing ? 'Actualizar' : 'Crear'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  void _savePatient() {
    if (_formKey.currentState!.validate() && _dateOfBirth != null) {
      final patientData = {
        'identity_document': _identityDocumentController.text,
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'date_of_birth': DateFormat('yyyy-MM-dd').format(_dateOfBirth!),
        'gender': _gender,
        'phone': _phoneController.text,
        if (_emailController.text.isNotEmpty) 'email': _emailController.text,
        if (_addressController.text.isNotEmpty)
          'address': _addressController.text,
        if (_emergencyNameController.text.isNotEmpty)
          'emergency_contact_name': _emergencyNameController.text,
        if (_emergencyPhoneController.text.isNotEmpty)
          'emergency_contact_phone': _emergencyPhoneController.text,
        if (_bloodTypeController.text.isNotEmpty)
          'blood_type': _bloodTypeController.text,
        if (_allergiesController.text.isNotEmpty)
          'allergies': _allergiesController.text,
        if (_chronicConditionsController.text.isNotEmpty)
          'chronic_conditions': _chronicConditionsController.text,
      };

      if (isEditing) {
        context.read<PatientBloc>().add(
          UpdatePatientRequested(widget.patient!.id, patientData),
        );
      } else {
        context.read<PatientBloc>().add(CreatePatientRequested(patientData));
      }
    } else if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una fecha de nacimiento'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _identityDocumentController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _chronicConditionsController.dispose();
    super.dispose();
  }
}
