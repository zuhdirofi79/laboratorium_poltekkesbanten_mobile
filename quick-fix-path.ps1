# Quick fix PATH untuk PowerShell Administrator
# Copy-paste isi script ini ke PowerShell Administrator

Write-Host "Memperbaiki PATH untuk session ini..." -ForegroundColor Cyan

# Reload JAVA_HOME
$env:JAVA_HOME = [System.Environment]::GetEnvironmentVariable("JAVA_HOME","User")
Write-Host "JAVA_HOME: $env:JAVA_HOME"

# Fix Java PATH (prioritas Java 17/21)
$java17Path = "$env:JAVA_HOME\bin"
if (Test-Path $java17Path) {
    $paths = ($env:Path -split ';') | Where-Object { 
        $_ -ne $java17Path -and $_ -ne "$env:JAVA_HOME\bin"
    }
    $env:Path = "$java17Path;" + ($paths -join ';')
    Write-Host "[OK] Java PATH diperbaiki" -ForegroundColor Green
}

# Tambahkan Android paths
$androidPaths = @(
    "D:\Android\cmdline-tools\latest\bin",
    "D:\Android\platform-tools"
)

foreach ($path in $androidPaths) {
    if ($env:Path -notlike "*$path*") {
        if (Test-Path $path) {
            $env:Path = "$path;$env:Path"
            Write-Host "[OK] Ditambahkan: $path" -ForegroundColor Green
        }
    }
}

# Verifikasi
Write-Host "`nVerifikasi:" -ForegroundColor Cyan
Write-Host "Java version:"
java -version 2>&1 | Select-Object -First 1
Write-Host "`nAndroid paths:"
$env:PATH -split ';' | Select-String "Android"
Write-Host "`nTest sdkmanager:"
$env:PATH -split ';' | Select-String "cmdline-tools"

Write-Host "`n[SELESAI] Sekarang jalankan:" -ForegroundColor Green
Write-Host "sdkmanager `"platform-tools`" `"platforms;android-33`" `"build-tools;33.0.0`"" -ForegroundColor Yellow
