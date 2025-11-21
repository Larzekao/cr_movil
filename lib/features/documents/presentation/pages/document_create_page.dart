import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../clinical_records/domain/entities/clinical_record_entity.dart';
import '../../../clinical_records/presentation/bloc/clinical_record_bloc.dart';

/// Página para crear un nuevo documento
///
/// Flujo:
/// 1. Usuario selecciona una historia clínica
/// 2. Se abre la cámara para capturar fotos
/// 3. Se redirige a DocumentUploadPage con las fotos
class DocumentCreatePage extends StatefulWidget {
  const DocumentCreatePage({super.key});

  @override
  State<DocumentCreatePage> createState() => _DocumentCreatePageState();
}

class _DocumentCreatePageState extends State<DocumentCreatePage> {
  ClinicalRecordEntity? _selectedClinicalRecord;
  bool _isLoading = false;
  List<ClinicalRecordEntity> _clinicalRecords = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadClinicalRecords();
  }

  void _loadClinicalRecords() {
    context.read<ClinicalRecordBloc>().add(GetClinicalRecordsEvent());
  }

  void _onClinicalRecordSelected(ClinicalRecordEntity record) {
    setState(() {
      _selectedClinicalRecord = record;
    });
  }

  Future<void> _openCamera() async {
    if (_selectedClinicalRecord == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una historia clínica primero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Navegar a la cámara
    final result = await Navigator.pushNamed(
      context,
      '/document-camera',
      arguments: {'clinicalRecordId': _selectedClinicalRecord!.id},
    );

    // Si hay fotos capturadas, ir a upload
    if (result != null && result is List<XFile>) {
      if (mounted) {
        final uploadResult = await Navigator.pushNamed(
          context,
          '/document-upload',
          arguments: {
            'clinicalRecordId': _selectedClinicalRecord!.id,
            'capturedFiles': result,
            'patientName': _selectedClinicalRecord!.patientName,
            'patientIdentification':
                _selectedClinicalRecord!.patientInfo?.identification,
          },
        );

        // Si se subió exitosamente, volver a la pantalla anterior
        if (uploadResult == true && mounted) {
          Navigator.pop(context, true);
        }
      }
    }
  }

  List<ClinicalRecordEntity> get _filteredRecords {
    if (_searchQuery.isEmpty) {
      return _clinicalRecords;
    }
    return _clinicalRecords.where((record) {
      final searchLower = _searchQuery.toLowerCase();
      return record.recordNumber.toLowerCase().contains(searchLower) ||
          (record.patientName.toLowerCase().contains(searchLower)) ||
          (record.patientInfo?.identification.toLowerCase().contains(
                searchLower,
              ) ??
              false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Documento'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<ClinicalRecordBloc, ClinicalRecordState>(
        listener: (context, state) {
          if (state is ClinicalRecordsLoaded) {
            setState(() {
              _clinicalRecords = state.records;
              _isLoading = false;
            });
          } else if (state is ClinicalRecordLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is ClinicalRecordError) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Instrucciones
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: AppColors.primary.withValues(alpha: 0.1),
                child: Column(
                  children: [
                    Icon(Icons.camera_alt, size: 48, color: AppColors.primary),
                    const SizedBox(height: 8),
                    Text(
                      'Selecciona una Historia Clínica',
                      style: AppTextStyles.h3,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Luego podrás capturar fotos con la cámara',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Buscador
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por paciente, cédula o número...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              // Historia clínica seleccionada
              if (_selectedClinicalRecord != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.secondary),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.secondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Seleccionado',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              _selectedClinicalRecord!.patientName,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _selectedClinicalRecord!.recordNumber,
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedClinicalRecord = null;
                          });
                        },
                        child: const Text('Cambiar'),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // Lista de historias clínicas
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredRecords.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay historias clínicas',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _loadClinicalRecords,
                              child: const Text('Recargar'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredRecords.length,
                        itemBuilder: (context, index) {
                          final record = _filteredRecords[index];
                          final isSelected =
                              _selectedClinicalRecord?.id == record.id;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.secondary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isSelected
                                    ? AppColors.secondary
                                    : AppColors.primary.withValues(alpha: 0.1),
                                child: Icon(
                                  isSelected ? Icons.check : Icons.person,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.primary,
                                ),
                              ),
                              title: Text(
                                record.patientName,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(record.recordNumber),
                                  if (record.patientInfo?.identification !=
                                      null)
                                    Text(
                                      'CI: ${record.patientInfo!.identification}',
                                    ),
                                ],
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              onTap: () => _onClinicalRecordSelected(record),
                            ),
                          );
                        },
                      ),
              ),

              // Botón de continuar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _selectedClinicalRecord != null
                          ? _openCamera
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text(
                        'Abrir Cámara',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
