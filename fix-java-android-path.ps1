# Script untuk memperbaiki Java dan Android PATH
# Jalankan di PowerShell: .\fix-java-android-path.ps1

Write-Host "=== FIXING JAVA AND ANDROID PATH ===" -ForegroundColor Cyan
Write-Host ""

# 1. Fix Java PATH (pastikan Java 17 digunakan, bukan Java 8)
Write-Host "1. Memperbaiki Java PATH..." -ForegroundColor Yellow
$env:JAVA_HOME = [System.Environment]::GetEnvironmentVariable("JAVA_HOME","User")

if (-not $env:JAVA_HOME) {
    Write-Host "   ERROR: JAVA_HOME tidak ditemukan!" -ForegroundColor Red
    Write-Host "   Pastikan JAVA_HOME sudah di-set di Environment Variables." -ForegroundColor Red
    exit 1
}

Write-Host "   JAVA_HOME: $env:JAVA_HOME" -ForegroundColor Gray

$java17Path = "$env:JAVA_HOME\bin"
if (Test-Path $java17Path) {
    # Pindahkan Java 17 ke depan PATH
    $paths = ($env:Path -split ';') | Where-Object { 
        $_ -ne $java17Path -and $_ -ne "$env:JAVA_HOME\bin"
    }
    $env:Path = "$java17Path;" + ($paths -join ';')
    Write-Host "   [OK] Java PATH diperbaiki" -ForegroundColor Green
} else {
    Write-Host "   ERROR: Folder tidak ditemukan: $java17Path" -ForegroundColor Red
    exit 1
}

# Verifikasi Java version
Write-Host ""
Write-Host "   Java version sekarang:" -ForegroundColor Cyan
java -version
Write-Host ""

# 2. Fix Android PATH
Write-Host "2. Menambahkan Android paths ke PATH..." -ForegroundColor Yellow
$androidPaths = @(
    "D:\Android\cmdline-tools\latest\bin",
    "D:\Android\platform-tools"
)

foreach ($path in $androidPaths) {
    if ($env:Path -notlike "*$path*") {
        if (Test-Path $path) {
            $env:Path = "$path;$env:Path"
            Write-Host "   [OK] Ditambahkan: $path" -ForegroundColor Green
        } else {
            Write-Host "   ! Tidak ditemukan (skip): $path" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   - Sudah ada: $path" -ForegroundColor Gray
    }
}

# 3. Verifikasi Setup
Write-Host ""
Write-Host "=== VERIFIKASI SETUP ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "Java version:" -ForegroundColor White
java -version
Write-Host ""

Write-Host "JAVA_HOME: $env:JAVA_HOME" -ForegroundColor White
Write-Host ""

Write-Host "Android paths di PATH:" -ForegroundColor White
$androidInPath = $env:PATH -split ';' | Select-String "Android"
if ($androidInPath) {
    $androidInPath | ForEach-Object { Write-Host "  [OK] $_" -ForegroundColor Green }
} else {
    Write-Host "  ! Tidak ada Android paths di PATH" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== TESTING SDKMANAGER ===" -ForegroundColor Cyan

# Test sdkmanager
$sdkmanagerPath = "D:\Android\cmdline-tools\latest\bin\sdkmanager.bat"
if (Test-Path $sdkmanagerPath) {
    Write-Host "Testing sdkmanager..." -ForegroundColor Yellow
    try {
        & $sdkmanagerPath --version
        Write-Host "[OK] sdkmanager berfungsi!" -ForegroundColor Green
    } catch {
        Write-Host "! Error saat menjalankan sdkmanager:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
} else {
    Write-Host "! File tidak ditemukan: $sdkmanagerPath" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== CATATAN PENTING ===" -ForegroundColor Yellow
Write-Host "Perbaikan ini HANYA untuk session PowerShell saat ini." -ForegroundColor White
Write-Host "Untuk perbaikan PERMANEN:" -ForegroundColor White
Write-Host "1. Buka Environment Variables (Win+R -> sysdm.cpl)" -ForegroundColor White
Write-Host "2. Pastikan %JAVA_HOME%\bin ada di User Path DI ATAS (prioritas tinggi)" -ForegroundColor White
Write-Host "3. Pastikan D:\Android\cmdline-tools\latest\bin ada di Path" -ForegroundColor White
Write-Host "4. Pastikan D:\Android\platform-tools ada di Path" -ForegroundColor White
Write-Host "5. Hapus atau pindahkan Java 8 dari Path (jika ada)" -ForegroundColor White
Write-Host "6. Restart PowerShell setelah mengedit Environment Variables" -ForegroundColor White
