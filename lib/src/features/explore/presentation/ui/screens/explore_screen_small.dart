import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_ebook_app/src/features/features.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class ExploreScreenSmall extends ConsumerWidget {
  const ExploreScreenSmall({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: context.isSmallScreen
          ? AppBar(centerTitle: true, title: const Text('Explore'))
          : null,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 64),
              const SizedBox(height: 12),
              const Text(
                'Online catalog disabled',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'This build is local-first. Import books from your device on the Home tab to populate your library.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(currentTabNotifierProvider).value = 0;
                },
                icon: const Icon(Icons.library_books),
                label: const Text('Go to bookshelf'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
