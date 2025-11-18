# ============================================================================
# Script para Build de Produccion - CliniDocs Mobile
# ============================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "BUILD DE PRODUCCION - CLINIDOCS MOBILE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar que estamos en la carpeta correcta
if (-Not (Test-Path "pubspec.yaml")) {
    Write-Host "Error: Debes ejecutar este script desde la carpeta cr_movil" -ForegroundColor Red
    exit 1
}

# 2. Verificar que existe .env.prod
if (-Not (Test-Path ".env.prod")) {
    Write-Host "Error: No se encontro el archivo .env.prod" -ForegroundColor Red
    exit 1
}

Write-Host "Archivo .env.prod encontrado" -ForegroundColor Green

# 2.5. IMPORTANTE: Copiar .env.prod a .env para que Flutter lo cargue
Write-Host ""
Write-Host "Copiando .env.prod a .env para la compilacion..." -ForegroundColor Yellow
Copy-Item ".env.prod" ".env" -Force
Write-Host "✓ Archivo .env actualizado" -ForegroundColor Green

# 3. Verificar configuracion de firma
if (-Not (Test-Path "android/key.properties")) {
    Write-Host "ADVERTENCIA: No se encontro android/key.properties" -ForegroundColor Yellow
    Write-Host "   La APK se firmara con claves de debug (solo para testing)" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "¿Continuar de todos modos? (s/n)"
    if ($continue -ne "s") {
        Write-Host "Abortado por el usuario" -ForegroundColor Yellow
        exit 0
    }
} else {
    Write-Host "Configuracion de firma encontrada" -ForegroundColor Green
}

Write-Host ""
Write-Host "Limpiando builds anteriores..." -ForegroundColor Cyan
flutter clean

Write-Host ""
Write-Host "Obteniendo dependencias..." -ForegroundColor Cyan
flutter pub get

Write-Host ""
Write-Host "Construyendo APK de produccion..." -ForegroundColor Cyan
Write-Host "   Modo: Release" -ForegroundColor Gray
Write-Host "   Config: .env.prod" -ForegroundColor Gray
Write-Host "   Split por ABI: Sí (menor tamaño)" -ForegroundColor Gray
Write-Host ""

# Build con split-per-abi para generar APKs optimizadas
flutter build apk --release --split-per-abi --dart-define-from-file=.env.prod

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "================================" -ForegroundColor Green
    Write-Host "BUILD COMPLETADO EXITOSAMENTE" -ForegroundColor Green
    Write-Host "================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "APKs generadas:" -ForegroundColor Cyan
    
    $apkPath = "build\app\outputs\flutter-apk"
    if (Test-Path "$apkPath\app-armeabi-v7a-release.apk") {
        $size = (Get-Item "$apkPath\app-armeabi-v7a-release.apk").Length / 1MB
        $sizeFormatted = [math]::Round($size, 2)
        $msg = "   app-armeabi-v7a-release.apk  (" + $sizeFormatted + " MB) - ARM 32-bit"
        Write-Host $msg -ForegroundColor White
    }
    if (Test-Path "$apkPath\app-arm64-v8a-release.apk") {
        $size = (Get-Item "$apkPath\app-arm64-v8a-release.apk").Length / 1MB
        $sizeFormatted = [math]::Round($size, 2)
        $msg = "   app-arm64-v8a-release.apk    (" + $sizeFormatted + " MB) - ARM 64-bit (RECOMENDADO)"
        Write-Host $msg -ForegroundColor Green
    }
    if (Test-Path "$apkPath\app-x86_64-release.apk") {
        $size = (Get-Item "$apkPath\app-x86_64-release.apk").Length / 1MB
        $sizeFormatted = [math]::Round($size, 2)
        $msg = "   app-x86_64-release.apk       (" + $sizeFormatted + " MB) - x86 64-bit"
        Write-Host $msg -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "Ubicacion:" -ForegroundColor Cyan
    Write-Host "   $apkPath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Para instalar en dispositivo:" -ForegroundColor Cyan
    Write-Host "   adb install -r $apkPath\app-arm64-v8a-release.apk" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "La APK esta lista para distribucion" -ForegroundColor Green
    
} else {
    Write-Host ""
    Write-Host "================================" -ForegroundColor Red
    Write-Host "BUILD FALLIDO" -ForegroundColor Red
    Write-Host "================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Revisa los errores arriba para más detalles" -ForegroundColor Yellow
    exit 1
}
