# ============================================================================
# REBUILD Y RUN - CLINIC RECORDS MOBILE
# ============================================================================

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  REBUILD Y RUN - FLUTTER APP" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

# 1. Limpiar cache
Write-Host "1️⃣  Limpiando cache..." -ForegroundColor Yellow
flutter clean

# 2. Obtener dependencias
Write-Host "`n2️⃣  Obteniendo dependencias..." -ForegroundColor Yellow
flutter pub get

# 3. Regenerar código generado
Write-Host "`n3️⃣  Regenerando código (json_serializable)..." -ForegroundColor Yellow
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Verificar dispositivos
Write-Host "`n4️⃣  Verificando dispositivos..." -ForegroundColor Yellow
flutter devices

# 5. Ejecutar en modo debug
Write-Host "`n5️⃣  Ejecutando en modo debug..." -ForegroundColor Green
Write-Host "📱 La app se ejecutará con logging habilitado" -ForegroundColor Cyan
Write-Host "🔍 Revisa los logs en consola para ver errores detallados" -ForegroundColor Cyan
Write-Host ""

flutter run --verbose

Write-Host "`n✅ Proceso completado" -ForegroundColor Green
