import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:macless_haystack/item_management/item_file_import.dart';

class ItemPasteImport extends StatefulWidget {
  /// Lets the user paste an accessories JSON file's contents instead of
  /// picking a file, for browsers where the native file picker does not
  /// open (e.g. a Flutter web app rendered to a canvas in an automated
  /// or remote browser).
  const ItemPasteImport({super.key});

  @override
  State<ItemPasteImport> createState() => _ItemPasteImportState();
}

class _ItemPasteImportState extends State<ItemPasteImport> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _import() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() {
        _error = 'Paste the JSON file contents first.';
      });
      return;
    }
    Uint8List bytes;
    try {
      // Validate that it is JSON before handing it to the file import,
      // which also parses it and shows its own error if it is not.
      jsonDecode(text);
      bytes = Uint8List.fromList(utf8.encode(text));
    } catch (e) {
      setState(() {
        _error = 'That does not look like valid JSON. Check the pasted text.';
      });
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ItemFileImport(bytes: bytes),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paste JSON'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ListTile(
                title: Text(
                    'Paste the full contents of an accessories JSON file below. The same import screen as the file import will open.'),
              ),
              TextField(
                controller: _controller,
                maxLines: 12,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: '[{"id": 123, "name": "...", ...}]',
                  labelText: 'Accessories JSON',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _error!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _import,
                child: const Text('Import'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
