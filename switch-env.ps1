param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('dev','prod','staging')]
    [string]$env
)

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Cambiando Ambiente de la App" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que el archivo .env existe
$sourceFile = ".env.$env"
if (-not (Test-Path $sourceFile)) {
    Write-Host "ERROR: El archivo $sourceFile no existe" -ForegroundColor Red
    exit 1
}

# Copiar archivo de ambiente
Write-Host "► Copiando $sourceFile a .env..." -ForegroundColor Yellow
Copy-Item $sourceFile ".env" -Force

# Limpiar build
Write-Host "► Limpiando build anterior..." -ForegroundColor Yellow
flutter clean | Out-Null

# Obtener dependencias
Write-Host "► Descargando dependencias..." -ForegroundColor Yellow
flutter pub get | Out-Null

Write-Host ""
Write-Host "✅ Ambiente cambiado exitosamente a: $env" -ForegroundColor Green
Write-Host ""

# Mostrar configuración actual
Write-Host "Configuración actual:" -ForegroundColor Cyan
Get-Content .env | Select-String "API_BASE_URL|ENVIRONMENT" | ForEach-Object {
    Write-Host "  $_" -ForegroundColor White
}

Write-Host ""
Write-Host "Ejecuta 'flutter run' para iniciar la app" -ForegroundColor Yellow
Write-Host ""
