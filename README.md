# Laboratorium Poltekkes Kemenkes Banten Mobile App

Aplikasi mobile untuk sistem manajemen laboratorium Politeknik Kesehatan Kementerian Kesehatan Serang Banten.

## Fitur Aplikasi

### Role: Admin
- **Users**: Manajemen daftar pengguna (tambah, edit, hapus, import)
- **Manage User**: Manajemen user dengan role assignment
- **Master Data**: Manajemen data ruangan laboratorium

### Role: PLP (Pengelola Lab)
- **Daftar Barang**: Daftar inventori barang/peralatan lab
- **Jadwal Praktikum**: Manajemen jadwal praktikum
- **Request Peralatan**: Review dan approve/reject request peminjaman peralatan
- **Request Jadwal Praktek**: Manajemen request jadwal praktek
- **Pinjaman & Pengembalian**: Tracking peminjaman dan pengembalian peralatan
- **Laporan**: Generate laporan aktivitas lab

### Role: User (Siswa)
- **Request Peralatan**: Buat request peminjaman peralatan lab
- **Jadwal Praktikum**: Lihat jadwal praktikum
- **Kunjungan Lab**: Tracking kunjungan ke lab

## Teknologi yang Digunakan

- **Framework**: Flutter 3.0+
- **State Management**: Provider
- **HTTP Client**: Dio
- **Local Storage**: Shared Preferences
- **Backend**: PHP REST API (Laravel/Slim/Lumen)

## Struktur Proyek

```
lib/
├── main.dart                 # Entry point aplikasi
├── models/                   # Data models
│   ├── user_model.dart
│   ├── equipment_request_model.dart
│   ├── lab_room_model.dart
│   ├── praktikum_schedule_model.dart
│   └── item_model.dart
├── services/                 # API services
│   └── api_service.dart
├── providers/                # State management
│   └── auth_provider.dart
├── screens/                  # UI Screens
│   ├── splash_screen.dart
│   ├── auth/
│   │   └── login_screen.dart
│   ├── admin/
│   │   ├── admin_home_screen.dart
│   │   ├── admin_users_screen.dart
│   │   ├── admin_manage_user_screen.dart
│   │   └── admin_master_data_screen.dart
│   ├── plp/
│   │   ├── plp_home_screen.dart
│   │   ├── plp_daftar_barang_screen.dart
│   │   ├── plp_jadwal_praktikum_screen.dart
│   │   └── plp_request_peralatan_screen.dart
│   └── user/
│       ├── user_home_screen.dart
│       ├── user_request_peralatan_screen.dart
│       ├── user_jadwal_praktikum_screen.dart
│       └── user_kunjungan_lab_screen.dart
├── widgets/                  # Reusable widgets
│   ├── app_drawer.dart
│   └── search_bar_widget.dart
└── utils/                    # Utilities
    ├── app_theme.dart
    └── api_config.dart
```

## Setup & Installation

### Prerequisites
- Flutter SDK 3.0 atau lebih tinggi
- Dart SDK 3.0 atau lebih tinggi
- Android Studio / VS Code dengan Flutter extension
- Backend API PHP sudah berjalan

### Installation Steps

1. Clone repository:
```bash
git clone <repository-url>
cd laboratorium-poltekkesbanten-mobile
```

2. Install dependencies:
```bash
flutter pub get
```

3. Konfigurasi API endpoint:
Edit file `lib/utils/api_config.dart` dan sesuaikan `baseUrl` dengan URL backend PHP Anda:
```dart
static const String baseUrl = 'https://laboratorium.poltekkesbanten.ac.id/api';
```

4. Run aplikasi:
```bash
flutter run
```

## Konfigurasi Backend API

Aplikasi ini memerlukan backend API PHP yang menyediakan endpoint-endpoint berikut:

### Authentication
- `POST /api/auth/login` - Login user
- `POST /api/auth/logout` - Logout user
- `GET /api/auth/profile` - Get user profile
- `POST /api/auth/change-password` - Change password

### Admin Endpoints
- `GET /api/admin/users` - Get list users
- `GET /api/admin/manage-users` - Get manage users
- `GET /api/admin/master-data` - Get master data (rooms)
- `POST /api/admin/users/add` - Add user
- `PUT /api/admin/users/edit/{id}` - Edit user
- `DELETE /api/admin/users/delete/{id}` - Delete user
- `POST /api/admin/rooms/add` - Add room
- `PUT /api/admin/rooms/edit/{id}` - Edit room
- `DELETE /api/admin/rooms/delete/{id}` - Delete room

### PLP Endpoints
- `GET /api/plp/items` - Get items list
- `GET /api/plp/praktikum/schedule` - Get schedule
- `GET /api/plp/equipment/requests` - Get equipment requests
- `GET /api/plp/requests/detail/{id}` - Get request detail
- `POST /api/plp/requests/approve/{id}` - Approve request
- `POST /api/plp/requests/reject/{id}` - Reject request

### User Endpoints
- `GET /api/user/equipment/requests` - Get user requests
- `POST /api/user/equipment/request/create` - Create request
- `GET /api/user/praktikum/schedule` - Get schedule
- `GET /api/user/lab-visits` - Get lab visits

### Response Format
API harus mengembalikan response dalam format JSON:
```json
{
  "success": true,
  "data": {...},
  "message": "Success message"
}
```

Untuk error:
```json
{
  "success": false,
  "message": "Error message"
}
```

## Build untuk Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Catatan Pengembangan

- Pastikan backend API sudah tersedia sebelum menjalankan aplikasi
- Update `baseUrl` di `lib/utils/api_config.dart` sesuai dengan environment
- Token authentication disimpan di SharedPreferences
- Aplikasi menggunakan Material Design 3

## Lisensi

Proyek ini dibuat untuk Politeknik Kesehatan Kementerian Kesehatan Serang Banten.

## Kontak

Untuk pertanyaan atau dukungan, silakan hubungi tim IT Poltekkes Kemenkes Serang Banten.