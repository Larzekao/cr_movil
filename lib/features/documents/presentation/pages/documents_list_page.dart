import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/dependency_injection/injection_container.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as custom;
import '../bloc/document_bloc.dart';
import '../bloc/document_event.dart';
import '../bloc/document_state.dart';
import '../../domain/entities/document_entity.dart';
import 'document_detail_page.dart';

class DocumentsListPage extends StatelessWidget {
  final String? clinicalRecordId;
  final String? patientName;

  const DocumentsListPage({super.key, this.clinicalRecordId, this.patientName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<DocumentBloc>()
            ..add(LoadDocuments(clinicalRecordId: clinicalRecordId)),
      child: _DocumentsListView(
        clinicalRecordId: clinicalRecordId,
        patientName: patientName,
      ),
    );
  }
}

class _DocumentsListView extends StatefulWidget {
  final String? clinicalRecordId;
  final String? patientName;

  const _DocumentsListView({this.clinicalRecordId, this.patientName});

  @override
  State<_DocumentsListView> createState() => _DocumentsListViewState();
}

class _DocumentsListViewState extends State<_DocumentsListView> {
  String? _selectedType;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  final List<Map<String, String>> _documentTypes = [
    {'value': 'consultation', 'label': 'Consulta'},
    {'value': 'lab_result', 'label': 'Resultado de Laboratorio'},
    {'value': 'imaging_report', 'label': 'Informe de Imagen'},
    {'value': 'prescription', 'label': 'Receta'},
    {'value': 'surgical_note', 'label': 'Nota Quirúrgica'},
    {'value': 'discharge_summary', 'label': 'Resumen de Alta'},
    {'value': 'consent_form', 'label': 'Consentimiento Informado'},
    {'value': 'progress_note', 'label': 'Nota de Evolución'},
    {'value': 'referral', 'label': 'Referencia'},
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onFilterChanged(String? type) {
    setState(() {
      _selectedType = type;
    });
    context.read<DocumentBloc>().add(
      LoadDocuments(
        clinicalRecordId: widget.clinicalRecordId,
        documentType: type,
        search: _searchController.text.isEmpty ? null : _searchController.text,
      ),
    );
  }

  void _onSearch(String query) {
    // Actualizar UI para mostrar/ocultar el botón de limpiar
    setState(() {});

    // Cancelar el timer anterior si existe
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Crear nuevo timer con delay de 500ms
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<DocumentBloc>().add(
        LoadDocuments(
          clinicalRecordId: widget.clinicalRecordId,
          documentType: _selectedType,
          search: query.isEmpty ? null : query,
        ),
      );
    });
  }

  void _loadDocuments() {
    context.read<DocumentBloc>().add(
      LoadDocuments(
        clinicalRecordId: widget.clinicalRecordId,
        documentType: _selectedType,
        search: _searchController.text.isEmpty ? null : _searchController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.patientName != null
              ? 'Documentos de ${widget.patientName}'
              : 'Documentos',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDocuments,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por título o paciente...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                          _loadDocuments();
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

          // Filtro por tipo
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Filtrar por tipo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.filter_list),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Todos los tipos'),
                ),
                ..._documentTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type['value'],
                    child: Text(type['label']!),
                  );
                }),
              ],
              onChanged: _onFilterChanged,
            ),
          ),

          // Lista de documentos
          Expanded(
            child: BlocConsumer<DocumentBloc, DocumentState>(
              listener: (context, state) {
                if (state is DocumentError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is DocumentDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Documento eliminado'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Recargar lista
                  _loadDocuments();
                }
              },
              builder: (context, state) {
                if (state is DocumentLoading) {
                  return const LoadingWidget();
                }

                if (state is DocumentError) {
                  return custom.ErrorWidget(
                    message: state.message,
                    onRetry: _loadDocuments,
                  );
                }

                if (state is DocumentsLoaded) {
                  if (state.documents.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay documentos',
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
                    onRefresh: () async {
                      _loadDocuments();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.documents.length,
                      itemBuilder: (context, index) {
                        final document = state.documents[index];
                        return _DocumentCard(
                          document: document,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DocumentDetailPage(documentId: document.id),
                              ),
                            );
                          },
                          onDelete: () => _showDeleteDialog(context, document),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.clinicalRecordId != null
          ? FloatingActionButton.extended(
              onPressed: () {
                // TODO: Navegar a formulario
              },
              icon: const Icon(Icons.add),
              label: const Text('Nuevo Documento'),
            )
          : null,
    );
  }

  void _showDeleteDialog(BuildContext context, DocumentEntity document) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Documento'),
        content: Text(
          '¿Está seguro de que desea eliminar "${document.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<DocumentBloc>().add(DeleteDocument(document.id));
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final DocumentEntity document;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DocumentCard({
    required this.document,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Ícono según tipo
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTypeColor(
                        document.documentType,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(document.documentType),
                      color: _getTypeColor(document.documentType),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          document.documentTypeLabel,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!document.isLocked)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete,
                    ),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    document.patientName,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(document.documentDate),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              if (document.fileName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.attachment, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      document.fileName!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      document.formattedFileSize,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
              if (document.isSigned) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 16, color: Colors.green[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Firmado',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  IconData _getTypeIcon(String type) {
    const icons = {
      'consultation': Icons.medical_services,
      'lab_result': Icons.science,
      'imaging_report': Icons.image,
      'prescription': Icons.medication,
      'surgical_note': Icons.local_hospital,
      'discharge_summary': Icons.exit_to_app,
      'consent_form': Icons.assignment,
      'progress_note': Icons.timeline,
      'referral': Icons.send,
    };
    return icons[type] ?? Icons.description;
  }

  Color _getTypeColor(String type) {
    const colors = {
      'consultation': Colors.blue,
      'lab_result': Colors.purple,
      'imaging_report': Colors.orange,
      'prescription': Colors.green,
      'surgical_note': Colors.red,
      'discharge_summary': Colors.teal,
      'consent_form': Colors.indigo,
      'progress_note': Colors.amber,
      'referral': Colors.cyan,
    };
    return colors[type] ?? Colors.grey;
  }
}
