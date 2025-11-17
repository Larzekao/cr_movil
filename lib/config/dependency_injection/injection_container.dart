import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/environment/environment.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/network_info.dart';

// Features - Auth
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Features - Patients
import '../../features/patients/data/datasources/patient_remote_datasource.dart';
import '../../features/patients/data/repositories/patient_repository_impl.dart';
import '../../features/patients/domain/repositories/patient_repository.dart';
import '../../features/patients/domain/usecases/get_patients_usecase.dart';
import '../../features/patients/domain/usecases/get_patient_detail_usecase.dart';
import '../../features/patients/domain/usecases/create_patient_usecase.dart';
import '../../features/patients/domain/usecases/update_patient_usecase.dart';
import '../../features/patients/domain/usecases/delete_patient_usecase.dart';
import '../../features/patients/presentation/bloc/patient_bloc.dart';

// Features - Clinical Records
import '../../features/clinical_records/data/datasources/clinical_record_remote_datasource.dart';
import '../../features/clinical_records/data/repositories/clinical_record_repository_impl.dart';
import '../../features/clinical_records/domain/repositories/clinical_record_repository.dart';
import '../../features/clinical_records/domain/usecases/get_clinical_records_usecase.dart';
import '../../features/clinical_records/domain/usecases/get_clinical_record_detail_usecase.dart';
import '../../features/clinical_records/domain/usecases/create_clinical_record_usecase.dart';
import '../../features/clinical_records/domain/usecases/update_clinical_record_usecase.dart';
import '../../features/clinical_records/domain/usecases/delete_clinical_record_usecase.dart';
import '../../features/clinical_records/presentation/bloc/clinical_record_bloc.dart';

// Features - Documents
import '../../features/documents/data/datasources/document_remote_datasource.dart';
import '../../features/documents/data/repositories/document_repository_impl.dart';
import '../../features/documents/domain/repositories/document_repository.dart';
import '../../features/documents/domain/usecases/get_documents_usecase.dart';
import '../../features/documents/domain/usecases/get_document_by_id_usecase.dart';
import '../../features/documents/domain/usecases/create_document_usecase.dart';
import '../../features/documents/domain/usecases/update_document_usecase.dart';
import '../../features/documents/domain/usecases/delete_document_usecase.dart';
import '../../features/documents/domain/usecases/upload_document_usecase.dart';
import '../../features/documents/presentation/bloc/document_bloc.dart';

final sl = GetIt.instance;

/// Inicializa todas las dependencias de la aplicación
///
/// Este método debe ser llamado en main() antes de runApp()
///
/// Ejemplo:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await di.init();
///   runApp(MyApp());
/// }
/// ```
Future<void> init() async {
  // =========================================================================
  // External Dependencies (Third-party libraries)
  // =========================================================================

  // SharedPreferences - Para almacenamiento simple
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // FlutterSecureStorage - Para almacenamiento seguro de tokens
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  sl.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);

  // =========================================================================
  // Core Dependencies
  // =========================================================================

  // Dio - Cliente HTTP base
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.options.baseUrl = Environment.apiBaseUrl;
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    return dio;
  });

  // DioClient - Cliente HTTP con interceptores personalizados
  sl.registerLazySingleton<DioClient>(
    () => DioClient(dio: sl<Dio>(), storage: sl<FlutterSecureStorage>()),
  );

  // NetworkInfo - Verificador de conectividad
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfo());

  // =========================================================================
  // Features
  // =========================================================================

  _initAuth();
  _initPatients();
  _initClinicalRecords();
  _initDocuments();
}

/// Inicializa las dependencias del feature de autenticación
///
/// Incluye:
/// - DataSources (Local y Remote)
/// - Repository
/// - Use Cases
/// - BLoC
void _initAuth() {
  // =========================================================================
  // Data Layer
  // =========================================================================

  // DataSources - Fuentes de datos
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(storage: sl<FlutterSecureStorage>()),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl<DioClient>()),
  );

  // Repository - Implementación del repositorio
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      localDataSource: sl<AuthLocalDataSource>(),
      remoteDataSource: sl<AuthRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // =========================================================================
  // Domain Layer
  // =========================================================================

  // Use Cases - Casos de uso de negocio
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(sl<AuthRepository>()),
  );

  // =========================================================================
  // Presentation Layer
  // =========================================================================

  // BLoC - Gestión de estado (Factory para crear nueva instancia cada vez)
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
    ),
  );
}

/// Inicializa las dependencias del feature de pacientes
///
/// Incluye:
/// - DataSources (Remote)
/// - Repository
/// - Use Cases
/// - BLoC
void _initPatients() {
  // =========================================================================
  // Data Layer
  // =========================================================================

  // DataSources
  sl.registerLazySingleton<PatientRemoteDataSource>(
    () => PatientRemoteDataSourceImpl(dioClient: sl<DioClient>()),
  );

  // Repository
  sl.registerLazySingleton<PatientRepository>(
    () =>
        PatientRepositoryImpl(remoteDataSource: sl<PatientRemoteDataSource>()),
  );

  // =========================================================================
  // Domain Layer
  // =========================================================================

  // Use Cases
  sl.registerLazySingleton<GetPatientsUseCase>(
    () => GetPatientsUseCase(sl<PatientRepository>()),
  );

  sl.registerLazySingleton<GetPatientDetailUseCase>(
    () => GetPatientDetailUseCase(sl<PatientRepository>()),
  );

  sl.registerLazySingleton<CreatePatientUseCase>(
    () => CreatePatientUseCase(sl<PatientRepository>()),
  );

  sl.registerLazySingleton<UpdatePatientUseCase>(
    () => UpdatePatientUseCase(sl<PatientRepository>()),
  );

  sl.registerLazySingleton<DeletePatientUseCase>(
    () => DeletePatientUseCase(sl<PatientRepository>()),
  );

  // =========================================================================
  // Presentation Layer
  // =========================================================================

  // BLoC
  sl.registerFactory<PatientBloc>(
    () => PatientBloc(
      getPatientsUseCase: sl<GetPatientsUseCase>(),
      getPatientDetailUseCase: sl<GetPatientDetailUseCase>(),
      createPatientUseCase: sl<CreatePatientUseCase>(),
      updatePatientUseCase: sl<UpdatePatientUseCase>(),
      deletePatientUseCase: sl<DeletePatientUseCase>(),
    ),
  );
}

/// Inicializa las dependencias del feature de historias clínicas
///
/// Incluye:
/// - DataSources (Remote)
/// - Repository
/// - Use Cases
/// - BLoC
void _initClinicalRecords() {
  // =========================================================================
  // Data Layer
  // =========================================================================

  // DataSources
  sl.registerLazySingleton<ClinicalRecordRemoteDataSource>(
    () => ClinicalRecordRemoteDataSourceImpl(dioClient: sl<DioClient>()),
  );

  // Repository
  sl.registerLazySingleton<ClinicalRecordRepository>(
    () => ClinicalRecordRepositoryImpl(
      remoteDataSource: sl<ClinicalRecordRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // =========================================================================
  // Domain Layer
  // =========================================================================

  // Use Cases
  sl.registerLazySingleton<GetClinicalRecordsUseCase>(
    () => GetClinicalRecordsUseCase(sl<ClinicalRecordRepository>()),
  );

  sl.registerLazySingleton<GetClinicalRecordDetailUseCase>(
    () => GetClinicalRecordDetailUseCase(sl<ClinicalRecordRepository>()),
  );

  sl.registerLazySingleton<CreateClinicalRecordUseCase>(
    () => CreateClinicalRecordUseCase(sl<ClinicalRecordRepository>()),
  );

  sl.registerLazySingleton<UpdateClinicalRecordUseCase>(
    () => UpdateClinicalRecordUseCase(sl<ClinicalRecordRepository>()),
  );

  sl.registerLazySingleton<DeleteClinicalRecordUseCase>(
    () => DeleteClinicalRecordUseCase(sl<ClinicalRecordRepository>()),
  );

  // =========================================================================
  // Presentation Layer
  // =========================================================================

  // BLoC
  sl.registerFactory<ClinicalRecordBloc>(
    () => ClinicalRecordBloc(
      getClinicalRecordsUseCase: sl<GetClinicalRecordsUseCase>(),
      getClinicalRecordDetailUseCase: sl<GetClinicalRecordDetailUseCase>(),
      createClinicalRecordUseCase: sl<CreateClinicalRecordUseCase>(),
      updateClinicalRecordUseCase: sl<UpdateClinicalRecordUseCase>(),
      deleteClinicalRecordUseCase: sl<DeleteClinicalRecordUseCase>(),
    ),
  );
}

/// Inicializa las dependencias del feature de documentos
///
/// Incluye:
/// - DataSources (Remote)
/// - Repository
/// - Use Cases
/// - BLoC
void _initDocuments() {
  // =========================================================================
  // Data Layer
  // =========================================================================

  // DataSources
  sl.registerLazySingleton<DocumentRemoteDataSource>(
    () => DocumentRemoteDataSourceImpl(client: sl<DioClient>()),
  );

  // Repository
  sl.registerLazySingleton<DocumentRepository>(
    () => DocumentRepositoryImpl(
      remoteDataSource: sl<DocumentRemoteDataSource>(),
    ),
  );

  // =========================================================================
  // Domain Layer
  // =========================================================================

  // Use Cases
  sl.registerLazySingleton<GetDocumentsUseCase>(
    () => GetDocumentsUseCase(sl<DocumentRepository>()),
  );

  sl.registerLazySingleton<GetDocumentByIdUseCase>(
    () => GetDocumentByIdUseCase(sl<DocumentRepository>()),
  );

  sl.registerLazySingleton<CreateDocumentUseCase>(
    () => CreateDocumentUseCase(sl<DocumentRepository>()),
  );

  sl.registerLazySingleton<UpdateDocumentUseCase>(
    () => UpdateDocumentUseCase(sl<DocumentRepository>()),
  );

  sl.registerLazySingleton<DeleteDocumentUseCase>(
    () => DeleteDocumentUseCase(sl<DocumentRepository>()),
  );

  sl.registerLazySingleton<UploadDocumentUseCase>(
    () => UploadDocumentUseCase(sl<DocumentRepository>()),
  );

  // =========================================================================
  // Presentation Layer
  // =========================================================================

  // BLoC
  sl.registerFactory<DocumentBloc>(
    () => DocumentBloc(
      getDocumentsUseCase: sl<GetDocumentsUseCase>(),
      getDocumentByIdUseCase: sl<GetDocumentByIdUseCase>(),
      createDocumentUseCase: sl<CreateDocumentUseCase>(),
      updateDocumentUseCase: sl<UpdateDocumentUseCase>(),
      deleteDocumentUseCase: sl<DeleteDocumentUseCase>(),
      uploadDocumentUseCase: sl<UploadDocumentUseCase>(),
    ),
  );
}
