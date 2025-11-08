# Módulo de Historias Clínicas - CliniDocs Mobile

## 📋 Descripción

El módulo de **Historias Clínicas** permite a los doctores registrar, ver, editar y eliminar historias clínicas de los pacientes. Implementa un CRUD completo con Clean Architecture y BLoC pattern.

## 🎯 Funcionalidades Implementadas

### ✅ CRUD Completo
- **Crear** nueva historia clínica para un paciente
- **Leer** lista de historias clínicas (con búsqueda)
- **Leer** detalle completo de una historia clínica
- **Actualizar** historia clínica existente
- **Eliminar** historia clínica (con confirmación)

### ✅ Características Adicionales
- Búsqueda en tiempo real por diagnóstico, tratamiento, etc.
- Filtrado por paciente específico
- Navegación fluida entre lista, detalle y formulario
- Validación de formularios
- Manejo de errores con mensajes amigables
- Pull-to-refresh en la lista
- Diseño responsivo y Material Design

## 📁 Estructura de Archivos

```
lib/features/clinical_records/
├── data/
│   ├── datasources/
│   │   └── clinical_record_remote_datasource.dart
│   ├── models/
│   │   ├── clinical_record_model.dart
│   │   └── clinical_record_model.g.dart (generado)
│   └── repositories/
│       └── clinical_record_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   └── clinical_record_entity.dart
│   ├── repositories/
│   │   └── clinical_record_repository.dart
│   └── usecases/
│       ├── get_clinical_records_usecase.dart
│       ├── get_clinical_record_detail_usecase.dart
│       ├── create_clinical_record_usecase.dart
│       ├── update_clinical_record_usecase.dart
│       └── delete_clinical_record_usecase.dart
│
└── presentation/
    ├── bloc/
    │   ├── clinical_record_bloc.dart
    │   ├── clinical_record_event.dart
    │   └── clinical_record_state.dart
    └── pages/
        ├── clinical_records_list_page.dart
        ├── clinical_record_detail_page.dart
        └── clinical_record_form_page.dart
```

## 🔌 Endpoints del Backend

El módulo se conecta a los siguientes endpoints:

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/api/clinical-records/` | GET | Listar historias clínicas |
| `/api/clinical-records/` | POST | Crear historia clínica |
| `/api/clinical-records/{id}/` | GET | Obtener detalle |
| `/api/clinical-records/{id}/` | PUT | Actualizar historia |
| `/api/clinical-records/{id}/` | DELETE | Eliminar historia |

### Parámetros de Búsqueda (GET)
- `page`: Número de página (paginación)
- `page_size`: Cantidad de resultados por página
- `search`: Búsqueda por texto (diagnóstico, tratamiento, etc.)
- `patient`: Filtrar por ID de paciente

## 📝 Modelo de Datos

### ClinicalRecordEntity

```dart
class ClinicalRecordEntity {
  final String id;                    // ID único
  final String patientId;             // ID del paciente
  final String patientName;           // Nombre del paciente
  final String? chiefComplaint;       // Motivo de consulta
  final String? diagnosis;            // Diagnóstico
  final String? treatment;            // Tratamiento
  final String? notes;                // Notas adicionales
  final String? vitalSigns;           // Signos vitales
  final String? allergies;            // Alergias
  final String? medications;          // Medicamentos actuales
  final String createdBy;             // ID del doctor
  final String createdByName;         // Nombre del doctor
  final DateTime createdAt;           // Fecha de creación
  final DateTime? updatedAt;          // Última actualización
}
```

## 🚀 Uso

### 1. Listar Historias Clínicas

```dart
// Navegar a la lista de todas las historias
Navigator.pushNamed(context, '/clinical-records');

// Navegar a las historias de un paciente específico
Navigator.pushNamed(
  context,
  '/clinical-records',
  arguments: {
    'patientId': 'abc123',
    'patientName': 'Juan Pérez',
  },
);
```

### 2. Ver Detalle

```dart
Navigator.pushNamed(
  context,
  '/clinical-records/detail',
  arguments: recordId,
);
```

### 3. Crear Nueva Historia

```dart
Navigator.pushNamed(
  context,
  '/clinical-records/form',
  arguments: {'patientId': patientId},
);
```

### 4. Editar Historia Existente

```dart
Navigator.pushNamed(
  context,
  '/clinical-records/form',
  arguments: {
    'recordId': recordId,
    'record': clinicalRecordEntity,
  },
);
```

## 🎨 Pantallas

### Lista de Historias Clínicas
- Barra de búsqueda
- Lista con cards informativos
- Botón flotante para crear nueva (cuando se filtra por paciente)
- Pull-to-refresh
- Botón de eliminar en cada card

### Detalle de Historia Clínica
- Información del paciente y doctor
- Secciones organizadas:
  - Motivo de consulta
  - Signos vitales
  - Diagnóstico
  - Tratamiento
  - Alergias
  - Medicamentos actuales
  - Notas adicionales
- Botón de editar en el AppBar

### Formulario (Crear/Editar)
- Campos de texto con validación
- Campos requeridos: Motivo, Diagnóstico, Tratamiento
- Campos opcionales: Signos vitales, Alergias, Medicamentos, Notas
- Botones de Cancelar y Guardar
- Indicador de carga durante el guardado

## 🔒 Permisos

Este módulo está disponible para:
- **Doctores**: Pueden crear, ver, editar y eliminar historias
- **Administradores**: Acceso completo

## 🧪 Testing

Para probar el módulo:

1. **Backend activo**: Asegúrate de que el backend Django esté corriendo
2. **Autenticación**: Inicia sesión con un usuario Doctor o Admin
3. **Crear paciente**: Primero crea un paciente si no existe
4. **Crear historia**: Navega a las historias del paciente y crea una nueva
5. **CRUD completo**: Prueba ver, editar y eliminar

## 🔧 Configuración

### Variables de Entorno (.env)

```env
API_BASE_URL=http://10.0.2.2:8000/api
```

### Dependencias Registradas

El módulo ya está registrado en `injection_container.dart`:
- DataSource
- Repository
- UseCases (5)
- BLoC

### Rutas Configuradas

En `main.dart`:
```dart
'/clinical-records' → ClinicalRecordsListPage
'/clinical-records/detail' → ClinicalRecordDetailPage (con ID)
'/clinical-records/form' → ClinicalRecordFormPage (crear/editar)
```

## 📦 Dependencias

- `flutter_bloc`: State management
- `dio`: HTTP client
- `dartz`: Functional programming (Either)
- `equatable`: Value equality
- `json_annotation`: Serialización JSON
- `get_it`: Dependency injection

## 🐛 Troubleshooting

### Error: "No hay conexión a internet"
- Verifica que el emulador/dispositivo tenga conexión
- Verifica que el backend esté corriendo

### Error: "No autorizado"
- Asegúrate de estar autenticado
- Verifica que el token JWT no haya expirado

### Error 404: "Historia clínica no encontrada"
- Verifica que el ID de la historia sea correcto
- Asegúrate de que la historia no haya sido eliminada

### Error de validación
- Verifica que los campos requeridos estén completos
- Revisa los mensajes de error específicos del backend

## 📈 Próximas Mejoras

- [ ] Paginación infinita en la lista
- [ ] Filtros avanzados (por fecha, doctor, etc.)
- [ ] Exportar historia a PDF
- [ ] Adjuntar imágenes/documentos
- [ ] Historial de cambios
- [ ] Firma digital del doctor
- [ ] Compartir historia con otros doctores

## 👨‍💻 Desarrollo

### Generar archivos .g.dart

Después de modificar los modelos:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Agregar nuevos campos

1. Actualizar `ClinicalRecordEntity`
2. Actualizar `ClinicalRecordModel`
3. Regenerar archivos con build_runner
4. Actualizar formulario y vistas

## 📄 Licencia

Este módulo es parte del proyecto CliniDocs Mobile.

---

**Desarrollado con ❤️ usando Flutter + Clean Architecture + BLoC**
