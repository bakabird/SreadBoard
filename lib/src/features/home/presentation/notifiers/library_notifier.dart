import 'dart:io';

import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_ebook_app/src/features/home/data/repositories/local_library_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library_notifier.g.dart';

final localLibraryRepositoryProvider =
    Provider.autoDispose<LocalLibraryRepository>(
  (ref) => LocalLibraryRepository(
    ref.watch(libraryDatabaseProvider),
    ref.watch(storeRefProvider),
  ),
);

@riverpod
class LibraryNotifier extends _$LibraryNotifier {
  @override
  Future<List<LocalBook>> build() async {
    final repo = ref.read(localLibraryRepositoryProvider);
    return repo.loadAll();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () async => ref.read(localLibraryRepositoryProvider).loadAll(),
    );
  }

  Future<void> importFiles(List<File> files) async {
    final repo = ref.read(localLibraryRepositoryProvider);
    final existing = state.valueOrNull ?? [];

    try {
      final imported = <LocalBook>[];
      for (final file in files) {
        final book = await repo.importFile(file);
        imported.add(book);
      }
      state = AsyncValue.data([...existing, ...imported]);
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
      rethrow;
    }
  }

  Future<void> removeBook(String id) async {
    final repo = ref.read(localLibraryRepositoryProvider);
    final current = state.valueOrNull;
    if (current == null) return;

    await repo.remove(id);
    state = AsyncValue.data(
      current.where((book) => book.id != id).toList(),
    );
  }

  Future<void> markBookOpened(LocalBook book) async {
    final updated = book.copyWith(lastOpenedAt: DateTime.now());
    await ref.read(localLibraryRepositoryProvider).update(updated);
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncValue.data([
      for (final existing in current)
        if (existing.id == updated.id) updated else existing,
    ]);
  }
}
