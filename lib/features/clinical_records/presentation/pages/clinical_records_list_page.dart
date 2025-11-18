import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/clinical_record_entity.dart';
import '../bloc/clinical_record_bloc.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as custom;

class ClinicalRecordsListPage extends StatefulWidget {
  const ClinicalRecordsListPage({Key? key}) : super(key: key);

  @override
  State<ClinicalRecordsListPage> createState() => _ClinicalRecordsListPageState();
}

class _ClinicalRecordsListPageState extends State<ClinicalRecordsListPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Cargar historias clínicas al iniciar
    _loadClinicalRecords();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _loadClinicalRecords() {
    context.read<ClinicalRecordBloc>().add(GetClinicalRecordsEvent());
  }

  void _onSearch(String query) {
    // Actualizar UI para mostrar/ocultar el botón de limpiar
    setState(() {});

    // Cancelar el timer anterior si existe
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Crear nuevo timer con delay de 500ms
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<ClinicalRecordBloc>().add(
        GetClinicalRecordsEvent(search: query.isEmpty ? null : query),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historias Clínicas'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por paciente o número...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                          _loadClinicalRecords();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _onSearch,
            ),
          ),
        ),
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
          } else if (state is ClinicalRecordDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Historia clínica eliminada exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            // Recargar la lista
            context.read<ClinicalRecordBloc>().add(GetClinicalRecordsEvent());
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
                context.read<ClinicalRecordBloc>().add(GetClinicalRecordsEvent());
              },
            );
          }

          if (state is ClinicalRecordsLoaded) {
            if (state.records.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_off_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay historias clínicas',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Presiona el botón + para crear una',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ClinicalRecordBloc>().add(GetClinicalRecordsEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: state.records.length,
                itemBuilder: (context, index) {
                  final record = state.records[index];
                  return _ClinicalRecordCard(
                    record: record,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/clinical-record-detail',
                        arguments: record.id,
                      );
                    },
                    onDelete: () => _confirmDelete(context, record),
                  );
                },
              ),
            );
          }

          return const Center(
            child: Text('Cargando historias clínicas...'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/clinical-record-create');
        },
        child: const Icon(Icons.add),
        tooltip: 'Nueva Historia Clínica',
      ),
    );
  }

  void _confirmDelete(BuildContext context, ClinicalRecordEntity record) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Está seguro de eliminar la historia clínica ${record.recordNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ClinicalRecordBloc>().add(
                DeleteClinicalRecordEvent(record.id),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _ClinicalRecordCard extends StatelessWidget {
  final ClinicalRecordEntity record;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ClinicalRecordCard({
    required this.record,
    required this.onTap,
    required this.onDelete,
  });

  Color _getStatusColor() {
    switch (record.status) {
      case ClinicalRecordStatus.active:
        return Colors.green;
      case ClinicalRecordStatus.closed:
        return Colors.orange;
      case ClinicalRecordStatus.archived:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (record.status) {
      case ClinicalRecordStatus.active:
        return 'Activa';
      case ClinicalRecordStatus.closed:
        return 'Cerrada';
      case ClinicalRecordStatus.archived:
        return 'Archivada';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.folder_copy_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'HC ${record.recordNumber}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            record.patientName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (record.patientInfo != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.badge, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            record.patientInfo!.identification,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.description, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${record.documentsCount} documento${record.documentsCount != 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        if (record.bloodType != null) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.bloodtype, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            record.bloodType!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
