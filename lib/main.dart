import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/dependency_injection/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/home_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/patients/presentation/bloc/patient_bloc.dart';
import 'features/patients/presentation/pages/patients_list_page.dart';
import 'features/documents/presentation/bloc/document_bloc.dart';
import 'features/documents/presentation/pages/documents_list_page.dart';
import 'features/clinical_records/presentation/bloc/clinical_record_bloc.dart';
import 'features/clinical_records/presentation/pages/clinical_records_list_page.dart';
import 'features/clinical_records/presentation/pages/clinical_record_detail_page.dart';
import 'features/clinical_records/presentation/pages/clinical_record_form_page.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';
import 'features/notifications/presentation/bloc/notification_event.dart';
import 'core/services/notification_service.dart';
import 'features/help/presentation/bloc/help_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");

  // Inicializar inyección de dependencias
  await di.init();

  // Inicializar NotificationService para obtener token FCM
  final notificationService = di.sl<NotificationService>();
  await notificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<AuthBloc>()),
        BlocProvider(create: (context) => di.sl<PatientBloc>()),
        BlocProvider(create: (context) => di.sl<DocumentBloc>()),
        BlocProvider(create: (context) => di.sl<ClinicalRecordBloc>()),
        BlocProvider(
          create: (context) {
            final bloc = di.sl<NotificationBloc>();
            // Inicializar notificaciones automáticamente
            bloc.add(const InitializeNotifications());
            return bloc;
          },
        ),
        BlocProvider(create: (context) => HelpBloc()),
      ],
      child: MaterialApp(
        title: 'CliniDocs Mobile',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const SplashPage(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/splash': (context) => const SplashPage(),
          '/home': (context) => const HomePage(),
          '/patients': (context) => const PatientsListPage(),
          '/documents': (context) => const DocumentsListPage(),
          '/clinical-records': (context) => const ClinicalRecordsListPage(),
        },
        onGenerateRoute: (settings) {
          // Rutas con parámetros
          if (settings.name == '/clinical-record-detail') {
            final clinicalRecordId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) =>
                  ClinicalRecordDetailPage(clinicalRecordId: clinicalRecordId),
            );
          }
          if (settings.name == '/clinical-record-create') {
            return MaterialPageRoute(
              builder: (context) => const ClinicalRecordFormPage(),
            );
          }
          if (settings.name == '/clinical-record-edit') {
            final clinicalRecordId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) =>
                  ClinicalRecordFormPage(clinicalRecordId: clinicalRecordId),
            );
          }
          return null;
        },
      ),
    );
  }
}
