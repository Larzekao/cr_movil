import '../../domain/entities/help_topic_entity.dart';
import '../../../../core/constants/role_constants.dart';

/// Fuente de datos local con todos los temas de ayuda
class HelpLocalDataSource {
  // Singleton pattern
  static final HelpLocalDataSource _instance = HelpLocalDataSource._internal();
  factory HelpLocalDataSource() => _instance;
  HelpLocalDataSource._internal();

  /// Obtiene todos los temas de ayuda filtrados por rol
  List<HelpTopicEntity> getHelpTopicsByRole(String? userRole) {
    return _allTopics
        .where((topic) => topic.roles.isEmpty || topic.roles.contains(userRole ?? ''))
        .toList();
  }

  /// Busca temas de ayuda por query
  List<HelpTopicEntity> searchHelpTopics(String query, String? userRole) {
    final lowerQuery = query.toLowerCase();
    return getHelpTopicsByRole(userRole).where((topic) {
      return topic.title.toLowerCase().contains(lowerQuery) ||
          topic.description.toLowerCase().contains(lowerQuery) ||
          topic.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Obtiene temas por categoría
  List<HelpTopicEntity> getTopicsByCategory(String category, String? userRole) {
    return getHelpTopicsByRole(userRole)
        .where((topic) => topic.category == category)
        .toList();
  }

  /// Obtiene un tema específico por ID
  HelpTopicEntity? getTopicById(String id) {
    try {
      return _allTopics.firstWhere((topic) => topic.id == id);
    } catch (e) {
      return null;
    }
  }

  // Base de datos de temas de ayuda
  static final List<HelpTopicEntity> _allTopics = [
    // ===== HISTORIAS CLÍNICAS =====
    HelpTopicEntity(
      id: 'create_medical_record',
      title: '¿Cómo crear una historia clínica?',
      description: 'Aprende a crear una nueva historia clínica para un paciente.',
      category: HelpCategory.medicalRecords,
      tags: ['historia', 'crear', 'paciente', 'médico'],
      roles: [RoleConstants.doctor, RoleConstants.enfermera, RoleConstants.adminTI, RoleConstants.asu],
      steps: [
        HelpStepEntity(
          title: 'Acceder a la lista de pacientes',
          description: 'Desde el menú principal, selecciona "Pacientes" o usa el ícono de búsqueda.',
          iconName: 'person_search',
        ),
        HelpStepEntity(
          title: 'Seleccionar el paciente',
          description: 'Busca y selecciona al paciente para el cual quieres crear la historia clínica.',
          iconName: 'person',
        ),
        HelpStepEntity(
          title: 'Crear nueva historia',
          description: 'Presiona el botón "Nueva Historia Clínica" o el ícono "+".',
          iconName: 'add',
        ),
        HelpStepEntity(
          title: 'Completar información',
          description: 'Llena todos los campos requeridos: motivo de consulta, antecedentes, examen físico, diagnóstico y tratamiento.',
          iconName: 'edit',
        ),
        HelpStepEntity(
          title: 'Guardar',
          description: 'Revisa la información y presiona "Guardar". La historia quedará registrada con tu nombre y fecha.',
          iconName: 'save',
        ),
      ],
    ),

    HelpTopicEntity(
      id: 'view_medical_history',
      title: '¿Cómo ver el historial médico de un paciente?',
      description: 'Accede al historial completo de historias clínicas de un paciente.',
      category: HelpCategory.medicalRecords,
      tags: ['historial', 'ver', 'consultar', 'paciente'],
      roles: [RoleConstants.doctor, RoleConstants.enfermera, RoleConstants.adminTI, RoleConstants.asu],
      steps: [
        HelpStepEntity(
          title: 'Buscar paciente',
          description: 'Accede a la sección de "Pacientes" y busca al paciente deseado.',
          iconName: 'search',
        ),
        HelpStepEntity(
          title: 'Ver perfil del paciente',
          description: 'Toca sobre el paciente para ver su perfil completo.',
          iconName: 'person',
        ),
        HelpStepEntity(
          title: 'Acceder al historial',
          description: 'Selecciona la pestaña "Historial Médico" o "Historias Clínicas" para ver todas las consultas anteriores.',
          iconName: 'history',
        ),
        HelpStepEntity(
          title: 'Ver detalles',
          description: 'Toca cualquier historia clínica para ver sus detalles completos.',
          iconName: 'visibility',
        ),
      ],
    ),

    // ===== FORMULARIOS =====
    HelpTopicEntity(
      id: 'fill_forms',
      title: '¿Cómo llenar formularios médicos?',
      description: 'Guía para completar formularios de consentimiento, evolución, etc.',
      category: HelpCategory.forms,
      tags: ['formulario', 'llenar', 'completar', 'consentimiento'],
      roles: [RoleConstants.doctor, RoleConstants.enfermera, RoleConstants.recepcionista],
      steps: [
        HelpStepEntity(
          title: 'Acceder a formularios',
          description: 'Desde el perfil del paciente o historia clínica, selecciona "Formularios".',
          iconName: 'description',
        ),
        HelpStepEntity(
          title: 'Seleccionar tipo',
          description: 'Elige el tipo de formulario que necesitas: consentimiento, evolución, orden médica, etc.',
          iconName: 'list',
        ),
        HelpStepEntity(
          title: 'Completar campos',
          description: 'Llena todos los campos obligatorios. Los campos opcionales pueden dejarse en blanco.',
          iconName: 'edit',
        ),
        HelpStepEntity(
          title: 'Firma digital',
          description: 'Si el formulario requiere firma, usa el panel de firma digital o tu firma electrónica.',
          iconName: 'draw',
        ),
        HelpStepEntity(
          title: 'Guardar y archivar',
          description: 'Presiona "Guardar". El formulario quedará adjunto a la historia clínica del paciente.',
          iconName: 'save',
        ),
      ],
    ),

    // ===== IA Y MEJORA DE IMÁGENES =====
    HelpTopicEntity(
      id: 'improve_images',
      title: '¿Cómo mejorar imágenes con IA?',
      description: 'Usa la IA para mejorar la calidad de radiografías, ecografías y otras imágenes médicas.',
      category: HelpCategory.ai,
      tags: ['ia', 'inteligencia artificial', 'imagen', 'mejorar', 'radiografía'],
      roles: [RoleConstants.doctor, RoleConstants.enfermera, RoleConstants.adminTI, RoleConstants.asu],
      steps: [
        HelpStepEntity(
          title: 'Subir imagen',
          description: 'Desde la historia clínica, selecciona "Adjuntar imagen" o "Estudios de imagen".',
          iconName: 'upload',
        ),
        HelpStepEntity(
          title: 'Seleccionar IA',
          description: 'Una vez cargada la imagen, presiona el botón "Mejorar con IA" o el ícono de varita mágica.',
          iconName: 'auto_fix_high',
        ),
        HelpStepEntity(
          title: 'Esperar procesamiento',
          description: 'La IA procesará la imagen. Esto puede tardar unos segundos dependiendo del tamaño.',
          iconName: 'hourglass_empty',
        ),
        HelpStepEntity(
          title: 'Comparar resultados',
          description: 'Podrás ver la imagen original y la mejorada lado a lado para comparar.',
          iconName: 'compare',
        ),
        HelpStepEntity(
          title: 'Guardar o descartar',
          description: 'Si estás satisfecho con el resultado, presiona "Guardar mejorada". De lo contrario, "Mantener original".',
          iconName: 'save',
        ),
      ],
    ),

    HelpTopicEntity(
      id: 'diabetes_prediction',
      title: '¿Cómo usar la predicción de diabetes?',
      description: 'Utiliza la IA para predecir el riesgo de diabetes de un paciente.',
      category: HelpCategory.ai,
      tags: ['diabetes', 'predicción', 'ia', 'riesgo', 'análisis'],
      roles: [RoleConstants.doctor, RoleConstants.enfermera],
      steps: [
        HelpStepEntity(
          title: 'Acceder al paciente',
          description: 'Busca y selecciona al paciente en la lista de pacientes.',
          iconName: 'person',
        ),
        HelpStepEntity(
          title: 'Ir a IA/Análisis',
          description: 'Desde el perfil del paciente, selecciona "Análisis con IA" o "Predicción de Diabetes".',
          iconName: 'analytics',
        ),
        HelpStepEntity(
          title: 'Verificar datos',
          description: 'Asegúrate de que el paciente tenga datos clínicos completos (glucosa, presión, IMC, etc.).',
          iconName: 'check',
        ),
        HelpStepEntity(
          title: 'Realizar predicción',
          description: 'Presiona "Nueva Predicción" o el botón flotante de análisis.',
          iconName: 'play_arrow',
        ),
        HelpStepEntity(
          title: 'Revisar resultados',
          description: 'La IA mostrará el porcentaje de riesgo, nivel (bajo/medio/alto) y factores contribuyentes.',
          iconName: 'assessment',
        ),
      ],
    ),

    // ===== PERMISOS =====
    HelpTopicEntity(
      id: 'role_permissions',
      title: '¿Qué permisos tiene mi rol?',
      description: 'Comprende qué acciones puedes realizar según tu rol en el sistema.',
      category: HelpCategory.permissions,
      tags: ['permisos', 'rol', 'acceso', 'privilegios'],
      roles: [], // Todos los roles
      steps: [
        HelpStepEntity(
          title: 'ASU (Super Admin)',
          description: 'Acceso total al sistema. Puede gestionar todos los tenants, usuarios, roles y configuraciones globales.',
          iconName: 'admin_panel_settings',
        ),
        HelpStepEntity(
          title: 'Administrador TI',
          description: 'Gestión completa de su tenant: crear usuarios, asignar roles, configurar módulos y permisos.',
          iconName: 'settings',
        ),
        HelpStepEntity(
          title: 'Doctor',
          description: 'Crear y ver historias clínicas, gestionar pacientes, usar IA, completar formularios médicos.',
          iconName: 'local_hospital',
        ),
        HelpStepEntity(
          title: 'Enfermera',
          description: 'Ver historias clínicas, registrar signos vitales, completar algunos formularios, asistir en consultas.',
          iconName: 'medical_services',
        ),
        HelpStepEntity(
          title: 'Recepcionista',
          description: 'Registrar pacientes, agendar citas, actualizar datos de contacto, imprimir formularios básicos.',
          iconName: 'badge',
        ),
      ],
    ),

    HelpTopicEntity(
      id: 'request_permissions',
      title: '¿Cómo solicitar más permisos?',
      description: 'Si necesitas acceso a funciones adicionales, aprende cómo solicitarlo.',
      category: HelpCategory.permissions,
      tags: ['solicitar', 'permisos', 'acceso', 'administrador'],
      roles: [],
      steps: [
        HelpStepEntity(
          title: 'Identificar necesidad',
          description: 'Determina exactamente qué función o módulo necesitas acceder.',
          iconName: 'lightbulb',
        ),
        HelpStepEntity(
          title: 'Contactar administrador',
          description: 'Comunícate con tu Administrador TI o supervisor directo.',
          iconName: 'contact_mail',
        ),
        HelpStepEntity(
          title: 'Justificar solicitud',
          description: 'Explica por qué necesitas ese permiso y cómo te ayudará en tu trabajo.',
          iconName: 'description',
        ),
        HelpStepEntity(
          title: 'Esperar aprobación',
          description: 'El administrador evaluará tu solicitud y, si es aprobada, actualizará tu rol o permisos.',
          iconName: 'pending',
        ),
        HelpStepEntity(
          title: 'Verificar acceso',
          description: 'Una vez aprobado, cierra sesión y vuelve a iniciar para que los cambios se apliquen.',
          iconName: 'check_circle',
        ),
      ],
    ),

    // ===== GESTIÓN DE PACIENTES =====
    HelpTopicEntity(
      id: 'register_patient',
      title: '¿Cómo registrar un nuevo paciente?',
      description: 'Guía paso a paso para agregar un paciente al sistema.',
      category: HelpCategory.patients,
      tags: ['paciente', 'registrar', 'nuevo', 'agregar'],
      roles: [RoleConstants.doctor, RoleConstants.enfermera, RoleConstants.recepcionista],
      steps: [
        HelpStepEntity(
          title: 'Acceder a pacientes',
          description: 'Desde el menú principal, selecciona "Pacientes".',
          iconName: 'people',
        ),
        HelpStepEntity(
          title: 'Nuevo paciente',
          description: 'Presiona el botón "+" o "Agregar Paciente".',
          iconName: 'person_add',
        ),
        HelpStepEntity(
          title: 'Datos personales',
          description: 'Completa: nombres, apellidos, fecha de nacimiento, género, documento de identidad.',
          iconName: 'badge',
        ),
        HelpStepEntity(
          title: 'Datos de contacto',
          description: 'Agrega: teléfono, email, dirección, contacto de emergencia.',
          iconName: 'phone',
        ),
        HelpStepEntity(
          title: 'Guardar',
          description: 'Revisa que todos los datos obligatorios estén completos y presiona "Guardar".',
          iconName: 'save',
        ),
      ],
    ),

    HelpTopicEntity(
      id: 'search_patient',
      title: '¿Cómo buscar un paciente?',
      description: 'Encuentra rápidamente a un paciente en el sistema.',
      category: HelpCategory.patients,
      tags: ['buscar', 'encontrar', 'paciente', 'filtrar'],
      roles: [RoleConstants.doctor, RoleConstants.enfermera, RoleConstants.recepcionista],
      steps: [
        HelpStepEntity(
          title: 'Usar barra de búsqueda',
          description: 'En la sección "Pacientes", usa la barra de búsqueda en la parte superior.',
          iconName: 'search',
        ),
        HelpStepEntity(
          title: 'Criterios de búsqueda',
          description: 'Puedes buscar por: nombre, apellido, documento de identidad o número de historia.',
          iconName: 'filter_alt',
        ),
        HelpStepEntity(
          title: 'Filtros avanzados',
          description: 'Usa filtros adicionales como rango de edad, género o estado de paciente.',
          iconName: 'tune',
        ),
        HelpStepEntity(
          title: 'Seleccionar resultado',
          description: 'Toca sobre el paciente encontrado para ver su perfil completo.',
          iconName: 'touch_app',
        ),
      ],
    ),

    // ===== GESTIÓN DE USUARIOS (Admin) =====
    HelpTopicEntity(
      id: 'create_user',
      title: '¿Cómo crear un nuevo usuario?',
      description: 'Registra nuevos usuarios en el sistema (solo para administradores).',
      category: HelpCategory.users,
      tags: ['usuario', 'crear', 'registrar', 'admin'],
      roles: [RoleConstants.adminTI, RoleConstants.asu],
      steps: [
        HelpStepEntity(
          title: 'Acceder a gestión de usuarios',
          description: 'Desde el menú de administración, selecciona "Usuarios" o "Gestión de Usuarios".',
          iconName: 'manage_accounts',
        ),
        HelpStepEntity(
          title: 'Nuevo usuario',
          description: 'Presiona "Agregar Usuario" o el botón "+".',
          iconName: 'person_add',
        ),
        HelpStepEntity(
          title: 'Datos del usuario',
          description: 'Completa: nombres, apellidos, email (que será su usuario), documento de identidad.',
          iconName: 'badge',
        ),
        HelpStepEntity(
          title: 'Asignar rol',
          description: 'Selecciona el rol apropiado: Doctor, Enfermera, Recepcionista, etc.',
          iconName: 'assignment_ind',
        ),
        HelpStepEntity(
          title: 'Contraseña temporal',
          description: 'El sistema generará una contraseña temporal que el usuario deberá cambiar en su primer ingreso.',
          iconName: 'password',
        ),
        HelpStepEntity(
          title: 'Guardar y notificar',
          description: 'Guarda el usuario. Se enviará un email con las credenciales de acceso.',
          iconName: 'send',
        ),
      ],
    ),

    HelpTopicEntity(
      id: 'manage_roles',
      title: '¿Cómo gestionar roles y permisos?',
      description: 'Crea roles personalizados y asigna permisos específicos.',
      category: HelpCategory.users,
      tags: ['roles', 'permisos', 'admin', 'personalizar'],
      roles: [RoleConstants.adminTI, RoleConstants.asu],
      steps: [
        HelpStepEntity(
          title: 'Acceder a roles',
          description: 'En el menú de administración, selecciona "Roles y Permisos".',
          iconName: 'admin_panel_settings',
        ),
        HelpStepEntity(
          title: 'Crear nuevo rol',
          description: 'Presiona "Nuevo Rol" y asigna un nombre descriptivo (ej: "Médico Especialista").',
          iconName: 'add_box',
        ),
        HelpStepEntity(
          title: 'Seleccionar permisos',
          description: 'Marca las casillas de los módulos y acciones que este rol podrá realizar.',
          iconName: 'checklist',
        ),
        HelpStepEntity(
          title: 'Revisar permisos',
          description: 'Asegúrate de dar solo los permisos necesarios. Principio de menor privilegio.',
          iconName: 'security',
        ),
        HelpStepEntity(
          title: 'Guardar rol',
          description: 'Guarda el rol. Ahora podrás asignarlo a usuarios nuevos o existentes.',
          iconName: 'save',
        ),
      ],
    ),

    // ===== CONFIGURACIÓN DEL SISTEMA =====
    HelpTopicEntity(
      id: 'system_settings',
      title: '¿Cómo configurar el sistema?',
      description: 'Configura parámetros generales del sistema (solo Admin TI).',
      category: HelpCategory.system,
      tags: ['configuración', 'sistema', 'settings', 'admin'],
      roles: [RoleConstants.adminTI, RoleConstants.asu],
      steps: [
        HelpStepEntity(
          title: 'Acceder a configuración',
          description: 'Desde el menú, selecciona el ícono de engranaje o "Configuración".',
          iconName: 'settings',
        ),
        HelpStepEntity(
          title: 'Información del tenant',
          description: 'Actualiza: nombre de la institución, logo, información de contacto.',
          iconName: 'business',
        ),
        HelpStepEntity(
          title: 'Módulos activos',
          description: 'Activa o desactiva módulos según las necesidades de tu institución.',
          iconName: 'apps',
        ),
        HelpStepEntity(
          title: 'Integraciones',
          description: 'Configura integraciones con sistemas externos, APIs o servicios de terceros.',
          iconName: 'link',
        ),
        HelpStepEntity(
          title: 'Guardar cambios',
          description: 'No olvides guardar los cambios. Algunos pueden requerir reinicio de sesión.',
          iconName: 'save',
        ),
      ],
    ),

    // ===== USO GENERAL =====
    HelpTopicEntity(
      id: 'navigation',
      title: '¿Cómo navegar por la aplicación?',
      description: 'Conoce la estructura y navegación básica de CliniDocs.',
      category: HelpCategory.generalUsage,
      tags: ['navegación', 'menú', 'uso', 'básico'],
      roles: [],
      steps: [
        HelpStepEntity(
          title: 'Menú principal',
          description: 'Toca el ícono de menú (☰) en la esquina superior izquierda para ver todas las opciones.',
          iconName: 'menu',
        ),
        HelpStepEntity(
          title: 'Barra inferior',
          description: 'La barra inferior te da acceso rápido a: Inicio, Pacientes, Notificaciones y Perfil.',
          iconName: 'navigation',
        ),
        HelpStepEntity(
          title: 'Búsqueda global',
          description: 'Usa el ícono de lupa (🔍) para buscar pacientes, historias o usuarios rápidamente.',
          iconName: 'search',
        ),
        HelpStepEntity(
          title: 'Botón de retroceso',
          description: 'Usa la flecha de retroceso (←) para volver a la pantalla anterior.',
          iconName: 'arrow_back',
        ),
        HelpStepEntity(
          title: 'Perfil de usuario',
          description: 'Toca tu foto o nombre en el menú para ver tu perfil, configuración y cerrar sesión.',
          iconName: 'account_circle',
        ),
      ],
    ),

    HelpTopicEntity(
      id: 'notifications',
      title: '¿Cómo funcionan las notificaciones?',
      description: 'Gestiona y responde a notificaciones del sistema.',
      category: HelpCategory.generalUsage,
      tags: ['notificaciones', 'alertas', 'avisos'],
      roles: [],
      steps: [
        HelpStepEntity(
          title: 'Acceder a notificaciones',
          description: 'Toca el ícono de campana (🔔) en la barra inferior o superior.',
          iconName: 'notifications',
        ),
        HelpStepEntity(
          title: 'Tipos de notificaciones',
          description: 'Recibirás alertas sobre: nuevas asignaciones, citas, resultados de laboratorio, mensajes, etc.',
          iconName: 'info',
        ),
        HelpStepEntity(
          title: 'Marcar como leída',
          description: 'Toca una notificación para verla y marcarla como leída automáticamente.',
          iconName: 'mark_email_read',
        ),
        HelpStepEntity(
          title: 'Configurar notificaciones',
          description: 'En tu perfil > Configuración, puedes activar/desactivar tipos específicos de notificaciones.',
          iconName: 'settings',
        ),
      ],
    ),
  ];
}
