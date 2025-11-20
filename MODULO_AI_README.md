# Módulo de Predicción de Diabetes con IA - App Móvil

## ✅ **¡Implementación Completada!**

Se ha agregado el módulo de predicción de diabetes con IA a la aplicación móvil de CliniDocs.

---

## 🎯 **¿Qué hace?**

Los médicos pueden:
1. Abrir el detalle de un paciente
2. Click en el botón "Predicción de Diabetes"
3. Ver la **probabilidad de diabetes** del paciente en tiempo real
4. Ver el **nivel de riesgo** (Bajo, Medio, Alto, Muy Alto)
5. Ver **historial de predicciones anteriores**
6. Ver **factores contribuyentes** y **recomendaciones**

---

## 📂 **Estructura Creada**

```
cr_movil/lib/features/ai/
├── data/
│   ├── datasources/
│   │   └── diabetes_remote_datasource.dart    # API calls al backend
│   ├── models/
│   │   └── diabetes_prediction_model.dart     # Modelo de datos
│   └── repositories/
│       └── diabetes_repository_impl.dart      # Implementación del repositorio
├── domain/
│   ├── entities/
│   │   └── diabetes_prediction_entity.dart    # Entidad de dominio
│   └── repositories/
│       └── diabetes_repository.dart           # Contrato del repositorio
└── presentation/
    ├── bloc/
    │   ├── diabetes_bloc.dart                 # Lógica de estado
    │   ├── diabetes_event.dart                # Eventos
    │   └── diabetes_state.dart                # Estados
    └── pages/
        └── diabetes_prediction_page.dart      # Pantalla principal
```

---

## 🔧 **Cambios Realizados**

### **1. Archivos Nuevos Creados:**

- ✅ **9 archivos** del módulo AI completo
- ✅ Integración en `patient_detail_page.dart` (botón añadido)
- ✅ Configuración en `injection_container.dart` (dependency injection)

### **2. Dependency Injection Configurado:**

```dart
// En injection_container.dart
void _initAI() {
  // DataSource
  sl.registerLazySingleton<DiabetesRemoteDataSource>(
    () => DiabetesRemoteDataSourceImpl(dioClient: sl<DioClient>()),
  );

  // Repository
  sl.registerLazySingleton<DiabetesRepository>(
    () => DiabetesRepositoryImpl(remoteDataSource: sl<DiabetesRemoteDataSource>()),
  );

  // BLoC
  sl.registerFactory<DiabetesBloc>(
    () => DiabetesBloc(repository: sl<DiabetesRepository>()),
  );
}
```

---

## 🚀 **Cómo Usar (Para Usuario Final)**

### **Paso 1: Abrir Detalle del Paciente**

En la app móvil:
1. Ir a **Pacientes**
2. Click en un paciente
3. Scroll hasta abajo

Verás un botón azul:

```
┌──────────────────────────────────────┐
│  📊  Predicción de Diabetes          │
│      Análisis con IA            →    │
└──────────────────────────────────────┘
```

### **Paso 2: Ver Predicción**

Al hacer click:
- Si el paciente NO tiene datos clínicos → Error (necesita triaje y labs)
- Si el paciente tiene datos → **Predicción instantánea**

### **Paso 3: Resultado**

La pantalla muestra:

```
┌────────────────────────────────────────┐
│  ⚠️  RIESGO DETECTADO                  │
│                                        │
│      Probabilidad de Diabetes          │
│              85%                       │
│                                        │
│       🔴 Riesgo Alto                   │
│                                        │
│  📊 Modelo: v1.2                       │
│  📅 Fecha: 19/11/2025 14:30           │
│                                        │
│  Factores Contribuyentes:              │
│  • Glucosa alta: 130.2 mg/dL          │
│  • BMI elevado: 34.5                   │
│  • Edad: 62 años                       │
│                                        │
│  Recomendaciones:                       │
│  ✓ Control de glucosa urgente          │
│  ✓ Consulta con endocrinólogo          │
│  ✓ Plan de reducción de peso           │
└────────────────────────────────────────┘
```

---

## 🔌 **Integración con Backend**

### **Endpoints Utilizados:**

#### **1. Hacer Predicción**
```dart
POST /api/ai/diabetes/predict/
Body: { "patient_id": "uuid" }

Response:
{
  "success": true,
  "data": {
    "id": "uuid",
    "patient": "uuid",
    "has_diabetes_risk": true,
    "probability": 0.85,
    "risk_level": "high",
    "model_version": "1.2",
    "features_used": { ... },
    "contributing_factors": [ ... ],
    "recommendations": [ ... ],
    "prediction_date": "2025-11-19T14:30:00Z"
  }
}
```

#### **2. Historial de Predicciones**
```dart
GET /api/ai/diabetes/patient/<patient_id>/

Response: [
  { ... prediction 1 ... },
  { ... prediction 2 ... },
  ...
]
```

---

## ⚙️ **Configuración Necesaria**

### **Backend Debe Estar Corriendo**

Asegúrate de que el backend Django esté activo:

```bash
cd cr_backend
python manage.py runserver
```

### **Modelo Entrenado**

El backend necesita el modelo entrenado:

```bash
cd cr_backend
python manage.py train_diabetes_model
```

Verifica que el modelo está activo:
```bash
curl http://localhost:8000/api/ai/diabetes/model/info/
```

### **Paciente con Datos Clínicos**

Para que funcione la predicción, el paciente debe tener:
- ✅ Historia clínica activa
- ✅ Triaje con peso, altura, presión arterial
- ✅ Orden de laboratorio: "Glucosa en ayunas"
- ✅ Orden de laboratorio: "Insulina sérica"

Puedes agregar datos manualmente o usar:
```bash
cd cr_backend
python manage.py add_clinical_data_to_patients --patient-id <uuid>
```

---

## 📱 **Prueba en la App**

### **Paso 1: Ejecutar la App**

```bash
cd cr_movil
flutter run
```

### **Paso 2: Login**

- Email: `doctor@clinidocs.com`
- Password: tu contraseña

### **Paso 3: Navegar**

1. Menú → **Pacientes**
2. Selecciona un paciente con datos clínicos
3. Scroll abajo → Click **"Predicción de Diabetes"**
4. Click **"Nueva Predicción"**
5. ¡Ver resultado!

---

## 🎨 **Características de la UI**

### **Diseño Adaptativo**

- 🟢 **Riesgo Bajo** → Verde
- 🟠 **Riesgo Medio** → Naranja
- 🔴 **Riesgo Alto** → Rojo
- 🔴🔴 **Riesgo Muy Alto** → Rojo oscuro

### **Componentes**

- **Card principal** con gradiente según riesgo
- **Probabilidad grande** (64px) centrada
- **Chip de nivel de riesgo** con icono
- **Lista de factores** con bullets
- **Lista de recomendaciones** con checks
- **Historial** con mini-cards
- **FAB** para nueva predicción

### **Interactividad**

- **Pull-to-refresh** → Actualiza historial
- **Diálogo automático** → Muestra resultado al completar
- **Loading** → Spinner mientras procesa
- **Snackbar** → Errores en rojo

---

## 🐛 **Troubleshooting**

### **Error: "No se pudo realizar la predicción"**

**Causa**: Paciente sin datos clínicos completos

**Solución**:
```bash
cd cr_backend
python manage.py add_clinical_data_to_patients --patient-id <uuid>
```

### **Error: "Error al conectar con el servidor"**

**Causa**: Backend no está corriendo o URL incorrecta

**Solución**:
1. Verificar backend: `http://localhost:8000/api/`
2. Verificar URL en `environment.dart`:
   ```dart
   static const String apiBaseUrl = 'http://10.0.2.2:8000'; // Emulador
   // o
   static const String apiBaseUrl = 'http://192.168.x.x:8000'; // Dispositivo físico
   ```

### **Error: "No hay modelo activo"**

**Causa**: Modelo no entrenado

**Solución**:
```bash
cd cr_backend
python manage.py train_diabetes_model
```

---

## 📊 **Ejemplo de Flujo Completo**

```
1. Usuario abre app → Login
         ↓
2. Navega a Pacientes → Selecciona paciente
         ↓
3. Scroll abajo → Click "Predicción de Diabetes"
         ↓
4. Click "Nueva Predicción" (FAB)
         ↓
5. Backend extrae features del paciente
         ↓
6. Modelo predice probabilidad
         ↓
7. Resultado se muestra en diálogo
         ↓
8. Card grande muestra detalles completos
         ↓
9. Historial se actualiza automáticamente
```

---

## ✅ **Checklist de Verificación**

Antes de probar, verifica:

- [ ] Backend Django corriendo en `http://localhost:8000`
- [ ] Modelo de diabetes entrenado (v1.2 con 85.98% accuracy)
- [ ] Al menos 1 paciente con datos clínicos completos
- [ ] App móvil compilando sin errores
- [ ] Dependency injection configurado
- [ ] Usuario puede hacer login

---

## 🎯 **Próximos Pasos (Opcional)**

Si quieres mejorar el módulo:

### **1. Agregar Gráficos**
Usar `fl_chart` para mostrar evolución del riesgo:
```dart
dependencies:
  fl_chart: ^0.68.0
```

### **2. Notificaciones Push**
Alertar cuando el riesgo sea alto:
```dart
if (prediction.riskLevel == 'high') {
  NotificationService.send('¡Riesgo Alto Detectado!');
}
```

### **3. Exportar PDF**
Generar reporte PDF del resultado:
```dart
dependencies:
  pdf: ^3.10.0
```

### **4. Comparar con Predicciones Anteriores**
Mostrar tendencia del riesgo en el tiempo

---

## 📞 **Soporte**

Para más información:
- 📄 Documentación backend: `cr_backend/docs/GUIA_PREDICCION_DIABETES.md`
- 🩺 Cómo agregar datos: `cr_backend/docs/EJEMPLO_SUBIR_TOMOGRAFIA.md`
- 🤖 Modelo ML: `cr_backend/apps/ai/ia-md`

---

¡El módulo de IA ya está listo para usar en el móvil! 🎉📱
