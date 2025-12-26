import 'dart:io';

import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:uuid/uuid.dart';

class LocalLibraryRepository {
  LocalLibraryRepository(
    this._database,
    this._store,
  );

  final Database _database;
  final StoreRef<String, Map<String, dynamic>> _store;
  final Uuid _uuid = const Uuid();
  static const Set<String> _supportedFileTypes = {'epub', 'txt'};

  Future<List<LocalBook>> loadAll() async {
    final records = await _store.find(
      _database,
      finder: Finder(sortOrders: [SortOrder('title')]),
    );
    return records
        .map(
          (record) => LocalBook.fromMap(
            record.value,
            id: record.key,
          ),
        )
        .where((book) => _supports(book.fileType))
        .toList();
  }

  Future<LocalBook> importFile(File file) async {
    final Directory booksDir = await _getBooksDir();
    final fileType = extension(file.path)
        .replaceFirst('.', '')
        .toLowerCase()
        .trim();
    if (!_supports(fileType)) {
      throw UnsupportedError('Only EPUB and TXT files can be imported.');
    }
    final id = _uuid.v4();
    final fileName = '$id.$fileType';
    final targetFile = await file.copy(join(booksDir.path, fileName));

    final book = LocalBook(
      id: id,
      title: basenameWithoutExtension(file.path),
      author: null,
      filePath: targetFile.path,
      fileType: fileType,
      coverPath: null,
      importedAt: DateTime.now(),
    );

    await _store.record(id).put(_database, book.toMap());
    return book;
  }

  Future<void> remove(String id) async {
    final stored = await _store.record(id).get(_database);
    if (stored != null) {
      final path = stored['filePath'] as String?;
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
    await _store.record(id).delete(_database);
  }

  Future<void> update(LocalBook book) async {
    await _store.record(book.id).update(_database, book.toMap());
  }

  bool _supports(String fileType) =>
      _supportedFileTypes.contains(fileType.toLowerCase());

  Future<Directory> _getBooksDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final booksDir = Directory(join(dir.path, 'books'));
    if (!await booksDir.exists()) {
      await booksDir.create(recursive: true);
    }
    return booksDir;
  }
}
