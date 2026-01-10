/// Lab Room Model
/// 
/// Domain model for lab room management
/// Fields in camelCase, mapped from backend snake_case
/// fromJson factory only (no toJson needed for now)
class LabRoom {
  final int id;
  final String labName;
  final String department;
  final String campus;

  const LabRoom({
    required this.id,
    required this.labName,
    required this.department,
    required this.campus,
  });

  /// Parse from JSON (snake_case from API → camelCase)
  factory LabRoom.fromJson(Map<String, dynamic> json) {
    return LabRoom(
      id: json['id'] as int,
      labName: json['nama_ruang_lab'] as String, // Backend uses 'nama_ruang_lab'
      department: json['jurusan'] as String, // Backend uses 'jurusan'
      campus: json['kampus'] as String, // Backend uses 'kampus'
    );
  }
}
