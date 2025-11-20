# 📘 Ejemplos de Integración del Chatbot de Ayuda

## 🎯 Casos de Uso Comunes

### 1. Página Simple con Botón Flotante Principal

**Cuándo usar**: Páginas sin otros botones flotantes.

```dart
import 'package:flutter/material.dart';
import 'package:clinidocs_mobile/features/help/presentation/widgets/help_chat_button.dart';

class MySimplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mi Página')),
      body: Center(child: Text('Contenido de la página')),
      floatingActionButton: const HelpChatButton(),
    );
  }
}
```

---

### 2. Página con Múltiples FABs (Botón Mini)

**Cuándo usar**: Páginas que ya tienen un botón flotante principal.

```dart
import 'package:flutter/material.dart';
import 'package:clinidocs_mobile/features/help/presentation/widgets/help_chat_button.dart';

class MyPageWithMultipleFABs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestión de Pacientes')),
      body: Stack(
        children: [
          // Contenido principal
          ListView(
            children: [
              ListTile(title: Text('Paciente 1')),
              ListTile(title: Text('Paciente 2')),
              // ... más contenido
            ],
          ),

          // Botón de ayuda mini en la esquina inferior izquierda
          const HelpChatButtonMini(alignment: Alignment.bottomLeft),
        ],
      ),
      // Botón principal para agregar paciente
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addPatient(),
        child: Icon(Icons.person_add),
        tooltip: 'Agregar Paciente',
      ),
    );
  }

  void _addPatient() {
    // Lógica para agregar paciente
  }
}
```

---

### 3. Página con Botón en Esquina Superior Derecha

**Cuándo usar**: Cuando la parte inferior está ocupada o prefieres otro posicionamiento.

```dart
import 'package:flutter/material.dart';
import 'package:clinidocs_mobile/features/help/presentation/widgets/help_chat_button.dart';

class MyPageTopRightHelp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mi Página')),
      body: Stack(
        children: [
          // Contenido
          MyPageContent(),

          // Botón de ayuda en esquina superior derecha
          const HelpChatButtonMini(alignment: Alignment.topRight),
        ],
      ),
    );
  }
}
```

---

### 4. Abrir Chatbot con Tema Específico

**Cuándo usar**: Para llevar al usuario directamente a una guía específica desde un onboarding o tutorial.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinidocs_mobile/features/help/presentation/bloc/help_bloc.dart';
import 'package:clinidocs_mobile/features/help/presentation/bloc/help_event.dart';
import 'package:clinidocs_mobile/features/help/presentation/pages/help_topic_detail_page.dart';

class OnboardingPage extends StatelessWidget {
  void _showHelpForCreatingMedicalRecord(BuildContext context) {
    // Navegar directamente a la guía de crear historia clínica
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HelpTopicDetailPage(
          topicId: 'create_medical_record',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bienvenido')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('¿Necesitas ayuda para empezar?'),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showHelpForCreatingMedicalRecord(context),
              icon: Icon(Icons.help),
              label: Text('Ver cómo crear historias clínicas'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 5. Abrir Chatbot Programáticamente

**Cuándo usar**: Cuando quieres abrir el chatbot desde código, no desde un botón visible.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinidocs_mobile/features/help/presentation/bloc/help_bloc.dart';
import 'package:clinidocs_mobile/features/help/presentation/bloc/help_event.dart';
import 'package:clinidocs_mobile/features/help/presentation/pages/help_chat_page.dart';
import 'package:clinidocs_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clinidocs_mobile/features/auth/presentation/bloc/auth_state.dart';

class MyPage extends StatelessWidget {
  void _openHelpChat(BuildContext context) {
    // Obtener el rol del usuario autenticado
    String? userRole;
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      userRole = authState.user.role?.name;
    }

    // Cargar los temas de ayuda según el rol
    context.read<HelpBloc>().add(LoadHelpTopics(userRole: userRole));

    // Abrir el chatbot como modal bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HelpChatPage(userRole: userRole),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Página'),
        actions: [
          // Botón de ayuda en el AppBar
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () => _openHelpChat(context),
            tooltip: 'Ayuda',
          ),
        ],
      ),
      body: Center(child: Text('Contenido')),
    );
  }
}
```

---

### 6. Página de Formulario con Ayuda Contextual

**Cuándo usar**: En formularios complejos donde el usuario puede necesitar ayuda.

```dart
import 'package:flutter/material.dart';
import 'package:clinidocs_mobile/features/help/presentation/widgets/help_chat_button.dart';

class MedicalRecordFormPage extends StatefulWidget {
  @override
  _MedicalRecordFormPageState createState() => _MedicalRecordFormPageState();
}

class _MedicalRecordFormPageState extends State<MedicalRecordFormPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva Historia Clínica'),
        actions: [
          // Ícono de ayuda en el AppBar también
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: _showFormHelp,
            tooltip: 'Cómo llenar este formulario',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Formulario
          Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Motivo de Consulta',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.help_outline, size: 20),
                      onPressed: () => _showFieldHelp('motivo'),
                    ),
                  ),
                ),
                // ... más campos
              ],
            ),
          ),

          // Botón de ayuda flotante
          const HelpChatButtonMini(alignment: Alignment.bottomLeft),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveForm,
        icon: Icon(Icons.save),
        label: Text('Guardar'),
      ),
    );
  }

  void _showFormHelp() {
    // Mostrar ayuda general del formulario
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ayuda - Historia Clínica'),
        content: Text(
          'Completa todos los campos obligatorios. '
          'Usa el botón de ayuda flotante para ver una guía detallada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showFieldHelp(String field) {
    // Ayuda específica para cada campo
    String message = '';
    switch (field) {
      case 'motivo':
        message = 'Describe brevemente por qué el paciente viene a consulta.';
        break;
      // ... otros campos
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      // Guardar formulario
    }
  }
}
```

---

### 7. Lista con Ayuda sobre Cómo Usar Filtros

```dart
import 'package:flutter/material.dart';
import 'package:clinidocs_mobile/features/help/presentation/widgets/help_chat_button.dart';

class PatientsListPage extends StatefulWidget {
  @override
  _PatientsListPageState createState() => _PatientsListPageState();
}

class _PatientsListPageState extends State<PatientsListPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pacientes'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Barra de búsqueda con ayuda
              Padding(
                padding: EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar pacientes...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.help_outline),
                      onPressed: () => _showSearchHelp(),
                      tooltip: 'Cómo buscar',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),

              // Lista de pacientes
              Expanded(
                child: _buildPatientsList(),
              ),
            ],
          ),

          // Botón de ayuda flotante
          const HelpChatButtonMini(alignment: Alignment.bottomLeft),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPatient,
        child: Icon(Icons.person_add),
        tooltip: 'Agregar Paciente',
      ),
    );
  }

  Widget _buildPatientsList() {
    // Implementación de la lista
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) => ListTile(
        title: Text('Paciente $index'),
        subtitle: Text('ID: 00$index'),
      ),
    );
  }

  void _showSearchHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.search, color: Colors.blue),
            SizedBox(width: 8),
            Text('Búsqueda de Pacientes'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Puedes buscar por:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Nombre completo'),
            Text('• Apellido'),
            Text('• Número de documento'),
            Text('• Número de historia clínica'),
            SizedBox(height: 16),
            Text(
              'Para ayuda más detallada, usa el botón de ayuda flotante.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showFilters() {
    // Mostrar filtros
  }

  void _addPatient() {
    // Agregar paciente
  }
}
```

---

### 8. Dashboard con Ayuda en Tarjetas

```dart
import 'package:flutter/material.dart';
import 'package:clinidocs_mobile/features/help/presentation/pages/help_topic_detail_page.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildFeatureCard(
            context,
            title: 'Historias Clínicas',
            icon: Icons.medical_information,
            color: Colors.blue,
            helpTopicId: 'create_medical_record',
            onTap: () => _navigateToMedicalRecords(context),
          ),
          _buildFeatureCard(
            context,
            title: 'Pacientes',
            icon: Icons.people,
            color: Colors.green,
            helpTopicId: 'register_patient',
            onTap: () => _navigateToPatients(context),
          ),
          _buildFeatureCard(
            context,
            title: 'Predicción IA',
            icon: Icons.psychology,
            color: Colors.purple,
            helpTopicId: 'diabetes_prediction',
            onTap: () => _navigateToAI(context),
          ),
          // ... más tarjetas
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String helpTopicId,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Contenido principal
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 48, color: color),
                  SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Botón de ayuda en la esquina
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: Icon(Icons.help_outline, size: 18),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HelpTopicDetailPage(
                        topicId: helpTopicId,
                      ),
                    ),
                  );
                },
                tooltip: '¿Cómo usar?',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToMedicalRecords(BuildContext context) {
    Navigator.pushNamed(context, '/clinical-records');
  }

  void _navigateToPatients(BuildContext context) {
    Navigator.pushNamed(context, '/patients');
  }

  void _navigateToAI(BuildContext context) {
    Navigator.pushNamed(context, '/ai-predictions');
  }
}
```

---

## 🎨 Personalización de Posicionamiento

```dart
// Esquina inferior izquierda (por defecto)
const HelpChatButtonMini(alignment: Alignment.bottomLeft)

// Esquina inferior derecha
const HelpChatButtonMini(alignment: Alignment.bottomRight)

// Esquina superior izquierda
const HelpChatButtonMini(alignment: Alignment.topLeft)

// Esquina superior derecha
const HelpChatButtonMini(alignment: Alignment.topRight)
```

---

## 📋 Checklist de Integración

Al agregar el chatbot a una nueva página, verifica:

- [ ] Import correcto del widget (`help_chat_button.dart`)
- [ ] `HelpBloc` registrado en `main.dart` (ya está hecho globalmente)
- [ ] Botón flotante no se superpone con otros elementos
- [ ] Funciona correctamente en diferentes tamaños de pantalla
- [ ] El rol del usuario se pasa correctamente (automático con `HelpChatButton`)
- [ ] Los temas relevantes existen en `help_local_datasource.dart`
- [ ] Probado en modo debug y release

---

## 🐛 Errores Comunes y Soluciones

### Error: "BlocProvider not found"
**Solución**: Asegúrate de que `HelpBloc` esté registrado en `main.dart` como provider global.

### Error: Botón se superpone con otro FAB
**Solución**: Usa `HelpChatButtonMini` en lugar de `HelpChatButton` y ajusta el posicionamiento.

### El chatbot no muestra temas
**Solución**: Verifica que el rol del usuario esté configurado correctamente y que existan temas para ese rol.

---

**¿Necesitas más ejemplos?** Revisa las implementaciones existentes en:
- `home_page.dart`
- `diabetes_prediction_page.dart`
