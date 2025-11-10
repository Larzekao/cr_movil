# Contrato de Clinical Records - Backend ↔ Mobile

## 📋 Resumen Ejecutivo

Este documento define el contrato completo entre el backend Django y la aplicación móvil Flutter para el módulo de **Clinical Records (Historias Clínicas)**.

**Fecha de alineación:** 10 de noviembre de 2025  
**Backend:** Django REST Framework  
**Mobile:** Flutter (Clean Architecture + BLoC)

---

## 🎯 Alcance del Módulo

### Funcionalidades Principales

1. **Gestión de Historias Clínicas (CRUD)**
   - Listar historias con filtros
   - Ver detalle de historia clínica
   - Crear nueva historia
   - Actualizar información
   - Archivar/Cerrar historias

2. **Formularios Clínicos**
   - Triaje
   - Consulta Médica
   - Notas de Evolución
   - Recetas Médicas
   - Órdenes de Laboratorio/Imagenología
   - Procedimientos
   - Alta Médica
   - Referencias

3. **Timeline de Eventos**
   - Vista cronológica de documentos y formularios
   - Historial completo del paciente

4. **Relación con Pacientes**
   - Historias clínicas por paciente
   - Validación de una sola historia activa

---

## 🔗 Endpoints del Backend

### Base URL
```
/api/clinical-records/
```

### 1. Historias Clínicas

#### **Listar Historias Clínicas**
```http
GET /api/clinical-records/
```

**Query Parameters:**
- `page`: número de página (default: 1)
- `page_size`: tamaño de página (default: 10)
- `search`: búsqueda por record_number, nombre de paciente
- `status`: filtrar por estado (active | archived | closed)
- `patient`: filtrar por ID de paciente
- `ordering`: ordenar por campos (-created_at, record_number)

**Response:**
```json
{
  "count": 100,
  "next": "http://api/clinical-records/?page=2",
  "previous": null,
  "results": [
    {
      "id": "uuid",
      "patient": "uuid",
      "patient_info": {
        "id": "uuid",
        "first_name": "Juan",
        "last_name": "Pérez",
        "identification": "12345678",
        "date_of_birth": "1990-05-15",
        "gender": "male"
      },
      "record_number": "HC-2025-000001",
      "status": "active",
      "blood_type": "O+",
      "allergies": [
        {
          "allergen": "Penicilina",
          "severity": "alta",
          "reaction": "Urticaria"
        }
      ],
      "chronic_conditions": [
        "Diabetes tipo 2",
        "Hipertensión"
      ],
      "medications": [
        {
          "name": "Metformina",
          "dose": "500mg",
          "frequency": "2 veces al día"
        }
      ],
      "family_history": "Padre con diabetes, madre hipertensa",
      "social_history": "No fuma, consume alcohol ocasionalmente",
      "documents_count": 15,
      "created_by": "uuid",
      "created_by_name": "Dr. García",
      "created_at": "2025-01-10T10:00:00Z",
      "updated_at": "2025-11-10T15:30:00Z"
    }
  ]
}
```

---

#### **Detalle de Historia Clínica**
```http
GET /api/clinical-records/{id}/
```

**Response:** Mismo formato que item de lista

---

#### **Crear Historia Clínica**
```http
POST /api/clinical-records/
```

**Request Body:**
```json
{
  "patient": "uuid",
  "blood_type": "O+",
  "allergies": [
    {
      "allergen": "Penicilina",
      "severity": "alta",
      "reaction": "Urticaria"
    }
  ],
  "chronic_conditions": ["Diabetes tipo 2"],
  "medications": [
    {
      "name": "Metformina",
      "dose": "500mg",
      "frequency": "2 veces al día"
    }
  ],
  "family_history": "Texto libre",
  "social_history": "Texto libre"
}
```

**Response:** Historia clínica creada (201 Created)

**Validaciones:**
- ✅ Paciente no debe tener otra historia clínica activa
- ✅ record_number se genera automáticamente: `HC-{año}-{número}`

---

#### **Actualizar Historia Clínica**
```http
PATCH /api/clinical-records/{id}/
PUT /api/clinical-records/{id}/
```

**Request Body:** Campos a actualizar (parcial o completo)

**Response:** Historia clínica actualizada

---

#### **Eliminar Historia Clínica**
```http
DELETE /api/clinical-records/{id}/
```

**Response:** 204 No Content

---

### 2. Acciones Especiales de Historia Clínica

#### **Archivar Historia**
```http
POST /api/clinical-records/{id}/archive/
```

**Response:**
```json
{
  "message": "Historia clínica archivada exitosamente",
  "status": "archived"
}
```

---

#### **Cerrar Historia**
```http
POST /api/clinical-records/{id}/close/
```

**Response:**
```json
{
  "message": "Historia clínica cerrada exitosamente",
  "status": "closed"
}
```

**Importante:** Una historia cerrada NO permite agregar nuevos formularios ni documentos.

---

#### **Timeline de Historia**
```http
GET /api/clinical-records/{id}/timeline/
```

**Response:**
```json
[
  {
    "type": "document",
    "date": "2025-11-10T10:00:00Z",
    "title": "Consulta Cardiología",
    "document_type": "consultation_note",
    "specialty": "Cardiología",
    "doctor_name": "Dr. García",
    "id": "uuid"
  },
  {
    "type": "document",
    "date": "2025-11-09T14:30:00Z",
    "title": "Orden de Laboratorio",
    "document_type": "lab_order",
    "specialty": "Medicina Interna",
    "doctor_name": "Dr. López",
    "id": "uuid"
  }
]
```

**Ordenamiento:** Descendente por fecha (más reciente primero)

---

#### **Documentos de Historia**
```http
GET /api/clinical-records/{id}/documents/
```

**Response:** Lista de documentos clínicos asociados

---

### 3. Formularios Clínicos

#### **Listar Formularios**
```http
GET /api/clinical-records/forms/
```

**Query Parameters:**
- `page`, `page_size`: paginación
- `search`: búsqueda por form_type, doctor_name, doctor_specialty
- `form_type`: filtrar por tipo de formulario
- `clinical_record`: filtrar por ID de historia clínica
- `filled_by`: filtrar por usuario que llenó
- `ordering`: ordenar (-form_date, created_at)

**Response:**
```json
{
  "count": 50,
  "results": [
    {
      "id": "uuid",
      "clinical_record": "uuid",
      "record_number": "HC-2025-000001",
      "patient_name": "Juan Pérez",
      "form_type": "triage",
      "form_type_display": "Triaje",
      "form_template_id": "uuid-optional",
      "form_data": {
        "vital_signs": {
          "blood_pressure": "120/80",
          "heart_rate": 75,
          "temperature": 36.5,
          "respiratory_rate": 18
        },
        "symptoms": ["Dolor de cabeza", "Fiebre"],
        "triage_level": "amarillo"
      },
      "filled_by": "uuid",
      "filled_by_name": "Enf. María González",
      "doctor_name": "Dr. García",
      "doctor_specialty": "Medicina General",
      "form_date": "2025-11-10T09:30:00Z",
      "created_at": "2025-11-10T09:35:00Z",
      "updated_at": "2025-11-10T09:35:00Z"
    }
  ]
}
```

---

#### **Detalle de Formulario**
```http
GET /api/clinical-records/forms/{id}/
```

---

#### **Crear Formulario**
```http
POST /api/clinical-records/forms/
```

**Request Body:**
```json
{
  "clinical_record": "uuid",
  "form_type": "triage",
  "form_template_id": "uuid-optional",
  "form_data": {
    "vital_signs": {
      "blood_pressure": "120/80",
      "heart_rate": 75
    }
  },
  "doctor_name": "Dr. García",
  "doctor_specialty": "Medicina General",
  "form_date": "2025-11-10T09:30:00Z"
}
```

**Validaciones:**
- ✅ La historia clínica NO debe estar cerrada
- ✅ form_data debe ser un objeto JSON válido
- ✅ filled_by se asigna automáticamente al usuario actual
- ✅ Si doctor_name está vacío, se toma del usuario

**Response:** Formulario creado (201 Created)

---

#### **Actualizar Formulario**
```http
PATCH /api/clinical-records/forms/{id}/
PUT /api/clinical-records/forms/{id}/
```

**Request Body:** Campos a actualizar

**Nota:** `form_type` y `clinical_record` son read-only en actualización

---

#### **Eliminar Formulario**
```http
DELETE /api/clinical-records/forms/{id}/
```

---

#### **Formularios por Historia Clínica**
```http
GET /api/clinical-records/forms/by_record/?clinical_record_id={uuid}
```

**Response:** Lista de formularios de esa historia

---

#### **Formularios por Tipo**
```http
GET /api/clinical-records/forms/by_type/?form_type=triage
```

---

#### **Tipos de Formularios Disponibles**
```http
GET /api/clinical-records/forms/form_types/
```

**Response:**
```json
{
  "form_types": [
    {"value": "triage", "label": "Triaje"},
    {"value": "consultation", "label": "Consulta Médica"},
    {"value": "evolution", "label": "Nota de Evolución"},
    {"value": "prescription", "label": "Receta Médica"},
    {"value": "lab_order", "label": "Orden de Laboratorio"},
    {"value": "imaging_order", "label": "Orden de Imagenología"},
    {"value": "procedure", "label": "Procedimiento"},
    {"value": "discharge", "label": "Alta Médica"},
    {"value": "referral", "label": "Referencia"},
    {"value": "other", "label": "Otro"}
  ]
}
```

---

### 4. Relación con Pacientes

#### **Historias Clínicas de un Paciente**
```http
GET /api/patients/{patient_id}/clinical-records/
```

**Response:** Lista de historias clínicas del paciente

---

## 📐 Reglas de Negocio

### ⚠️ Reglas Críticas

1. **Una Historia Activa por Paciente**
   - Solo puede existir 1 historia clínica con `status=active` por paciente
   - Al crear una nueva historia, valida que no exista otra activa
   - Si necesitas otra historia, primero archiva o cierra la actual

2. **Estados de Historia Clínica**
   - `active`: Historia en uso activo (default al crear)
   - `archived`: Historia archivada (puede reactivarse)
   - `closed`: Historia cerrada (NO permite agregar documentos/formularios)

3. **Restricción en Historia Cerrada**
   - NO se pueden agregar formularios clínicos
   - NO se pueden agregar documentos clínicos
   - Impacta a módulo Documents

4. **Generación Automática de Número**
   - Formato: `HC-{año}-{número_secuencial}`
   - Ejemplo: `HC-2025-000001`
   - Se genera automáticamente al crear

5. **Auto-completado de Doctor**
   - Si `doctor_name` está vacío al crear formulario, se toma del usuario actual
   - Si el usuario tiene `specialty`, se asigna a `doctor_specialty`

### 🔒 Permisos

**Clinical Records:**
- `clinical_record.read`: ver historias
- `clinical_record.create`: crear historias
- `clinical_record.update`: actualizar historias
- `clinical_record.delete`: eliminar historias

**Clinical Forms:**
- `clinical_form.read`: ver formularios
- `clinical_form.create`: crear formularios
- `clinical_form.update`: actualizar formularios
- `clinical_form.delete`: eliminar formularios

**Regla Especial:**
- Pacientes solo pueden ver SU propia historia clínica
- Doctores pueden gestionar todas las historias de su tenant

---

## 📊 Modelos de Datos

### ClinicalRecord (Historia Clínica)

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | UUID | ✅ | Identificador único |
| `patient` | UUID | ✅ | ID del paciente |
| `patient_info` | Object | ❌ | Información del paciente (read-only) |
| `record_number` | String | ✅ | Número de expediente (auto-generado) |
| `status` | Enum | ✅ | Estado: active \| archived \| closed |
| `blood_type` | String | ❌ | Tipo de sangre |
| `allergies` | JSON Array | ❌ | Lista de alergias |
| `chronic_conditions` | JSON Array | ❌ | Condiciones crónicas |
| `medications` | JSON Array | ❌ | Medicamentos actuales |
| `family_history` | Text | ❌ | Antecedentes familiares |
| `social_history` | Text | ❌ | Antecedentes sociales |
| `documents_count` | Integer | ❌ | Cantidad de documentos (read-only) |
| `created_by` | UUID | ❌ | Usuario creador (read-only) |
| `created_by_name` | String | ❌ | Nombre del creador (read-only) |
| `created_at` | DateTime | ✅ | Fecha de creación (read-only) |
| `updated_at` | DateTime | ✅ | Fecha de actualización (read-only) |

#### Estructura de `allergies`
```json
[
  {
    "allergen": "string",
    "severity": "string",
    "reaction": "string"
  }
]
```

#### Estructura de `medications`
```json
[
  {
    "name": "string",
    "dose": "string",
    "frequency": "string"
  }
]
```

---

### ClinicalForm (Formulario Clínico)

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | UUID | ✅ | Identificador único |
| `clinical_record` | UUID | ✅ | ID de la historia clínica |
| `record_number` | String | ❌ | Número de expediente (read-only) |
| `patient_name` | String | ❌ | Nombre del paciente (read-only) |
| `form_type` | Enum | ✅ | Tipo de formulario |
| `form_type_display` | String | ❌ | Tipo en texto (read-only) |
| `form_template_id` | UUID | ❌ | ID de plantilla (si se usa) |
| `form_data` | JSON Object | ✅ | Datos del formulario |
| `filled_by` | UUID | ✅ | Usuario que llenó (auto-asignado) |
| `filled_by_name` | String | ❌ | Nombre (read-only) |
| `doctor_name` | String | ❌ | Nombre del doctor |
| `doctor_specialty` | String | ❌ | Especialidad del doctor |
| `form_date` | DateTime | ✅ | Fecha del formulario |
| `created_at` | DateTime | ✅ | Fecha de creación (read-only) |
| `updated_at` | DateTime | ✅ | Fecha de actualización (read-only) |

#### Tipos de Formulario (`form_type`)
- `triage`: Triaje
- `consultation`: Consulta Médica
- `evolution`: Nota de Evolución
- `prescription`: Receta Médica
- `lab_order`: Orden de Laboratorio
- `imaging_order`: Orden de Imagenología
- `procedure`: Procedimiento
- `discharge`: Alta Médica
- `referral`: Referencia
- `other`: Otro

---

## 🏗️ Arquitectura Móvil

### Estructura de Carpetas (Clean Architecture)

```
lib/features/clinical_records/
├── data/
│   ├── datasources/
│   │   └── clinical_record_remote_datasource.dart
│   ├── models/
│   │   ├── clinical_record_model.dart
│   │   └── clinical_form_model.dart
│   └── repositories/
│       └── clinical_record_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── clinical_record_entity.dart
│   │   └── clinical_form_entity.dart
│   ├── repositories/
│   │   └── clinical_record_repository.dart
│   └── usecases/
│       ├── get_clinical_records.dart
│       ├── get_clinical_record_detail.dart
│       ├── create_clinical_record.dart
│       ├── update_clinical_record.dart
│       ├── archive_clinical_record.dart
│       ├── close_clinical_record.dart
│       ├── get_timeline.dart
│       ├── get_forms.dart
│       └── create_form.dart
└── presentation/
    ├── bloc/
    │   ├── clinical_record_bloc.dart
    │   ├── clinical_record_event.dart
    │   └── clinical_record_state.dart
    ├── pages/
    │   ├── clinical_records_list_page.dart
    │   ├── clinical_record_detail_page.dart
    │   ├── clinical_record_form_page.dart
    │   └── timeline_page.dart
    └── widgets/
        ├── clinical_record_card.dart
        ├── timeline_item.dart
        └── form_type_chip.dart
```

---

## 🎯 Plan de Implementación por Fases

### ✅ Fase 0: Alineación de Contrato (ACTUAL)

**Objetivo:** Confirmar y documentar el contrato completo

**Tareas:**
1. ✅ Revisar endpoints del backend
2. ✅ Documentar todos los filtros y parámetros
3. ✅ Definir estructura de datos
4. ✅ Confirmar reglas de negocio
5. ✅ Crear este documento

---

### 🔄 Fase 1: Actualización de Entidades y Modelos

**Objetivo:** Alinear entidades y modelos móviles con backend

**Tareas:**
1. Actualizar `ClinicalRecordEntity` con todos los campos
2. Crear `ClinicalFormEntity` desde cero
3. Actualizar `ClinicalRecordModel` con serialización completa
4. Crear `ClinicalFormModel` con serialización completa
5. Agregar tests unitarios de modelos

**Archivos a modificar:**
- `domain/entities/clinical_record_entity.dart`
- `domain/entities/clinical_form_entity.dart` (nuevo)
- `data/models/clinical_record_model.dart`
- `data/models/clinical_form_model.dart` (nuevo)

---

### 🔄 Fase 2: Capa de Datos (Data Layer)

**Objetivo:** Implementar datasources y repositorio

**Tareas:**
1. Actualizar `ClinicalRecordRemoteDataSource` con:
   - Filtros (status, patient_id)
   - Método `archive()`
   - Método `close()`
   - Método `getTimeline()`
2. Crear `ClinicalFormRemoteDataSource` con:
   - CRUD completo de formularios
   - Filtros (form_type, clinical_record_id)
   - Método `getByRecord()`
   - Método `getFormTypes()`
3. Actualizar `ClinicalRecordRepositoryImpl`
4. Agregar manejo de errores y excepciones

**Archivos a modificar/crear:**
- `data/datasources/clinical_record_remote_datasource.dart`
- `data/datasources/clinical_form_remote_datasource.dart` (nuevo)
- `data/repositories/clinical_record_repository_impl.dart`

---

### 🔄 Fase 3: Capa de Dominio (Domain Layer)

**Objetivo:** Definir contratos y casos de uso

**Tareas:**
1. Actualizar `ClinicalRecordRepository` interface
2. Crear casos de uso:
   - `GetClinicalRecords` (con filtros)
   - `GetClinicalRecordDetail`
   - `CreateClinicalRecord`
   - `UpdateClinicalRecord`
   - `ArchiveClinicalRecord`
   - `CloseClinicalRecord`
   - `GetTimeline`
   - `GetForms`
   - `CreateForm`
   - `UpdateForm`
3. Agregar validaciones en casos de uso

**Archivos a crear:**
- `domain/usecases/get_clinical_records.dart`
- `domain/usecases/archive_clinical_record.dart`
- `domain/usecases/close_clinical_record.dart`
- `domain/usecases/get_timeline.dart`
- `domain/usecases/get_forms.dart`
- `domain/usecases/create_form.dart`

---

### 🔄 Fase 4: Capa de Presentación (Presentation Layer)

**Objetivo:** Implementar BLoC y UI

**Tareas:**
1. Actualizar `ClinicalRecordBloc` con:
   - Eventos de filtrado
   - Eventos de archive/close
   - Manejo de timeline
   - Manejo de formularios
2. Crear estados apropiados
3. Implementar páginas:
   - Lista de historias con filtros
   - Detalle de historia
   - Timeline
   - Formularios clínicos
4. Crear widgets reutilizables

**Archivos a modificar/crear:**
- `presentation/bloc/clinical_record_bloc.dart`
- `presentation/pages/clinical_records_list_page.dart`
- `presentation/pages/clinical_record_detail_page.dart`
- `presentation/pages/timeline_page.dart`
- `presentation/pages/clinical_form_page.dart`

---

### 🔄 Fase 5: Navegación y Routing

**Objetivo:** Integrar con go_router

**Tareas:**
1. Definir rutas en `app_router.dart`
2. Implementar navegación entre páginas
3. Manejar parámetros de navegación

**Rutas sugeridas:**
- `/clinical-records` - Lista
- `/clinical-records/:id` - Detalle
- `/clinical-records/:id/timeline` - Timeline
- `/clinical-records/:id/forms/new` - Nuevo formulario

---

### 🔄 Fase 6: Testing y Validación

**Objetivo:** Asegurar calidad del código

**Tareas:**
1. Tests unitarios de entidades y modelos
2. Tests unitarios de casos de uso
3. Tests de repositorios
4. Tests de BLoC
5. Tests de integración
6. Validación E2E con backend real

---

## 📝 Notas Importantes

### 🚨 Puntos Críticos a Validar

1. **Validación de Historia Activa**
   - Implementar en cliente antes de crear
   - Manejar error 400 del backend

2. **Estado Cerrado**
   - Deshabilitar botones de agregar formularios/documentos
   - Mostrar indicador visual claro

3. **Filtros**
   - Implementar filtros locales y remotos
   - Persistir filtros en navegación

4. **Paginación**
   - Implementar scroll infinito
   - Manejar estados de carga

5. **Offline First**
   - Cachear historias consultadas
   - Sincronizar cambios al reconectar

---

## 🔗 Referencias

- **Backend API:** `/api/clinical-records/`
- **Documentación Backend:** `cr_backend/docs/`
- **Swagger:** `http://backend/api/schema/swagger-ui/`

---

## ✅ Checklist de Alineación

- [x] Endpoints documentados
- [x] Filtros confirmados (patient_id, status)
- [x] Acciones confirmadas (forms, timeline, archive, close)
- [x] Estructura de datos definida
- [x] Reglas de negocio claras
- [ ] Entidades móviles actualizadas
- [ ] Modelos móviles actualizados
- [ ] Datasources implementados
- [ ] Repositorio actualizado
- [ ] Casos de uso creados
- [ ] BLoC implementado
- [ ] UI completada
- [ ] Tests implementados
- [ ] Validación E2E

---

**Documento actualizado:** 10 de noviembre de 2025  
**Versión:** 1.0  
**Estado:** ✅ Contrato Confirmado - Listo para Fase 1
