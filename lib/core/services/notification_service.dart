import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';

/// Handler para mensajes en background (DEBE estar fuera de la clase)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  Logger().i('📨 Mensaje en background: ${message.notification?.title}');
}

/// Servicio para gestionar las notificaciones push de Firebase Cloud Messaging
///
/// VERSIÓN SIMPLIFICADA: Sin notificaciones locales (flutter_local_notifications)
/// Las notificaciones se muestran automáticamente por el sistema Android
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  FirebaseMessaging? _fcm;  // Lazy initialization
  final Logger _logger = Logger();

  String? _fcmToken;
  Function(String)? onTokenReceived;
  Function(RemoteMessage)? onMessageTap;

  factory NotificationService() => _instance;

  NotificationService._internal();

  String? get fcmToken => _fcmToken;

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    try {
      _logger.i('🔧 Inicializando NotificationService...');

      // 1. Inicializar Firebase (solo si no está inicializado)
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
        _logger.i('✅ Firebase inicializado');
      } else {
        _logger.i('ℹ️ Firebase ya estaba inicializado');
      }

      // Inicializar FirebaseMessaging DESPUÉS de que Firebase esté listo
      _fcm = FirebaseMessaging.instance;

      // 2. Solicitar permisos de notificación
      final NotificationSettings? settings = await _fcm?.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings?.authorizationStatus == AuthorizationStatus.authorized) {
        _logger.i('✅ Permisos de notificación concedidos');
      } else if (settings?.authorizationStatus ==
          AuthorizationStatus.provisional) {
        _logger.w('⚠️ Permisos provisionales concedidos');
      } else {
        _logger.e('❌ Permisos de notificación denegados');
        return;
      }

      // 3. Obtener token FCM
      await _getToken();

      // 4. Configurar handlers
      _setupMessageHandlers();

      _logger.i('✅ NotificationService inicializado correctamente');
    } catch (e, stackTrace) {
      _logger.e('❌ Error inicializando NotificationService', error: e, stackTrace: stackTrace);
    }
  }

  /// Obtiene el token FCM del dispositivo
  Future<void> _getToken() async {
    try {
      _fcmToken = await _fcm?.getToken();

      if (_fcmToken != null) {
        _logger.i('📱 Token FCM obtenido: ${_fcmToken!.substring(0, 20)}...');

        if (onTokenReceived != null) {
          onTokenReceived!(_fcmToken!);
        }
      } else {
        _logger.e('❌ No se pudo obtener el token FCM');
      }
    } catch (e) {
      _logger.e('❌ Error obteniendo token FCM', error: e);
    }
  }

  /// Configura los handlers para mensajes push
  void _setupMessageHandlers() {
    // Handler para mensajes cuando la app está en FOREGROUND
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handler para cuando el usuario toca una notificación
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handler para mensajes en BACKGROUND
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Escuchar cambios de token
    _fcm?.onTokenRefresh.listen((newToken) {
      _logger.i('🔄 Token FCM renovado: ${newToken.substring(0, 20)}...');
      _fcmToken = newToken;

      if (onTokenReceived != null) {
        onTokenReceived!(newToken);
      }
    });

    _logger.i('✅ Handlers de mensajes configurados');
  }

  /// Maneja mensajes cuando la app está en FOREGROUND
  void _handleForegroundMessage(RemoteMessage message) {
    _logger.i('📲 Mensaje en foreground: ${message.notification?.title}');
    // Las notificaciones en foreground las muestra automáticamente Android
    // No necesitamos flutter_local_notifications
  }

  /// Maneja el tap en una notificación
  void _handleNotificationTap(RemoteMessage message) {
    _logger.i('👆 Usuario tocó notificación: ${message.data}');

    if (onMessageTap != null) {
      onMessageTap!(message);
    }
  }

  /// Obtiene el token FCM actual
  Future<String?> getToken() async {
    if (_fcmToken != null) {
      return _fcmToken;
    }
    return await _fcm?.getToken();
  }

  /// Elimina el token FCM actual
  Future<void> deleteToken() async {
    try {
      await _fcm?.deleteToken();
      _fcmToken = null;
      _logger.i('✅ Token FCM eliminado');
    } catch (e) {
      _logger.e('❌ Error eliminando token FCM', error: e);
    }
  }

  /// Suscribe al dispositivo a un topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm?.subscribeToTopic(topic);
      _logger.i('✅ Suscrito al topic: $topic');
    } catch (e) {
      _logger.e('❌ Error suscribiendo al topic', error: e);
    }
  }

  /// Desuscribe al dispositivo de un topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm?.unsubscribeFromTopic(topic);
      _logger.i('✅ Desuscrito del topic: $topic');
    } catch (e) {
      _logger.e('❌ Error desuscribiendo del topic', error: e);
    }
  }
}
