import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:macless_haystack/item_management/html_file_input.dart';
import 'package:macless_haystack/item_management/item_file_import.dart';
import 'package:macless_haystack/item_management/item_paste_import.dart';

class ItemHtmlFileImport extends StatefulWidget {
  /// Imports accessories through a visible, real HTML file input.
  ///
  /// Unlike the `file_picker` package, which creates a hidden input and
  /// clicks it programmatically (a click that never opens a native file
  /// dialog in some browsers), this page shows the actual
  /// `<input type="file">` element, so tapping it is a genuine user
  /// gesture on a real DOM element.
  const ItemHtmlFileImport({super.key});

  @override
  State<ItemHtmlFileImport> createState() => _ItemHtmlFileImportState();
}

class _ItemHtmlFileImportState extends State<ItemHtmlFileImport> {
  StreamSubscription<Uint8List>? _subscription;

  @override
  void initState() {
    super.initState();
    HtmlFileInput.register();
    _subscription = HtmlFileInput.onFilePicked.listen((bytes) {
      if (!mounted) {
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ItemFileImport(bytes: bytes),
        ),
      );
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from JSON File (Browser)'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ListTile(
                title: Text(
                    'Tap the file input below and choose an accessories JSON file. This uses a real browser file input, not the hidden one from the file picker.'),
              ),
              SizedBox(
                height: 64,
                child: HtmlFileInput.fileInputView(),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ItemPasteImport(),
                    ),
                  );
                },
                child: const Text('Or paste the JSON instead'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
