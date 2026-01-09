Semua endpoint API sudah dibuat. Ringkasan:
Endpoint yang dibuat
Authentication (selain yang sudah ada)
POST /api/auth/change-password.php - Ubah password user
Admin Endpoints
GET /api/admin/users.php - Daftar users (dengan search)
GET /api/admin/manage-users.php - Daftar users dengan role info
POST /api/admin/users/add.php - Tambah user baru
PUT /api/admin/users/edit.php?id={id} - Edit user
DELETE /api/admin/users/delete.php?id={id} - Hapus user
GET /api/admin/master-data.php - Daftar ruangan
POST /api/admin/rooms/add.php - Tambah ruangan
PUT /api/admin/rooms/edit.php?id={id} - Edit ruangan
DELETE /api/admin/rooms/delete.php?id={id} - Hapus ruangan
PLP Endpoints
GET /api/plp/items.php?type=inventaris|alat|bahan - Daftar barang (filtered by jurusan)
GET /api/plp/praktikum/schedule.php - Daftar jadwal praktikum
GET /api/plp/equipment/requests.php?status=Menunggu - Daftar request peralatan
GET /api/plp/requests/detail.php?id={id} - Detail request dengan items
POST /api/plp/requests/approve.php?id={id} - Approve request peralatan
POST /api/plp/requests/reject.php?id={id} - Reject request peralatan
GET /api/plp/schedule/requests.php?status=Menunggu - Daftar request jadwal
POST /api/plp/schedule/requests/approve.php?id={id} - Approve request jadwal (auto-create jadwal_praktikum)
POST /api/plp/schedule/requests/reject.php?id={id} - Reject request jadwal
GET /api/plp/loans.php?status=Selesai - Daftar pinjaman & pengembalian
POST /api/plp/loans/return.php?id={id} - Mark pengembalian selesai
User Endpoints
GET /api/user/equipment/requests.php - Daftar request user sendiri
POST /api/user/equipment/request/create.php - Buat request peralatan baru
GET /api/user/praktikum/schedule.php - Lihat jadwal praktikum
GET /api/user/lab-visits.php - Daftar kunjungan lab user
POST /api/user/lab-visits/create.php - Buat kunjungan lab baru
Fitur yang diimplementasikan
Role-based access: Admin, PLP, User dengan middleware
Filter by jurusan: PLP hanya melihat data sesuai jurusan mereka
Status management:
Peminjaman: "Menunggu", "Menunggu Konfirmasi", "Diterima", "Ditolak", "Menunggu Dikembalikan", "Selesai"
Peminjaman_detail: "Menunggu Konfirmasi", "Dipinjamkan", "Dikembalikan", "Habis Pakai", "Pemakaian", "Ditolak", "Hilang"
Req_jadwal_praktikum: "Menunggu", "Diterima", "Ditolak"
Transaction safety: Create/update operations menggunakan database transactions
Items aggregation: Endpoint items menggabungkan 3 tabel (barang_inventaris, barangbhp_alat, barangbhp_bahan)
Auto-create schedule: Approve request jadwal otomatis membuat jadwal_praktikum
File location
Semua file berada di folder api/ dengan struktur:

```
api/
├── auth/
│   ├── change-password.php
│   ├── login.php (sudah ada)
│   └── logout.php (sudah ada)
├── admin/
│   ├── users.php
│   ├── manage-users.php
│   ├── master-data.php
│   ├── users/
│   │   ├── add.php
│   │   ├── edit.php
│   │   └── delete.php
│   └── rooms/
│       ├── add.php
│       ├── edit.php
│       └── delete.php
├── plp/
│   ├── items.php
│   ├── loans.php
│   ├── praktikum/
│   │   └── schedule.php
│   ├── equipment/
│   │   └── requests.php
│   ├── requests/
│   │   ├── detail.php
│   │   ├── approve.php
│   │   └── reject.php
│   ├── schedule/
│   │   └── requests/
│   │       ├── approve.php
│   │       └── reject.php
│   └── loans/
│       └── return.php
└── user/
    ├── praktikum/
    │   └── schedule.php
    ├── equipment/
    │   ├── requests.php
    │   └── request/
    │       └── create.php
    └── lab-visits/
        └── create.php
```
Validasi tanpa emulator
Static analysis: Semua file menggunakan prepared statements
Database transactions: Untuk operasi multi-table
Error handling: Try-catch dengan logging
Input validation: Validasi field required dan format
Role checking: Middleware memastikan role yang tepat
Semua endpoint siap digunakan dan mengikuti format response yang sama seperti yang sudah ada.