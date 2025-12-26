import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_ebook_app/src/features/features.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreenSmall extends ConsumerStatefulWidget {
  const HomeScreenSmall({super.key});

  @override
  ConsumerState<HomeScreenSmall> createState() => _HomeScreenSmallState();
}

class _HomeScreenSmallState extends ConsumerState<HomeScreenSmall> {
  Future<void> _refreshLibrary() async {
    await ref.read(libraryNotifierProvider.notifier).refresh();
  }

  Future<void> _importBooks() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['epub', 'txt'],
    );
    if (result == null) return;

    final files = result.files
        .where((file) => file.path != null)
        .map((file) => File(file.path!))
        .toList();
    if (files.isEmpty) {
      _showSnackBar('Unable to import these files.');
      return;
    }
    try {
      await ref.read(libraryNotifierProvider.notifier).importFiles(files);
      _showSnackBar('Imported ${files.length} book(s).');
    } on UnsupportedError catch (err) {
      _showSnackBar(err.message ?? 'Only EPUB and TXT files are supported.');
    } catch (_) {
      _showSnackBar('Failed to import books.');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final libraryState = ref.watch(libraryNotifierProvider);
    return Scaffold(
      appBar: context.isSmallScreen
          ? AppBar(
              centerTitle: true,
              title: const Text(
                appName,
                style: TextStyle(fontSize: 20.0),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.file_upload),
                  onPressed: _importBooks,
                ),
              ],
            )
          : null,
      floatingActionButton: context.isSmallScreen
          ? FloatingActionButton.extended(
              onPressed: _importBooks,
              icon: const Icon(Icons.library_add),
              label: const Text('Import'),
            )
          : null,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: libraryState.when(
            loading: () => const LoadingWidget(),
            error: (_, __) => MyErrorWidget(
                  refreshCallBack: _refreshLibrary,
                ),
            data: (books) {
              if (books.isEmpty) {
                return _EmptyLibrary(onImport: _importBooks);
              }
              return RefreshIndicator(
                onRefresh: _refreshLibrary,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return _LocalBookTile(
                      book: book,
                      onRemove: () => ref
                          .read(libraryNotifierProvider.notifier)
                          .removeBook(book.id),
                    );
                  },
                ),
              );
            }),
      ),
    );
  }
}

class _LocalBookTile extends StatelessWidget {
  const _LocalBookTile({
    required this.book,
    required this.onRemove,
  });

  final LocalBook book;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 48,
      height: 64,
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      ),
      child: const Icon(Icons.menu_book),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Card(
        child: ListTile(
          leading: placeholder,
          title: Text(book.title),
          subtitle: Text(book.author ?? 'Unknown author'),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onRemove,
          ),
        ),
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.onImport});

  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.library_books, size: 64),
            const SizedBox(height: 12),
            const Text(
              'No books yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Import EPUB or TXT files from your device to start reading.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.file_upload),
              label: const Text('Import books'),
            ),
          ],
        ),
      ),
    );
  }
}
