import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';
import '../bloc/patient_state.dart';
import '../../domain/entities/patient_entity.dart';
import 'patient_detail_page.dart';
import 'patient_form_page.dart';

class PatientsListPage extends StatefulWidget {
  const PatientsListPage({super.key});

  @override
  State<PatientsListPage> createState() => _PatientsListPageState();
}

class _PatientsListPageState extends State<PatientsListPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  void _loadPatients() {
    context.read<PatientBloc>().add(const GetPatientsRequested());
  }

  void _searchPatients(String query) {
    // Cancelar el timer anterior si existe
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Crear nuevo timer con delay de 500ms
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        _loadPatients();
      } else {
        context.read<PatientBloc>().add(SearchPatientsRequested(query));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadPatients),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o documento...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadPatients();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _searchPatients,
            ),
          ),

          // Lista de pacientes
          Expanded(
            child: BlocConsumer<PatientBloc, PatientState>(
              listener: (context, state) {
                if (state is PatientError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is PatientDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Paciente eliminado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadPatients();
                }
              },
              builder: (context, state) {
                if (state is PatientLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is PatientsLoaded) {
                  if (state.patients.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay pacientes registrados',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadPatients(),
                    child: ListView.builder(
                      itemCount: state.patients.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final patient = state.patients[index];
                        return _PatientCard(
                          patient: patient,
                          onTap: () => _navigateToDetail(patient),
                        );
                      },
                    ),
                  );
                }

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Carga la lista de pacientes',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPatients,
                        child: const Text('Cargar Pacientes'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreate(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToDetail(PatientEntity patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<PatientBloc>(),
          child: PatientDetailPage(patientId: patient.id),
        ),
      ),
    ).then((_) => _loadPatients());
  }

  void _navigateToCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<PatientBloc>(),
          child: const PatientFormPage(),
        ),
      ),
    ).then((_) => _loadPatients());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}

class _PatientCard extends StatelessWidget {
  final PatientEntity patient;
  final VoidCallback onTap;

  const _PatientCard({required this.patient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Obtener inicial de forma segura
    String getInitial() {
      if (patient.firstName.isNotEmpty) {
        return patient.firstName[0].toUpperCase();
      } else if (patient.fullName.isNotEmpty) {
        return patient.fullName[0].toUpperCase();
      }
      return '?';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: patient.gender == 'M' ? Colors.blue : Colors.pink,
          child: Text(
            getInitial(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          patient.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Doc: ${patient.identityDocument}'),
            Text('Tel: ${patient.phone}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
