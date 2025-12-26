import 'package:meta/meta.dart';

@immutable
class LocalBook {
  const LocalBook({
    required this.id,
    required this.title,
    required this.filePath,
    required this.fileType,
    this.author,
    this.coverPath,
    this.importedAt,
    this.lastOpenedAt,
  });

  final String id;
  final String title;
  final String? author;
  final String filePath;
  final String fileType;
  final String? coverPath;
  final DateTime? importedAt;
  final DateTime? lastOpenedAt;

  LocalBook copyWith({
    String? title,
    String? author,
    String? filePath,
    String? fileType,
    String? coverPath,
    DateTime? importedAt,
    DateTime? lastOpenedAt,
  }) {
    return LocalBook(
      id: id,
      title: title ?? this.title,
      author: author ?? this.author,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      coverPath: coverPath ?? this.coverPath,
      importedAt: importedAt ?? this.importedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    );
  }

  factory LocalBook.fromMap(
    Map<String, dynamic> data, {
    required String id,
  }) {
    return LocalBook(
      id: id,
      title: data['title'] as String? ?? 'Untitled',
      author: data['author'] as String?,
      filePath: data['filePath'] as String? ?? '',
      fileType: data['fileType'] as String? ?? '',
      coverPath: data['coverPath'] as String?,
      importedAt: _decodeDateTime(data['importedAt'] as String?),
      lastOpenedAt: _decodeDateTime(data['lastOpenedAt'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'author': author,
      'filePath': filePath,
      'fileType': fileType,
      'coverPath': coverPath,
      'importedAt': importedAt?.toIso8601String(),
      'lastOpenedAt': lastOpenedAt?.toIso8601String(),
    };
  }

  static DateTime? _decodeDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}
