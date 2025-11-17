# Guía de Conexión al Backend Desplegado

## 📋 Configuración de Ambientes

Tu app móvil tiene 3 archivos de configuración:

### 1. `.env` - Desarrollo Local (Default)
```
API_BASE_URL=http://10.0.2.2:8000/api
```
- Para desarrollo con backend local en tu máquina
- Funciona con Android Emulator

### 2. `.env.dev` - Desarrollo
```
API_BASE_URL=http://10.0.2.2:8000/api
```
- Mismo que `.env`

### 3. `.env.prod` - Producción AWS ✅
```
API_BASE_URL=http://52.0.69.138/api
```
- Conecta al backend desplegado en AWS EC2
- IP Pública: 52.0.69.138

---

## 🔄 Cambiar entre Ambientes

### Opción 1: Copiar manualmente
Para usar **PRODUCCIÓN (AWS)**:
```powershell
cd cr_movil
copy .env.prod .env
flutter clean
flutter pub get
```

Para usar **DESARROLLO (Local)**:
```powershell
cd cr_movil
copy .env.dev .env
flutter clean
flutter pub get
```

### Opción 2: Crear scripts (Recomendado)

#### Windows PowerShell
Crea `switch-env.ps1`:
```powershell
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('dev','prod')]
    [string]$env
)

Copy-Item ".env.$env" ".env" -Force
Write-Host "Ambiente cambiado a: $env" -ForegroundColor Green
flutter clean
flutter pub get
```

Uso:
```powershell
# Cambiar a producción
.\switch-env.ps1 prod

# Cambiar a desarrollo
.\switch-env.ps1 dev
```

---

## ✅ Verificar Conexión

Después de cambiar el ambiente, ejecuta:

```powershell
flutter run
```

### Logs esperados al conectar:
```
REQUEST[GET] => PATH: /auth/...
RESPONSE[200] => Success
```

### Si hay error de conexión:
```
DioException: Connection refused
```

**Solución:** Verifica que el backend AWS esté corriendo:
```bash
# Desde SSH a EC2
sudo systemctl status nginx
sudo systemctl status gunicorn
```

---

## 🔧 Configuración Actual

### Backend AWS EC2
- **IP Pública:** 52.0.69.138
- **API Base:** http://52.0.69.138/api
- **Base de datos:** PostgreSQL en RDS (172.31.0.117)

### Archivos Actualizados
- ✅ `.env.prod` - Configurado con IP de AWS
- ✅ `.env.dev` - Configurado para desarrollo local
- ✅ `.env` - Actualmente en modo desarrollo local

---

## 🚀 Próximos Pasos

1. **Para probar con producción:**
   ```powershell
   copy .env.prod .env
   flutter run
   ```

2. **Para volver a desarrollo:**
   ```powershell
   copy .env.dev .env
   flutter run
   ```

3. **Verificar que funciona:**
   - Abre la app
   - Intenta hacer login
   - Verifica que cargue datos del backend AWS

---

## 📱 Notas Importantes

### Para Dispositivo Físico
Si pruebas en un celular real conectado a WiFi:
- Asegúrate de estar en la misma red que permite salir a internet
- La URL `http://52.0.69.138/api` debería funcionar

### Para Emulador
- Android Emulator: Usa la configuración actual
- iOS Simulator: Cambia `10.0.2.2` por `localhost` en `.env.dev`

### Seguridad
⚠️ **IMPORTANTE:** El backend está usando HTTP (sin SSL)
- No subas credenciales reales en producción
- Configura HTTPS con certificado SSL para producción real

---

## 🐛 Troubleshooting

### Error: "Connection refused"
- Verifica que el backend esté corriendo: `curl http://52.0.69.138/api/`
- Revisa los Security Groups de AWS EC2 (puerto 80 debe estar abierto)

### Error: "401 Unauthorized"
- El token JWT expiró, haz login nuevamente

### Error: "No route to host"
- Verifica que la IP de AWS sea correcta: `52.0.69.138`
- Revisa que el servidor esté activo en AWS Console

---

**Última actualización:** 10 de noviembre de 2025
