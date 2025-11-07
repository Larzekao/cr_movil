# Configuración de URLs - CliniDocs

## Resumen de Configuración Actual

### Backend (Django)
- **Puerto:** `8000`
- **Base URL:** `http://localhost:8000`
- **API Base URL:** `http://localhost:8000/api`
- **Base de Datos:** PostgreSQL - `DG_Clinica`
- **Usuario DB:** `postgres`
- **Puerto DB:** `5432`

### Frontend (React + Vite)
- **Puerto:** `5173`
- **Base URL:** `http://localhost:5173`
- **API Config:** `http://localhost:8000/api` (desde frontend)

### App Móvil (Flutter)
- **Android Emulator:** `http://10.0.2.2:8000/api`
- **iOS Simulator:** `http://localhost:8000/api`
- **Dispositivo Físico:** `http://[TU_IP_LOCAL]:8000/api`

---

## URLs según el Dispositivo

### 1️⃣ Android Emulator

**Archivo `.env`:**
```env
API_BASE_URL=http://10.0.2.2:8000/api
```

**¿Por qué `10.0.2.2`?**
- El emulador de Android usa `10.0.2.2` para referirse al `localhost` de tu máquina host
- `localhost` en el emulador se refiere al emulador mismo, no a tu máquina

**Verificar backend esté corriendo:**
```bash
cd cr_backend
python manage.py runserver 0.0.0.0:8000
```

---

### 2️⃣ iOS Simulator

**Archivo `.env`:**
```env
API_BASE_URL=http://localhost:8000/api
```

**¿Por qué `localhost`?**
- El simulador de iOS comparte la red con tu máquina host
- Puede usar directamente `localhost`

**Verificar backend esté corriendo:**
```bash
cd cr_backend
python manage.py runserver
```

---

### 3️⃣ Dispositivo Físico (Android/iOS)

**Paso 1: Obtener tu IP local**

**Windows:**
```bash
ipconfig
# Buscar "IPv4 Address" en la sección de tu adaptador de red
# Ejemplo: 192.168.1.100
```

**macOS/Linux:**
```bash
ifconfig
# O también:
hostname -I
```

**Paso 2: Actualizar `.env`**
```env
API_BASE_URL=http://192.168.1.100:8000/api
# Reemplaza 192.168.1.100 con tu IP real
```

**Paso 3: Backend debe aceptar conexiones externas**

Actualizar `cr_backend/.env`:
```env
ALLOWED_HOSTS=localhost,127.0.0.1,192.168.1.100
```

Ejecutar backend:
```bash
cd cr_backend
python manage.py runserver 0.0.0.0:8000
```

**Paso 4: Verificar firewall**
- Asegúrate que el puerto 8000 esté abierto en tu firewall
- Windows: Permitir Python en el firewall
- macOS: System Preferences → Security & Privacy → Firewall

---

## Estructura de Endpoints (Backend)

Basado en tu configuración de `api.config.ts`:

### Autenticación
```
POST   /api/login/              # Login
POST   /api/logout/             # Logout
POST   /api/refresh/            # Refresh token
GET    /api/users/me/           # Usuario actual
```

### Pacientes
```
GET    /api/patients/           # Listar pacientes
GET    /api/patients/{id}/      # Detalle de paciente
POST   /api/patients/           # Crear paciente
PUT    /api/patients/{id}/      # Actualizar paciente
DELETE /api/patients/{id}/      # Eliminar paciente
```

### Historias Clínicas
```
GET    /api/clinical-records/           # Listar historias
GET    /api/clinical-records/{id}/      # Detalle
POST   /api/clinical-records/           # Crear
PUT    /api/clinical-records/{id}/      # Actualizar
DELETE /api/clinical-records/{id}/      # Eliminar
```

### Documentos
```
GET    /api/documents/           # Listar documentos
GET    /api/documents/{id}/      # Detalle
POST   /api/documents/upload/    # Subir documento
PUT    /api/documents/{id}/      # Actualizar
DELETE /api/documents/{id}/      # Eliminar
```

### Auditoría
```
GET    /api/audit/               # Listar logs
GET    /api/audit/{id}/          # Detalle de log
```

### Reportes
```
POST   /api/reports/generator/generate/    # Generar reporte
GET    /api/reports/executions/            # Listar ejecuciones
```

---

## Configuración de CORS (Backend)

Tu backend ya está configurado para aceptar estas URLs:

**Archivo `cr_backend/.env`:**
```env
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173,http://localhost:5174
```

**Si usas dispositivo físico, agregar tu IP:**
```env
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173,http://localhost:5174,http://192.168.1.100:5173
```

---

## JWT Tokens

**Configuración (Backend `.env`):**
```env
JWT_ACCESS_TOKEN_LIFETIME=60         # 60 minutos
JWT_REFRESH_TOKEN_LIFETIME=1440      # 1440 minutos (24 horas)
```

**Flujo de Autenticación:**

1. **Login** → Devuelve `access_token` y `refresh_token`
2. **Requests** → Usar `access_token` en header: `Authorization: Bearer {token}`
3. **Token expirado (401)** → Usar `refresh_token` para obtener nuevo `access_token`
4. **Refresh token expirado** → Hacer login nuevamente

---

## Testing de Conexión

### 1. Verificar Backend

```bash
# Iniciar backend
cd cr_backend
python manage.py runserver 0.0.0.0:8000

# En otra terminal, probar endpoint
curl http://localhost:8000/api/
```

### 2. Verificar Frontend

```bash
cd cr_frontend
npm run dev
# Abrir http://localhost:5173
```

### 3. Verificar App Móvil

**Android Emulator:**
```bash
cd cr_movil
flutter run

# Verificar que .env tenga:
# API_BASE_URL=http://10.0.2.2:8000/api
```

**iOS Simulator:**
```bash
cd cr_movil
flutter run -d ios

# Verificar que .env tenga:
# API_BASE_URL=http://localhost:8000/api
```

---

## Troubleshooting

### ❌ Error: "Network Error" o "Connection refused"

**Solución:**
1. Verificar que el backend esté corriendo: `http://localhost:8000`
2. Verificar la URL en `.env` de la app móvil
3. Para Android Emulator, usar `10.0.2.2` en vez de `localhost`
4. Para dispositivo físico, usar la IP local de tu máquina

### ❌ Error: "CORS policy"

**Solución:**
1. Agregar la URL a `CORS_ALLOWED_ORIGINS` en backend `.env`
2. Reiniciar el servidor backend
3. Verificar que el frontend/móvil use la URL correcta

### ❌ Error: "401 Unauthorized"

**Solución:**
1. Verificar que el token esté en el header: `Authorization: Bearer {token}`
2. Verificar que el token no haya expirado
3. Intentar hacer login nuevamente

### ❌ Error: "404 Not Found"

**Solución:**
1. Verificar que la URL del endpoint sea correcta
2. Asegurarse de incluir `/api/` en la base URL
3. Verificar que el endpoint exista en el backend

### ❌ Backend no acepta conexiones externas

**Solución:**
1. Ejecutar con: `python manage.py runserver 0.0.0.0:8000`
2. Agregar IP a `ALLOWED_HOSTS` en backend `.env`
3. Verificar firewall

---

## Configuración Recomendada por Ambiente

### Desarrollo Local (mismo equipo)

**Backend:**
```bash
python manage.py runserver 0.0.0.0:8000
```

**Frontend:**
```bash
npm run dev
# http://localhost:5173
```

**App Móvil (Android Emulator):**
```env
API_BASE_URL=http://10.0.2.2:8000/api
```

**App Móvil (iOS Simulator):**
```env
API_BASE_URL=http://localhost:8000/api
```

### Testing en Dispositivo Físico

1. Obtener IP local: `ipconfig` (Windows) o `ifconfig` (Mac/Linux)
2. Backend `.env`:
   ```env
   ALLOWED_HOSTS=localhost,127.0.0.1,192.168.1.100
   CORS_ALLOWED_ORIGINS=http://localhost:5173,http://192.168.1.100:5173
   ```
3. App Móvil `.env`:
   ```env
   API_BASE_URL=http://192.168.1.100:8000/api
   ```
4. Ejecutar backend:
   ```bash
   python manage.py runserver 0.0.0.0:8000
   ```

---

## Cambiar entre Ambientes

### Método 1: Actualizar `.env`

Editar `cr_movil/.env` y cambiar `API_BASE_URL`

```bash
# Después de cambiar, recompilar:
flutter clean
flutter pub get
flutter run
```

### Método 2: Variables de entorno en tiempo de ejecución

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8000/api
```

---

## Resumen Rápido

| Dispositivo | URL a usar |
|-------------|------------|
| Android Emulator | `http://10.0.2.2:8000/api` |
| iOS Simulator | `http://localhost:8000/api` |
| Dispositivo Físico | `http://[TU_IP]:8000/api` |
| Frontend (React) | `http://localhost:8000/api` |
| Backend | `http://0.0.0.0:8000` |

**Credenciales de prueba (si existen en tu backend):**
- Email: `admin@example.com` (o el que hayas creado)
- Password: (la que configuraste)

---

## Comandos Útiles

```bash
# Ver logs del backend
cd cr_backend
python manage.py runserver --verbosity 3

# Ver logs de Flutter
cd cr_movil
flutter logs

# Limpiar caché de Flutter
flutter clean
flutter pub get

# Resetear app móvil (eliminar data)
flutter clean
rm -rf build/
flutter run
```

---

¡Todo listo! Tu configuración de URLs está sincronizada entre Backend, Frontend y App Móvil. 🚀
