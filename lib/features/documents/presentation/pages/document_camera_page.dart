import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import '../../../../core/theme/app_colors.dart';

/// Pantalla para capturar documentos clínicos con cámara
///
/// Funcionalidades:
/// - Captura de fotos con cámara
/// - Control de flash
/// - Galería de miniaturas de fotos capturadas
/// - Permisos de cámara gestionados
class DocumentCameraPage extends StatefulWidget {
  final String? clinicalRecordId;

  const DocumentCameraPage({this.clinicalRecordId});

  @override
  State<DocumentCameraPage> createState() => _DocumentCameraPageState();
}

class _DocumentCameraPageState extends State<DocumentCameraPage> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;

  List<XFile> capturedFiles = [];
  bool _flashEnabled = false;
  bool _cameraInitialized = false;
  bool _permissionDenied = false;

  final Logger _logger = Logger();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  /// Inicializar cámara con permisos
  Future<void> _initializeCamera() async {
    try {
      // Solicitar permiso de cámara
      final PermissionStatus status = await Permission.camera.request();

      if (status.isDenied) {
        setState(() => _permissionDenied = true);
        _logger.w('Permiso de cámara denegado');
        return;
      }

      if (status.isPermanentlyDenied) {
        setState(() => _permissionDenied = true);
        _logger.w('Permiso de cámara permanentemente denegado');
        return;
      }

      // Obtener cámaras disponibles
      final List<CameraDescription> cameras = await availableCameras();
      if (cameras.isEmpty) {
        _logger.e('No hay cámaras disponibles');
        return;
      }

      // Usar cámara trasera
      final CameraDescription rearCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras[0],
      );

      // Inicializar controlador
      _cameraController = CameraController(
        rearCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _initializeControllerFuture = _cameraController.initialize();

      _initializeControllerFuture
          .then((_) {
            if (mounted) {
              setState(() => _cameraInitialized = true);
            }
          })
          .catchError((e) {
            _logger.e('Error inicializando cámara: $e');
          });
    } catch (e) {
      _logger.e('Error en inicialización de cámara: $e');
    }
  }

  /// Capturar foto con cámara
  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;

      final XFile photo = await _cameraController.takePicture();

      setState(() {
        capturedFiles.add(photo);
      });

      _logger.i('Foto capturada: ${photo.name}');

      // Mostrar confirmación visual
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto capturada exitosamente'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      _logger.e('Error al capturar foto: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al capturar foto: $e')));
      }
    }
  }

  /// Alternar flash
  Future<void> _toggleFlash() async {
    try {
      if (_flashEnabled) {
        await _cameraController.setFlashMode(FlashMode.off);
        setState(() => _flashEnabled = false);
      } else {
        await _cameraController.setFlashMode(FlashMode.torch);
        setState(() => _flashEnabled = true);
      }
    } catch (e) {
      _logger.e('Error al cambiar flash: $e');
    }
  }

  /// Seleccionar foto de la galería
  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => capturedFiles.add(image));
        _logger.i('Imagen seleccionada de galería: ${image.name}');
      }
    } catch (e) {
      _logger.e('Error al seleccionar de galería: $e');
    }
  }

  /// Eliminar foto de la lista
  void _removePhoto(int index) {
    setState(() {
      capturedFiles.removeAt(index);
    });
    _logger.i('Foto eliminada del índice: $index');
  }

  /// Mostrar preview de foto en grande
  void _showPhotoPreview(int index) {
    showDialog(
      context: context,
      builder: (context) => PhotoPreviewDialog(file: capturedFiles[index]),
    );
  }

  /// Abrir ajustes para habilitar cámara
  void _openAppSettings() {
    openAppSettings();
  }

  /// Continuar a la siguiente pantalla con fotos capturadas
  void _continueToUpload() {
    if (capturedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Captura al menos una foto antes de continuar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Retornar lista de archivos capturados
    Navigator.pop(context, capturedFiles);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si permiso es permanentemente denegado
    if (_permissionDenied) {
      return Scaffold(
        appBar: AppBar(title: const Text('Capturar Documento')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam_off, size: 64, color: AppColors.error),
              const SizedBox(height: 24),
              const Text(
                'Permiso de Cámara Denegado',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Para usar la cámara, habilita el permiso en ajustes',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _openAppSettings,
                child: const Text('Ir a Ajustes'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Capturar Documento'), elevation: 0),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              _cameraInitialized) {
            return Stack(
              children: [
                // Vista previa de cámara
                CameraPreview(_cameraController),

                // Controles superpuestos
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: _toggleFlash,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _flashEnabled
                            ? AppColors.warning
                            : Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _flashEnabled ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Botón de captura (centro inferior)
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _takePicture,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          color: AppColors.primary.withOpacity(0.9),
                        ),
                        child: const Icon(
                          Icons.camera,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),

                // Galería de miniaturas (abajo, con transición)
                Positioned(
                  bottom: 110,
                  left: 0,
                  right: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: capturedFiles.isEmpty ? 0 : 120,
                    color: Colors.black54,
                    child: capturedFiles.isEmpty
                        ? null
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            child: Row(
                              children: List.generate(
                                capturedFiles.length,
                                (index) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _buildPhotoThumbnail(index),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),

                // Botón de galería (abajo izquierda)
                Positioned(
                  bottom: 24,
                  left: 24,
                  child: GestureDetector(
                    onTap: _pickFromGallery,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.image,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),

                // Botón de continuar (arriba derecha, si hay fotos)
                if (capturedFiles.isNotEmpty)
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: GestureDetector(
                      onTap: _continueToUpload,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${capturedFiles.length} Fotos',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  /// Construir miniatura de foto
  Widget _buildPhotoThumbnail(int index) {
    return GestureDetector(
      onTap: () => _showPhotoPreview(index),
      onLongPress: () => _removePhoto(index),
      child: Stack(
        children: [
          // Imagen miniatura
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(capturedFiles[index].path),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          // Número de foto
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog para ver preview de foto en grande
class PhotoPreviewDialog extends StatelessWidget {
  final XFile file;

  const PhotoPreviewDialog({required this.file});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            title: const Text('Vista Previa'),
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Expanded(child: Image.file(File(file.path), fit: BoxFit.contain)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    file.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
