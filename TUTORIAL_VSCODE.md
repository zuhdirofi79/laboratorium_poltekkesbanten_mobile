# Tutorial: Menjalankan Aplikasi Flutter di VS Code dengan Android Emulator

Tutorial ini akan memandu Anda untuk menjalankan aplikasi **Laboratorium Poltekkes Banten Mobile** menggunakan **VS Code** dengan **Android Virtual Device (AVD)** tanpa perlu menginstal Android Studio yang berat.

> **⚠️ PENTING - Mengapa Menggunakan Local Disk D:?**
> 
> Tutorial ini menggunakan **Local Disk D:** untuk semua komponen (Flutter SDK, Android SDK, Gradle cache, AVD, dan project) karena:
> - **C: biasanya terbatas space** (terutama setelah Windows update dan aplikasi sistem)
> - **Mobile development membutuhkan space besar**: Flutter SDK (~2GB), Android SDK (~10-15GB), Gradle cache (~5-10GB), AVD images (~8-15GB per emulator)
> - **Build process menulis banyak cache** yang bisa membuat C: penuh
> - **Mencegah Windows freeze/corrupt** karena space habis
> - **Project lebih aman** dari risiko write error saat build
> 
> Jika Anda sudah terlanjur install di C:, **pindahkan sekarang** sebelum melanjutkan development.

> **⚠️ CARA MENGGUNAKAN COMMAND DI TUTORIAL INI:**
> 
> - **JANGAN copy-paste syntax markdown** seperti ` ```bash `, ` ```powershell `, atau ` ``` ` ke terminal
> - **Hanya copy command-nya saja** (baris di antara ```)
> - Contoh: Jika tutorial menulis:
>   ```powershell
>   sdkmanager "platform-tools"
>   ```
>   Maka yang Anda copy ke PowerShell adalah: `sdkmanager "platform-tools"` (tanpa ```powershell dan ```)
> - Jika command tidak dikenali, gunakan **full path** yang disediakan sebagai alternatif

---

## 📋 Prerequisites

Sebelum memulai, pastikan Anda memiliki:
- Windows 10/11 (64-bit)
- RAM minimal 8GB (disarankan 16GB)
- **Local Disk D: dengan space minimal 20GB** (untuk Flutter SDK, Android SDK, dan project)
- Koneksi internet yang stabil
- VS Code sudah terinstal

> **⚠️ PENTING**: Tutorial ini menggunakan **Local Disk D:** untuk semua komponen (Flutter SDK, Android SDK, dan project) untuk menghindari masalah space di C:. Pastikan D: memiliki space yang cukup.

---

## 🔧 Step 1: Instalasi Flutter SDK

> **⚠️ PENTING**: Tutorial ini menggunakan **Local Disk D:** untuk menghindari masalah space di C:. Pastikan D: memiliki space yang cukup (minimal 20GB).

### 1.1 Download Flutter SDK
1. Kunjungi: https://docs.flutter.dev/get-started/install/windows
2. Download Flutter SDK (zip file)
3. Extract ke folder yang mudah diakses, contoh: `D:\flutter`
4. **JANGAN** extract ke folder `C:\Program Files\` atau `C:\` (permission issues dan space terbatas)

### 1.2 Setup Environment Variables
1. Buka **System Properties**:
   - Tekan `Win + R`
   - Ketik: `sysdm.cpl` dan tekan Enter
   - Atau: Klik kanan "This PC" → Properties → Advanced system settings

2. Klik **Environment Variables**

3. Di bagian **User variables**, edit/update **Path**:
   - Klik **Edit** pada variable Path
   - Klik **New** dan tambahkan: `D:\flutter\bin`
   - Klik **OK** pada semua dialog

4. Tambahkan variable baru (jika belum ada):
   - Klik **New** di User variables
   - Variable name: `FLUTTER_ROOT`
   - Variable value: `D:\flutter`
   - Klik **OK**

5. Tutup semua command prompt/PowerShell dan buka baru untuk reload environment

### 1.3 Verifikasi Flutter Installation
1. **Tutup semua PowerShell/Command Prompt** yang sedang terbuka
2. Buka **PowerShell** atau **Command Prompt BARU** (untuk reload environment variables)
3. Jalankan command:
   ```powershell
   flutter --version
   ```
4. Jika muncul versi Flutter, instalasi berhasil!

5. Jalankan Flutter doctor untuk cek dependencies:
   ```powershell
   flutter doctor
   ```

---

## ☕ Step 2: Install Java JDK (Wajib!)

> **⚠️ PENTING**: Android SDK Command Line Tools **MEMBUTUHKAN Java JDK** untuk berjalan. Jika Anda belum install Java, lakukan langkah ini terlebih dahulu.

### 2.1 Download dan Install Java JDK
1. Kunjungi: https://adoptium.net/ (atau https://www.oracle.com/java/technologies/downloads/)
2. Download **Java JDK 17 atau 21** (LTS version) untuk Windows x64
   - Rekomendasi: **Eclipse Temurin JDK 17** atau **21** (gratis, open source)
3. Install ke folder: `D:\Java\jdk-17` (atau versi yang Anda download)
   - **JANGAN** install ke `C:\Program Files\` (permission issues)
   - Pilih "Set JAVA_HOME variable" saat install (jika ada opsi)

### 2.2 Setup JAVA_HOME Environment Variable
1. Buka **Environment Variables** (Step 1.2)
2. Buat variable baru di **User variables**:
   - Variable name: `JAVA_HOME`
   - Variable value: `D:\Java\jdk-17` (sesuaikan dengan path install Java Anda)
   - Klik **OK**
3. Tambahkan ke **Path**:
   - Edit variable **Path**
   - Klik **New** dan tambahkan: `%JAVA_HOME%\bin`
   - Atau langsung: `D:\Java\jdk-17\bin`
   - Klik **OK**

### 2.3 Verifikasi Java Installation
1. **Tutup semua PowerShell/Command Prompt** yang sedang terbuka
2. Buka **PowerShell BARU**
3. Verifikasi Java terinstall:
   ```powershell
   java -version
   ```
   Harus menampilkan versi Java (contoh: `openjdk version "17.0.x"`)

4. Verifikasi JAVA_HOME:
   ```powershell
   $env:JAVA_HOME
   ```
   Harus menampilkan: `D:\Java\jdk-17` (atau path Java Anda)

5. Jika tidak muncul, reload PATH:
   ```powershell
   $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
   $env:JAVA_HOME = [System.Environment]::GetEnvironmentVariable("JAVA_HOME","User")
   ```

---

## 📱 Step 3: Setup Android SDK (Command Line Tools - Ringan)

Karena kita tidak menggunakan Android Studio, kita akan menggunakan Android SDK Command Line Tools yang lebih ringan.

> **⚠️ PENTING**: Semua Android SDK components akan diinstall di **D:\Android** untuk menghindari masalah space di C:.

### 3.1 Download Android SDK Command Line Tools
1. Kunjungi: https://developer.android.com/studio#command-tools
2. Download **Command line tools only** (bukan Android Studio)
   - Pilih versi untuk Windows: `commandlinetools-win-xxx_latest.zip`
3. Extract ke folder, contoh: `D:\Android\cmdline-tools`
4. **PENTING**: Buat struktur folder yang benar:
   ```
   D:\Android\cmdline-tools\
   └── latest\
       ├── bin\
       └── lib\
   ```
   
   **Langkah-langkah:**
   a. Buat folder `latest` di dalam `D:\Android\cmdline-tools\`
   b. Di dalam `latest`, buat folder `bin`
   c. **Pindahkan SEMUA file dari extract ke dalam `latest\bin\`** (termasuk folder `lib` yang ada di extract)
   
   **Struktur akhir harus seperti ini:**
   ```
   D:\Android\cmdline-tools\latest\
   ├── bin\
   │   ├── sdkmanager.bat
   │   ├── avdmanager.bat
   │   ├── NOTICE.txt
   │   ├── source.properties
   │   └── ... (file .bat lainnya)
   └── lib\
       ├── sdkmanager-classpath.jar
       └── ... (file .jar lainnya)
   ```
   
   **⚠️ CATATAN**: Folder `lib` harus ada di `latest\lib\`, bukan di `latest\bin\lib\`. Jika folder `lib` ikut terpindahkan ke dalam `bin`, pindahkan kembali ke `latest\lib\`.

### 3.2 Setup Android Environment Variables
1. Buka **Environment Variables** lagi (Step 1.2)

2. Tambahkan ke **Path**:
   ```
   D:\Android\cmdline-tools\latest\bin
   D:\Android\platform-tools
   ```

3. Buat variable baru:
   - Variable name: `ANDROID_HOME`
   - Variable value: `D:\Android`

4. Buat variable baru lagi:
   - Variable name: `ANDROID_SDK_ROOT`
   - Variable value: `D:\Android`

### 3.3 Setup Gradle Cache ke D: (Penting!)
Sebelum install SDK components, pastikan Gradle cache tidak menggunakan C::

1. Buat variable environment baru:
   - Variable name: `GRADLE_USER_HOME`
   - Variable value: `D:\.gradle`

2. Atau set via PowerShell (temporary):
   ```powershell
   $env:GRADLE_USER_HOME = "D:\.gradle"
   ```

### 3.4 Install Android SDK Components via Command Line

> **⚠️ PENTING**: 
> - **JANGAN copy-paste syntax markdown** (` ```bash ` atau ` ``` `) ke PowerShell
> - **Hanya copy command-nya saja** (baris setelah ```bash)
> - Atau gunakan full path jika `sdkmanager` tidak dikenali

1. **Tutup semua PowerShell/Command Prompt yang sedang terbuka** (untuk reload environment variables)

2. Buka **PowerShell BARU** sebagai Administrator:
   - Klik kanan Start Menu → **Windows PowerShell (Admin)**
   - Atau: Tekan `Win + X` → **Windows PowerShell (Admin)**

3. **Verifikasi PATH sudah benar** (opsional, untuk troubleshooting):
   ```powershell
   $env:PATH -split ';' | Select-String "Android"
   ```
   Harus menampilkan path yang mengandung `D:\Android\cmdline-tools\latest\bin`

4. **Jika sdkmanager tidak dikenali**, gunakan full path:
   ```powershell
   D:\Android\cmdline-tools\latest\bin\sdkmanager.bat "platform-tools" "platforms;android-33" "build-tools;33.0.0"
   D:\Android\cmdline-tools\latest\bin\sdkmanager.bat "emulator"
   D:\Android\cmdline-tools\latest\bin\sdkmanager.bat "system-images;android-33;google_apis;x86_64"
   ```

5. **Atau jika PATH sudah benar**, gunakan command biasa:
   ```powershell
   sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"
   sdkmanager "emulator"
   sdkmanager "system-images;android-33;google_apis;x86_64"
   ```

6. Accept licenses:
   ```powershell
   sdkmanager --licenses
   ```
   Atau dengan full path:
   ```powershell
   D:\Android\cmdline-tools\latest\bin\sdkmanager.bat --licenses
   ```
   Tekan `y` untuk semua license (bisa 5-10 kali)

### 3.5 Setup AVD Location ke D: (Penting!)
AVD images bisa sangat besar (8-15GB per emulator), jadi harus dipindahkan ke D::

1. Buat variable environment baru:
   - Variable name: `ANDROID_AVD_HOME`
   - Variable value: `D:\Android\avd`

2. Buat folder untuk AVD:
   ```bash
   mkdir D:\Android\avd
   ```

### 3.6 Create Android Virtual Device (AVD)
1. List available system images:
   ```powershell
   sdkmanager --list | Select-String "system-images"
   ```
   Atau dengan full path:
   ```powershell
   D:\Android\cmdline-tools\latest\bin\sdkmanager.bat --list | Select-String "system-images"
   ```

2. Create AVD (akan otomatis tersimpan di D:\Android\avd):
   ```powershell
   avdmanager create avd -n "pixel_5" -k "system-images;android-33;google_apis;x86_64"
   ```
   Atau dengan full path:
   ```powershell
   D:\Android\cmdline-tools\latest\bin\avdmanager.bat create avd -n "pixel_5" -k "system-images;android-33;google_apis;x86_64"
   ```
   - Pilih `yes` untuk hardware profile
   - Pilih `no` untuk custom hardware

3. List AVD untuk verifikasi:
   ```powershell
   emulator -list-avds
   ```
   Atau dengan full path:
   ```powershell
   D:\Android\emulator\emulator.exe -list-avds
   ```
   
4. Verifikasi AVD location:
   ```powershell
   $env:ANDROID_AVD_HOME
   ```
   Harus menampilkan: `D:\Android\avd`

---

## 💻 Step 4: Setup VS Code untuk Flutter

### 4.1 Install Flutter Extension di VS Code
1. Buka **VS Code**
2. Klik icon **Extensions** di sidebar (atau tekan `Ctrl+Shift+X`)
3. Cari: **Flutter**
4. Install extension **Flutter** (by Dart Code)
5. Otomatis akan menginstall extension **Dart** juga

### 4.2 Configure Flutter SDK Path di VS Code
1. Buka **Settings** di VS Code:
   - Tekan `Ctrl+,`
   - Atau: File → Preferences → Settings

2. Cari: `flutter.flutterSdkPaths`

3. Tambahkan path Flutter SDK:
   ```
   D:\flutter
   ```

4. Restart VS Code

---

## 🚀 Step 5: Setup Project

### 5.1 Clone/Buka Project
1. Jika menggunakan Git:
   ```bash
   cd D:\Projects
   git clone <repository-url>
   cd laboratorium-poltekkesbanten-mobile\laboratorium_poltekkesbanten_mobile
   ```

2. Atau buka folder project di VS Code:
   - File → Open Folder
   - Pilih folder: `D:\Projects\laboratorium-poltekkesbanten-mobile\laboratorium_poltekkesbanten_mobile`
   
   > **Catatan**: Path project sudah dipindahkan ke D: untuk menghindari masalah space di C:

### 5.2 Install Dependencies
1. Buka **Terminal** di VS Code:
   - Tekan `` Ctrl+` `` (backtick)
   - Atau: Terminal → New Terminal

2. Jalankan:
   ```powershell
   flutter pub get
   ```

3. Tunggu hingga semua dependencies terinstall

### 5.3 Verifikasi Setup
1. Di terminal VS Code, jalankan:
   ```powershell
   flutter doctor
   ```

2. Pastikan checkmarks (✓) ada di:
   - ✓ Flutter
   - ✓ Android toolchain
   - ✓ VS Code

3. Jika ada issue, ikuti saran dari `flutter doctor`

---

## 📲 Step 6: Menjalankan AVD (Android Emulator)

### 6.1 Start Emulator via Command Line
1. Buka **PowerShell** atau **Command Prompt**
2. Jalankan:
   ```powershell
   emulator -avd pixel_5
   ```
   Atau dengan full path:
   ```powershell
   D:\Android\emulator\emulator.exe -avd pixel_5
   ```
   (Ganti `pixel_5` dengan nama AVD Anda)

3. Tunggu hingga emulator boot up (bisa beberapa menit pertama kali)

### 6.2 Atau: Start Emulator dari VS Code
1. Di VS Code, tekan `Ctrl+Shift+P` (Command Palette)
2. Ketik: `Flutter: Launch Emulator`
3. Pilih AVD yang ingin digunakan
4. Emulator akan boot up

### 6.3 Verifikasi Emulator Running
1. Setelah emulator terbuka, cek di terminal:
   ```powershell
   flutter devices
   ```
2. Anda harus melihat device Android emulator terdeteksi

---

## ▶️ Step 7: Menjalankan Aplikasi

### 7.1 Configure API Base URL (Penting!)
1. Buka file: `lib/utils/api_config.dart`
2. Edit base URL sesuai dengan backend PHP Anda:
   ```dart
   static const String baseUrl = 'https://laboratorium.poltekkesbanten.ac.id/api';
   ```
3. Simpan file (`Ctrl+S`)

### 7.2 Run Aplikasi

**Method 1: Via VS Code (Recommended)**
1. Tekan `F5` atau klik **Run** di sidebar
2. Pilih device (Android Emulator)
3. Aplikasi akan di-build dan install ke emulator
4. Tunggu hingga aplikasi terbuka

**Method 2: Via Terminal**
1. Pastikan emulator sudah running
2. Di terminal VS Code:
   ```powershell
   flutter run
   ```
3. Aplikasi akan di-build dan dijalankan

**Method 3: Run Mode Selection**
1. Tekan `Ctrl+Shift+P`
2. Ketik: `Flutter: Select Device`
3. Pilih emulator
4. Tekan `F5` untuk run

### 7.3 Hot Reload & Hot Restart
Setelah aplikasi running:
- **Hot Reload**: Tekan `r` di terminal (untuk perubahan kecil)
- **Hot Restart**: Tekan `R` di terminal (untuk restart aplikasi)
- **Stop**: Tekan `q` di terminal
- Atau gunakan tombol di Debug toolbar di VS Code

---

## 🐛 Troubleshooting

### Issue 1: Flutter doctor shows issues

**Problem**: `flutter doctor` menunjukkan X pada beberapa item

**Solution**:
```powershell
flutter doctor --android-licenses
# Accept semua licenses dengan menekan y
```

### Issue 2: Java tidak ditemukan (sdkmanager error) - JAVA_HOME vs PATH Conflict

> **💡 QUICK FIX**: Jika Anda mendapat error `ClassNotFoundException` dan `java -version` menunjukkan Java 8, jalankan perintah berikut di PowerShell untuk perbaikan sementara:
> ```powershell
> # Fix Java PATH priority (pastikan Java 17 digunakan, bukan Java 8)
> $env:JAVA_HOME = [System.Environment]::GetEnvironmentVariable("JAVA_HOME","User")
> $java17Path = "$env:JAVA_HOME\bin"
> if ($java17Path -and (Test-Path $java17Path)) {
>     $paths = ($env:Path -split ';') | Where-Object { $_ -ne $java17Path }
>     $env:Path = "$java17Path;" + ($paths -join ';')
>     Write-Host "Java PATH fixed. Current Java version:" -ForegroundColor Green
>     java -version
> }
> 
> # Fix Android PATH (tambahkan jika belum ada)
> $androidPaths = @(
>     "D:\Android\cmdline-tools\latest\bin",
>     "D:\Android\platform-tools"
> )
> foreach ($path in $androidPaths) {
>     if ($env:Path -notlike "*$path*" -and (Test-Path $path)) {
>         $env:Path = "$path;$env:Path"
>         Write-Host "Added to PATH: $path" -ForegroundColor Green
>     }
> }
> 
> # Verifikasi
> Write-Host "`nVerifying setup..." -ForegroundColor Cyan
> Write-Host "JAVA_HOME: $env:JAVA_HOME"
> Write-Host "Java version:" 
> java -version
> Write-Host "`nAndroid paths in PATH:"
> $env:PATH -split ';' | Select-String "Android"
> ```
> **Catatan**: Ini hanya fix sementara untuk session PowerShell saat ini. Untuk fix permanen, edit Environment Variables (lihat Solutions di bawah).

### Issue 2: Java tidak ditemukan (sdkmanager error)

**Problem**: Error `Could not find or load main class com.android.sdklib.tool.sdkmanager.SdkManagerCli` atau `java.lang.ClassNotFoundException`

**⚠️ CATATAN PENTING**: Android SDK Command Line Tools **MEMBUTUHKAN Java 11 atau lebih baru** (disarankan Java 17 atau 21). Java 8 **TIDAK** didukung.

**Solutions**:

1. **Cek versi Java yang aktif**:
   ```powershell
   java -version
   ```
   - Jika menampilkan **Java 8 atau lebih lama** → **PROBLEM!** Perlu perbaikan PATH
   - Harus menampilkan **Java 11, 17, atau 21**

2. **Cek JAVA_HOME sudah di-set**:
   ```powershell
   $env:JAVA_HOME
   ```
   Harus menampilkan path Java 17/21 (contoh: `D:\Java\jdk-17`)

3. **Jika `java -version` menunjukkan Java 8 tetapi `JAVA_HOME` menunjukkan Java 17**:
   
   Ini berarti Java 8 ada di PATH sebelum Java 17. **Perbaiki urutan PATH**:
   
   a. **Buka Environment Variables**:
      - Tekan `Win + R` → ketik `sysdm.cpl` → Enter
      - Klik **Environment Variables**
   
   b. **Edit User Path**:
      - Di bagian **User variables**, edit **Path**
      - **HAPUS** entry Java 8 jika ada (contoh: `C:\Program Files\Java\jdk1.8.0_xxx\bin`)
      - **PASTIKAN** `%JAVA_HOME%\bin` ada di **ATAS** (urutan pertama atau kedua)
      - Jika `%JAVA_HOME%\bin` belum ada, klik **New** dan tambahkan
      - Jika sudah ada tapi di bawah, gunakan **Move Up** untuk naikkan ke atas
      - Klik **OK** pada semua dialog
   
   c. **Atau gunakan System Path** (jika Java 8 di System Path):
      - Di bagian **System variables**, edit **Path**
      - Cari entry Java 8 (contoh: `C:\Program Files (x86)\Common Files\Oracle\Java\javapath`)
      - **HAPUS** atau **Move Down** entry tersebut
      - **Move Up** `%JAVA_HOME%\bin` (jika ada di System Path)
   
   d. **Tutup SEMUA PowerShell/CMD dan buka yang BARU**

4. **Reload environment variables di PowerShell saat ini** (solusi sementara):
   ```powershell
   # Reload JAVA_HOME dan PATH
   $env:JAVA_HOME = [System.Environment]::GetEnvironmentVariable("JAVA_HOME","User")
   $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
   
   # Pastikan Java 17 ada di PATH (tambahkan di depan)
   $java17Path = "$env:JAVA_HOME\bin"
   if ($env:Path -notlike "*$java17Path*") {
       $env:Path = "$java17Path;$env:Path"
   } else {
       # Pindahkan ke depan jika sudah ada
       $paths = $env:Path -split ';'
       $paths = $paths | Where-Object { $_ -ne $java17Path }
       $env:Path = "$java17Path;" + ($paths -join ';')
   }
   
   # Verifikasi Java versi sekarang
   java -version
   javac -version
   ```
   Harus menampilkan **Java 17 atau 21**, bukan Java 8

5. **Verifikasi Java 17 bisa digunakan langsung**:
   ```powershell
   & "$env:JAVA_HOME\bin\java.exe" -version
   ```
   Harus menampilkan Java 17/21

6. **Jika JAVA_HOME kosong atau salah**, set ulang:
   - Buka Environment Variables (Step 1.2)
   - Pastikan `JAVA_HOME` = `D:\Java\jdk-17` (atau path Java 17/21 Anda)
   - Pastikan `%JAVA_HOME%\bin` ada di Path **DI ATAS** (prioritas tinggi)
   - **Tutup dan buka PowerShell baru**

7. **Jika masih error atau Java 17 belum terinstall**:
   - Download Java JDK 17 atau 21 dari: https://adoptium.net/
   - Install ke `D:\Java\jdk-17`
   - Set `JAVA_HOME` = `D:\Java\jdk-17`
   - Tambahkan `%JAVA_HOME%\bin` ke Path **DI ATAS**
   - **Tutup dan buka PowerShell baru**

### Issue 3: `sdkmanager` tidak dikenali (command not found)

**Problem**: PowerShell/CMD tidak mengenali command `sdkmanager` atau PATH tidak mengandung Android tools

**Solutions**:

1. **Verifikasi PATH di PowerShell**:
   ```powershell
   $env:PATH -split ';' | Select-String "Android"
   ```
   Jika **tidak muncul**, environment variable belum ter-reload atau belum di-set

2. **Pastikan PATH sudah di-set di Environment Variables**:
   - Buka Environment Variables (Step 1.2 atau 3.2)
   - Di bagian **User variables**, edit **Path**
   - Pastikan ada entry: `D:\Android\cmdline-tools\latest\bin`
   - Pastikan ada entry: `D:\Android\platform-tools`
   - Jika belum ada, tambahkan keduanya
   - Klik **OK** pada semua dialog

3. **Tutup dan buka PowerShell baru** (untuk reload environment):
   - Tutup **SEMUA** PowerShell/CMD yang sedang terbuka
   - Buka PowerShell **BARU** sebagai Administrator
   - Verifikasi lagi:
     ```powershell
     $env:PATH -split ';' | Select-String "Android"
     ```

4. **Reload PATH manual di PowerShell saat ini** (solusi sementara):
   ```powershell
   # Reload PATH dari environment variables
   $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
   
   # Tambahkan Android paths jika belum ada
   $androidCmdTools = "D:\Android\cmdline-tools\latest\bin"
   $androidPlatformTools = "D:\Android\platform-tools"
   
   if ($env:Path -notlike "*$androidCmdTools*") {
       $env:Path = "$androidCmdTools;$env:Path"
   }
   if ($env:Path -notlike "*$androidPlatformTools*") {
       $env:Path = "$androidPlatformTools;$env:Path"
   }
   
   # Verifikasi
   $env:PATH -split ';' | Select-String "Android"
   ```
   Sekarang harus menampilkan Android paths

5. **Verifikasi file sdkmanager.bat ada**:
   ```powershell
   Test-Path "D:\Android\cmdline-tools\latest\bin\sdkmanager.bat"
   ```
   Harus return `True`. Jika `False`, struktur folder salah (lihat Step 3.1)

6. **Gunakan full path sebagai alternatif** (jika PATH masih bermasalah):
   ```powershell
   D:\Android\cmdline-tools\latest\bin\sdkmanager.bat "platform-tools"
   ```

### Issue 4: Emulator tidak terdeteksi

**Problem**: `flutter devices` tidak menampilkan emulator

**Solutions**:
1. Pastikan emulator benar-benar running:
   ```powershell
   emulator -list-avds
   emulator -avd <nama_avd>
   ```
   Atau dengan full path:
   ```powershell
   D:\Android\emulator\emulator.exe -list-avds
   D:\Android\emulator\emulator.exe -avd <nama_avd>
   ```

2. Restart ADB:
   ```powershell
   adb kill-server
   adb start-server
   flutter devices
   ```
   Atau dengan full path:
   ```powershell
   D:\Android\platform-tools\adb.exe kill-server
   D:\Android\platform-tools\adb.exe start-server
   ```

3. Pastikan Android SDK Platform Tools terinstall:
   ```powershell
   sdkmanager "platform-tools"
   ```
   Atau dengan full path:
   ```powershell
   D:\Android\cmdline-tools\latest\bin\sdkmanager.bat "platform-tools"
   ```

### Issue 5: Gradle build failed

**Problem**: Error saat build Android

**Solutions**:
1. Pastikan Gradle cache di D::
   - Cek environment variable `GRADLE_USER_HOME` = `D:\.gradle`
   - Jika belum set, set ulang dan restart terminal

2. Clean project:
   ```powershell
   flutter clean
   flutter pub get
   ```

3. Update Gradle (edit `android/gradle/wrapper/gradle-wrapper.properties`):
   ```properties
   distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-all.zip
   ```

4. Jika masih error karena space, pastikan D: memiliki space cukup (minimal 10GB free)

### Issue 6: Port sudah digunakan

**Problem**: Error "port already in use"

**Solution**:
```powershell
# Cari process yang menggunakan port
netstat -ano | Select-String ":5037"
# Kill process (ganti PID dengan angka yang muncul)
taskkill /PID <PID> /F
```

### Issue 7: VS Code tidak detect Flutter

**Problem**: Flutter extension tidak bekerja

**Solutions**:
1. Reload VS Code window:
   - `Ctrl+Shift+P` → `Developer: Reload Window`

2. Cek Flutter SDK path di VS Code settings:
   - `Ctrl+,` → cari "flutter sdk"
   - Pastikan path benar: `D:\flutter`

3. Install Flutter extension ulang:
   - Uninstall extension
   - Restart VS Code
   - Install extension lagi

### Issue 7: Emulator lambat/lemot

**Solutions**:
1. Pastikan AVD di D: (tidak di C:):
   - Cek `ANDROID_AVD_HOME` = `D:\Android\avd`
   - Jika masih di C:, pindahkan dan update environment variable

2. Kurangi RAM emulator (edit AVD):
   ```bash
   emulator -avd pixel_5 -memory 2048
   ```

3. Gunakan x86_64 images (lebih cepat dari arm):
   ```bash
   sdkmanager "system-images;android-33;google_apis;x86_64"
   ```

4. Enable Hardware Acceleration (jika PC support):
   - Enable Hyper-V di Windows
   - Install Intel HAXM atau Windows Hypervisor Platform

### Issue 8: API connection error

**Problem**: Aplikasi tidak bisa connect ke backend

**Solutions**:
1. Pastikan base URL benar di `lib/utils/api_config.dart`
2. Test API dengan Postman/curl dulu
3. Pastikan emulator bisa akses internet:
   ```powershell
   adb shell ping 8.8.8.8
   ```
   Atau dengan full path:
   ```powershell
   D:\Android\platform-tools\adb.exe shell ping 8.8.8.8
   ```
4. Jika backend di localhost, gunakan IP address:
   ```dart
   // Jangan gunakan localhost atau 127.0.0.1
   // Gunakan IP PC Anda, contoh:
   static const String baseUrl = 'http://192.168.1.100/api';
   ```

---

## 📝 Tips & Best Practices

### 1. Storage Management
- **Selalu gunakan D: untuk semua komponen development** (Flutter, Android SDK, Gradle, AVD, project)
- Monitor space D: secara berkala (minimal 10GB free untuk build process)
- Jangan taruh project mobile di `C:\xampp\htdocs\` (itu untuk web server, bukan mobile app)
- Clean Gradle cache secara berkala jika space terbatas:
  ```bash
  # Hapus cache lama (hati-hati, akan re-download saat build berikutnya)
  Remove-Item -Recurse -Force D:\.gradle\caches\*
  ```

### 2. Performance Optimization
- Tutup aplikasi lain yang tidak perlu
- Alokasikan RAM yang cukup untuk emulator (2-4GB)
- Gunakan x86_64 system images (lebih cepat)

### 2. Development Workflow
- Gunakan **Hot Reload** untuk perubahan UI cepat
- Gunakan **Hot Restart** untuk perubahan logic/state
- Gunakan **Stop & Run** untuk perubahan dependency/config

### 3. Debugging
- Gunakan VS Code Debugger (F5) untuk breakpoints
- Cek **Debug Console** untuk log output
- Gunakan `print()` atau `debugPrint()` untuk logging

### 4. Command Line Shortcuts
```powershell
flutter run                    # Run aplikasi
flutter run -d <device>       # Run di device spesifik
flutter clean                 # Clean build files
flutter pub get               # Install dependencies
flutter devices               # List devices
flutter doctor                # Check setup
flutter doctor -v             # Verbose check
```

---

## ✅ Checklist Setup

Gunakan checklist ini untuk memastikan semua setup sudah benar:

- [ ] Flutter SDK terinstall di `D:\flutter` dan di PATH
- [ ] Android SDK Command Line Tools terinstall di `D:\Android\cmdline-tools`
- [ ] Environment variables sudah set:
  - [ ] `ANDROID_HOME` = `D:\Android`
  - [ ] `ANDROID_SDK_ROOT` = `D:\Android`
  - [ ] `ANDROID_AVD_HOME` = `D:\Android\avd`
  - [ ] `GRADLE_USER_HOME` = `D:\.gradle`
  - [ ] `FLUTTER_ROOT` = `D:\flutter`
- [ ] VS Code Flutter extension terinstall
- [ ] Flutter SDK path di VS Code settings = `D:\flutter`
- [ ] AVD sudah dibuat dan bisa running
- [ ] `flutter doctor` menunjukkan semua OK (✓)
- [ ] `flutter devices` mendeteksi emulator
- [ ] Project berada di `D:\Projects\laboratorium-poltekkesbanten-mobile\laboratorium_poltekkesbanten_mobile`
- [ ] Project dependencies terinstall (`flutter pub get`)
- [ ] API base URL sudah dikonfigurasi
- [ ] Aplikasi berhasil di-build dan running

---

## 📚 Resources Tambahan

- Flutter Documentation: https://docs.flutter.dev/
- VS Code Flutter Extension: https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter
- Android SDK Command Line Tools: https://developer.android.com/studio#command-tools
- Flutter Troubleshooting: https://docs.flutter.dev/get-started/install/windows#troubleshooting

---

## 💡 Alternative: Menggunakan Physical Device

Jika emulator terlalu lambat, Anda bisa menggunakan **Android Physical Device**:

### Setup Android Device
1. Aktifkan **Developer Options** di Android:
   - Settings → About Phone
   - Tap "Build Number" 7 kali

2. Aktifkan **USB Debugging**:
   - Settings → Developer Options
   - Enable "USB Debugging"

3. Connect device via USB

4. Verifikasi:
   ```powershell
   adb devices
   ```
   Atau dengan full path:
   ```powershell
   D:\Android\platform-tools\adb.exe devices
   ```

5. Pilih device saat run:
   ```powershell
   flutter run -d <device-id>
   ```

---

## 🎉 Selamat!

Jika semua langkah diikuti dengan benar, Anda seharusnya sudah bisa menjalankan aplikasi **Laboratorium Poltekkes Banten Mobile** di emulator melalui VS Code tanpa perlu Android Studio yang berat!

Jika masih ada masalah, cek bagian **Troubleshooting** atau buka issue di repository.

Happy Coding! 🚀