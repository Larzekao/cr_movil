# 🤖 Chatbot de Ayuda - Manual de Usuario

## 📋 Descripción

El Chatbot de Ayuda es un asistente virtual integrado en CliniDocs que proporciona guías paso a paso y ayuda contextual para todos los usuarios del sistema. El chatbot se adapta automáticamente al rol del usuario, mostrando solo la información relevante para sus permisos y funcionalidades.

## ✨ Características

### 🎯 Adaptación por Rol
- **ASU (Super Admin)**: Acceso a toda la documentación del sistema
- **Administrador TI**: Guías de gestión de usuarios, roles, configuración del sistema
- **Doctor**: Historias clínicas, IA, formularios médicos, gestión de pacientes
- **Enfermera**: Historias clínicas (vista), signos vitales, formularios básicos
- **Recepcionista**: Registro de pacientes, agendamiento, formularios básicos

### 📚 Categorías de Ayuda
1. **Historias Clínicas**: Crear, ver, editar historias médicas
2. **Formularios**: Completar formularios de consentimiento, evolución, etc.
3. **IA y Mejora de Imágenes**: Usar funciones de inteligencia artificial
4. **Permisos y Accesos**: Comprender roles y solicitar permisos
5. **Gestión de Pacientes**: Registrar y buscar pacientes
6. **Gestión de Usuarios**: Crear usuarios y asignar roles (Admin)
7. **Configuración del Sistema**: Ajustes generales (Admin)
8. **Uso General**: Navegación y funciones básicas

### 🔍 Funcionalidades
- ✅ Búsqueda en tiempo real de temas
- ✅ Filtrado por categorías
- ✅ Guías paso a paso con iconos visuales
- ✅ Acciones rápidas para tareas comunes
- ✅ Interfaz intuitiva y animada

## 🚀 Uso

### Abrir el Chatbot

#### Opción 1: Botón Flotante Principal
En la mayoría de las pantallas, encontrarás un botón flotante azul con el ícono de ayuda (❓) en la esquina inferior derecha.

```dart
// Se agrega automáticamente en páginas con:
floatingActionButton: const HelpChatButton(),
```

#### Opción 2: Botón Mini
En páginas con múltiples botones flotantes, el chatbot aparece como un botón pequeño en la esquina inferior izquierda.

```dart
// Se integra en un Stack:
Stack(
  children: [
    // Contenido de la página
    const HelpChatButtonMini(alignment: Alignment.bottomLeft),
  ],
)
```

### Buscar Ayuda

1. **Búsqueda por Texto**
   - Escribe tu pregunta en la barra de búsqueda
   - Los resultados se filtran en tiempo real
   - Busca por palabras clave como: "crear historia", "permisos", "diabetes", etc.

2. **Navegación por Categorías**
   - Selecciona una categoría en la cuadrícula colorida
   - Ve todos los temas relacionados con esa categoría

3. **Acciones Rápidas**
   - Toca cualquier acción rápida para ir directamente a la guía
   - Las acciones se personalizan según tu rol

### Ver Guía Detallada

1. Toca cualquier tema de la lista
2. Se abrirá una página con:
   - Título y descripción del tema
   - Pasos numerados con instrucciones
   - Iconos visuales para cada paso
   - Información de contacto para soporte adicional

## 🛠️ Integración en Páginas

### Para Desarrolladores

#### 1. Registrar el HelpBloc

Ya está registrado globalmente en `main.dart`:

```dart
MultiBlocProvider(
  providers: [
    // ... otros blocs
    BlocProvider(create: (context) => HelpBloc()),
  ],
  // ...
)
```

#### 2. Agregar Botón Flotante Principal

```dart
import 'package:clinidocs_mobile/features/help/presentation/widgets/help_chat_button.dart';

Scaffold(
  appBar: AppBar(title: Text('Mi Página')),
  body: MyPageContent(),
  floatingActionButton: const HelpChatButton(),
)
```

#### 3. Agregar Botón Mini (para páginas con múltiples FABs)

```dart
import 'package:clinidocs_mobile/features/help/presentation/widgets/help_chat_button.dart';

Scaffold(
  body: Stack(
    children: [
      MyPageContent(),
      const HelpChatButtonMini(alignment: Alignment.bottomLeft),
    ],
  ),
  floatingActionButton: FloatingActionButton(
    onPressed: () => _myPrimaryAction(),
    child: Icon(Icons.add),
  ),
)
```

#### 4. Abrir Chatbot Programáticamente

```dart
import 'package:clinidocs_mobile/features/help/presentation/pages/help_chat_page.dart';
import 'package:clinidocs_mobile/features/help/presentation/bloc/help_bloc.dart';
import 'package:clinidocs_mobile/features/help/presentation/bloc/help_event.dart';

// Obtener rol del usuario
final userRole = (context.read<AuthBloc>().state as Authenticated).user.role?.name;

// Cargar temas
context.read<HelpBloc>().add(LoadHelpTopics(userRole: userRole));

// Abrir chatbot
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => HelpChatPage(userRole: userRole),
);
```

## 📝 Agregar Nuevos Temas de Ayuda

Para agregar nuevos temas, edita: `lib/features/help/data/datasources/help_local_datasource.dart`

```dart
HelpTopicEntity(
  id: 'mi_nuevo_tema',
  title: '¿Cómo hacer algo nuevo?',
  description: 'Aprende a realizar esta nueva funcionalidad.',
  category: HelpCategory.generalUsage,
  tags: ['tag1', 'tag2', 'tag3'],
  roles: [RoleConstants.doctor, RoleConstants.enfermera], // Dejar vacío para todos los roles
  steps: [
    HelpStepEntity(
      title: 'Paso 1',
      description: 'Descripción del primer paso.',
      iconName: 'add', // Nombre del ícono de Material Icons
    ),
    HelpStepEntity(
      title: 'Paso 2',
      description: 'Descripción del segundo paso.',
      iconName: 'edit',
    ),
    // ... más pasos
  ],
),
```

### Iconos Disponibles

Usa cualquier ícono de Material Icons. Los más comunes:
- `person`, `person_add`, `person_search`
- `add`, `edit`, `save`, `delete`
- `search`, `filter_alt`, `tune`
- `description`, `medical_information`
- `analytics`, `assessment`
- `security`, `admin_panel_settings`
- `check`, `check_circle`, `close`
- `upload`, `download`
- `visibility`, `visibility_off`

## 🎨 Personalización

### Colores

Los colores se definen en el tema de la app. Para cambiar el color del chatbot:

```dart
// En el botón flotante
FloatingActionButton(
  backgroundColor: Colors.blue, // Cambia el color aquí
  child: Icon(Icons.help_outline, color: Colors.white),
)
```

### Animaciones

La ventana del chatbot se desliza desde abajo con una animación suave de 300ms. Para ajustar:

```dart
// En help_chat_page.dart
AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 300), // Ajusta la duración
)
```

## 📱 Páginas con Chatbot Integrado

Actualmente integrado en:
- ✅ [HomePage](../auth/presentation/pages/home_page.dart) - Botón flotante principal
- ✅ [DiabetesPredictionPage](../../ai/presentation/pages/diabetes_prediction_page.dart) - Botón mini

### Próximas Integraciones Recomendadas
- [ ] PatientsListPage
- [ ] ClinicalRecordsListPage
- [ ] DocumentsListPage
- [ ] ClinicalRecordFormPage

## 🔧 Troubleshooting

### El chatbot no muestra ningún tema
**Causa**: No hay temas configurados para el rol del usuario actual.
**Solución**: Verifica que los temas tengan el rol correcto o déjalos vacíos para todos los roles.

### Los iconos no se muestran correctamente
**Causa**: El nombre del ícono no coincide con ningún ícono de Material.
**Solución**: Revisa la función `_getIconFromName()` en `help_topic_detail_page.dart` y agrega el ícono faltante.

### El botón flotante se superpone con otro elemento
**Causa**: Conflicto de posicionamiento con otros botones flotantes.
**Solución**: Usa `HelpChatButtonMini` con posicionamiento personalizado.

## 📊 Estadísticas

- **Total de Temas**: 15+ guías
- **Categorías**: 8 categorías principales
- **Roles Soportados**: 5 roles (ASU, Admin TI, Doctor, Enfermera, Recepcionista)
- **Idioma**: Español

## 🚀 Futuras Mejoras

- [ ] Historial de búsquedas
- [ ] Temas favoritos
- [ ] Valoración de utilidad de las guías
- [ ] Videos tutoriales integrados
- [ ] Chat con soporte en vivo
- [ ] Sincronización de temas desde el backend
- [ ] Notificaciones de nuevas guías
- [ ] Modo offline con caché

## 👥 Contribuir

Para agregar nuevas guías:
1. Identifica la necesidad del usuario
2. Crea el tema en `help_local_datasource.dart`
3. Asigna categoría, tags y roles apropiados
4. Escribe pasos claros y concisos
5. Agrega iconos visuales
6. Prueba con diferentes roles

## 📞 Soporte

Si necesitas ayuda con el chatbot:
- **Desarrolladores**: Revisa el código en `lib/features/help/`
- **Usuarios**: Contacta a tu Administrador TI
- **Reportar bugs**: Crea un issue en el repositorio

---

**Versión**: 1.0.0
**Última actualización**: Noviembre 2025
**Autor**: Equipo CliniDocs
