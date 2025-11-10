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
  late final TextEditingController _cityController;
  late final TextEditingController _emergencyNameController;
  late final TextEditingController _emergencyRelationshipController;
  late final TextEditingController _emergencyPhoneController;

  DateTime? _dateOfBirth;
  String _gender = 'M';
  String _identityDocumentType = 'CI';

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
    _cityController = TextEditingController(text: widget.patient?.city ?? '');

    // Emergency contact - extraer del Map
    final emergencyContact = widget.patient?.emergencyContact;
    _emergencyNameController = TextEditingController(
      text: emergencyContact?['name']?.toString() ?? '',
    );
    _emergencyRelationshipController = TextEditingController(
      text: emergencyContact?['relationship']?.toString() ?? '',
    );
    _emergencyPhoneController = TextEditingController(
      text: emergencyContact?['phone']?.toString() ?? '',
    );

    _dateOfBirth = widget.patient?.dateOfBirth;
    _gender = widget.patient?.gender ?? 'M';
    _identityDocumentType = widget.patient?.identityDocumentType ?? 'CI';
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
                content: Text('✅ Paciente creado exitosamente'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
            Navigator.pop(context, true);
          } else if (state is PatientUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Paciente actualizado exitosamente'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
            Navigator.pop(context, true);
          } else if (state is PatientDuplicateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Colors.orange[800],
                duration: const Duration(seconds: 5),
              ),
            );
          } else if (state is PatientError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
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

                  // Tipo de documento
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.credit_card, color: Colors.grey),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _identityDocumentType,
                            decoration: const InputDecoration(
                              labelText: 'Tipo de Documento',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'CI',
                                child: Text('Cédula de Identidad'),
                              ),
                              DropdownMenuItem(
                                value: 'Pasaporte',
                                child: Text('Pasaporte'),
                              ),
                              DropdownMenuItem(
                                value: 'DNI',
                                child: Text('DNI'),
                              ),
                              DropdownMenuItem(
                                value: 'RUT',
                                child: Text('RUT'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _identityDocumentType = value ?? 'CI';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildTextField(
                    controller: _identityDocumentController,
                    label: 'Número de Documento',
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
                  _buildTextField(
                    controller: _cityController,
                    label: 'Ciudad (opcional)',
                    icon: Icons.location_city,
                  ),

                  const SizedBox(height: 24),

                  // Contacto de emergencia
                  _buildSectionTitle('Contacto de Emergencia (opcional)'),
                  _buildTextField(
                    controller: _emergencyNameController,
                    label: 'Nombre',
                    icon: Icons.person_outline,
                  ),
                  _buildTextField(
                    controller: _emergencyRelationshipController,
                    label: 'Relación',
                    icon: Icons.family_restroom,
                    hint: 'Ej: Madre, Padre, Hermano/a, Esposo/a',
                  ),
                  _buildTextField(
                    controller: _emergencyPhoneController,
                    label: 'Teléfono',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
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
      final Map<String, dynamic> patientData = {
        'identity_document_type': _identityDocumentType,
        'identity_document': _identityDocumentController.text,
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'date_of_birth': DateFormat('yyyy-MM-dd').format(_dateOfBirth!),
        'gender': _gender,
        'phone': _phoneController.text,
        if (_emailController.text.isNotEmpty) 'email': _emailController.text,
        if (_addressController.text.isNotEmpty)
          'address': _addressController.text,
        if (_cityController.text.isNotEmpty) 'city': _cityController.text,
      };

      // Agregar emergency_contact solo si hay datos
      if (_emergencyNameController.text.isNotEmpty ||
          _emergencyRelationshipController.text.isNotEmpty ||
          _emergencyPhoneController.text.isNotEmpty) {
        patientData['emergency_contact'] = {
          'name': _emergencyNameController.text,
          'relationship': _emergencyRelationshipController.text,
          'phone': _emergencyPhoneController.text,
        };
      }

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
    _cityController.dispose();
    _emergencyNameController.dispose();
    _emergencyRelationshipController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }
}
