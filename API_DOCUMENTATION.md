# API Documentation for Mobile App

Dokumentasi ini menjelaskan endpoint-endpoint API yang dibutuhkan oleh aplikasi mobile Flutter.

## Base URL
```
https://laboratorium.poltekkesbanten.ac.id/api
```

## Authentication

Semua endpoint (kecuali login) memerlukan token authentication di header:
```
Authorization: Bearer {token}
```

## Response Format Standar

### Success Response
```json
{
  "success": true,
  "data": {...},
  "message": "Success message"
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error message"
}
```

---

## Endpoints

### 1. Authentication

#### POST /auth/login
Login user

**Request Body:**
```json
{
  "username": "string",
  "password": "string"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "token": "jwt_token_here",
    "user": {
      "id": 1,
      "username": "99999",
      "nama": "Admin Kampus",
      "email": "admin@example.com",
      "telepon": "081234567890",
      "role": "admin"
    }
  },
  "message": "Login berhasil"
}
```

#### POST /auth/logout
Logout user

**Response:**
```json
{
  "success": true,
  "message": "Logout berhasil"
}
```

#### GET /auth/profile
Get current user profile

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "username": "99999",
    "nama": "Admin Kampus",
    "email": "admin@example.com",
    "telepon": "081234567890",
    "role": "admin"
  }
}
```

#### POST /auth/change-password
Change password

**Request Body:**
```json
{
  "old_password": "string",
  "new_password": "string"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Password berhasil diubah"
}
```

---

### 2. Admin Endpoints

#### GET /admin/users
Get list of users (with optional search)

**Query Parameters:**
- `search` (optional): Search term

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "username": "99999",
      "nama": "Admin Kampus",
      "email": "fajar.nur@raharja.info",
      "telepon": "0877912182131"
    }
  ]
}
```

#### GET /admin/manage-users
Get list of users with roles (with optional search)

**Query Parameters:**
- `search` (optional): Search term

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "username": "3175081304020001",
      "nama": "Qowiy Muhammad Rofi Zuhdi",
      "role": "admin"
    }
  ]
}
```

#### POST /admin/users/add
Add new user

**Request Body:**
```json
{
  "username": "string",
  "nama": "string",
  "email": "string",
  "telepon": "string",
  "password": "string",
  "role": "admin|plp|user"
}
```

**Response:**
```json
{
  "success": true,
  "message": "User berhasil ditambahkan"
}
```

#### PUT /admin/users/edit/{id}
Edit user

**Request Body:**
```json
{
  "username": "string",
  "nama": "string",
  "email": "string",
  "telepon": "string",
  "role": "admin|plp|user"
}
```

#### DELETE /admin/users/delete/{id}
Delete user

#### GET /admin/master-data
Get master data (lab rooms) (with optional search)

**Query Parameters:**
- `search` (optional): Search term

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "jurusan": "Kebidanan",
      "kampus": "Rangkasbitung",
      "nama_ruang_lab": "Ruang Anatomi"
    }
  ]
}
```

#### POST /admin/rooms/add
Add new room

**Request Body:**
```json
{
  "nama_ruang_lab": "string",
  "jurusan": "string",
  "kampus": "string"
}
```

#### PUT /admin/rooms/edit/{id}
Edit room

**Request Body:**
```json
{
  "nama_ruang_lab": "string",
  "jurusan": "string",
  "kampus": "string"
}
```

#### DELETE /admin/rooms/delete/{id}
Delete room

---

### 3. PLP Endpoints

#### GET /plp/items
Get list of items (with optional search)

**Query Parameters:**
- `search` (optional): Search term

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "nama_barang": "string",
      "kategori": "string",
      "merk": "string",
      "spesifikasi": "string",
      "jumlah": 10,
      "kondisi": "baik|rusak|perlu_perbaikan",
      "lokasi": "string"
    }
  ]
}
```

#### GET /plp/praktikum/schedule
Get praktikum schedule (with optional search)

**Query Parameters:**
- `search` (optional): Search term

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "mata_kuliah": "string",
      "kelas": "string",
      "ruang_lab": "string",
      "tanggal": "2025-01-15",
      "jam_mulai": "08:00",
      "jam_selesai": "10:00",
      "dosen": "string",
      "status": "string"
    }
  ]
}
```

#### GET /plp/equipment/requests
Get equipment requests (with optional jurusan filter)

**Query Parameters:**
- `jurusan` (optional): Filter by jurusan (kebidanan, keperawatan, etc.)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "nama_peminjam": "string",
      "jenis_alat": "string",
      "ruang_lab": "string",
      "tingkat": "string",
      "tgl_permintaan": "2025-01-15",
      "status": "pending|approved|rejected",
      "jurusan": "string",
      "keterangan": "string"
    }
  ]
}
```

#### GET /plp/requests/detail/{id}
Get request detail

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "nama_peminjam": "string",
    "jenis_alat": "string",
    "ruang_lab": "string",
    "tingkat": "string",
    "tgl_permintaan": "2025-01-15",
    "status": "pending",
    "keterangan": "string"
  }
}
```

#### POST /plp/requests/approve/{id}
Approve request

**Response:**
```json
{
  "success": true,
  "message": "Request disetujui"
}
```

#### POST /plp/requests/reject/{id}
Reject request

**Request Body:**
```json
{
  "reason": "string"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Request ditolak"
}
```

---

### 4. User Endpoints

#### GET /user/equipment/requests
Get user's equipment requests

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "jenis_alat": "string",
      "ruang_lab": "string",
      "tingkat": "string",
      "tgl_permintaan": "2025-01-15",
      "status": "pending|approved|rejected"
    }
  ]
}
```

#### POST /user/equipment/request/create
Create equipment request

**Request Body:**
```json
{
  "jenis_alat": "string",
  "ruang_lab": "string",
  "tingkat": "string",
  "tgl_permintaan": "2025-01-15T00:00:00Z",
  "keterangan": "string"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Request berhasil dibuat"
}
```

#### GET /user/praktikum/schedule
Get user's praktikum schedule

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "mata_kuliah": "string",
      "kelas": "string",
      "ruang_lab": "string",
      "tanggal": "2025-01-15",
      "jam_mulai": "08:00",
      "jam_selesai": "10:00"
    }
  ]
}
```

#### GET /user/lab-visits
Get user's lab visits

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "ruang_lab": "string",
      "tanggal": "2025-01-15",
      "waktu": "08:00-10:00"
    }
  ]
}
```

---

## Status Codes

- `200 OK`: Request berhasil
- `201 Created`: Resource berhasil dibuat
- `400 Bad Request`: Request tidak valid
- `401 Unauthorized`: Token tidak valid atau tidak ada
- `403 Forbidden`: User tidak memiliki permission
- `404 Not Found`: Resource tidak ditemukan
- `500 Internal Server Error`: Server error

## Catatan

1. Semua tanggal menggunakan format ISO 8601: `YYYY-MM-DD` atau `YYYY-MM-DDTHH:mm:ssZ`
2. Token authentication menggunakan JWT
3. Token akan expire setelah periode tertentu, perlu refresh token mechanism
4. Untuk pagination, bisa ditambahkan query parameters `page` dan `limit` jika diperlukan