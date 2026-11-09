import 'dart:convert';

import 'package:flutter/material.dart';

class AccessoryAdditionalKeysInput extends StatelessWidget {
  final ValueChanged<String?> changeListener;

  /// Displays a multi-line input field for additional Base64 encoded
  /// accessory private keys (one per line), used for key rotation.
  ///
  /// Empty input is allowed (no additional keys). Each non-empty line
  /// must be a valid Base64 private key, matching the format of the
  /// `additionalKeys` entries in an exported accessories JSON file.
  const AccessoryAdditionalKeysInput({
    super.key,
    required this.changeListener,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: TextFormField(
        maxLines: 4,
        keyboardType: TextInputType.multiline,
        decoration: const InputDecoration(
          hintText: 'SGVsbG8gV29ybGQhCg==\nSGVsbG8gV29ybGQhCg==',
          labelText: 'Additional Private Keys (Base64, one per line)',
          helperText:
              'Optional: one Base64 private key per line, for key rotation.',
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return null;
          }
          for (final line in value.split('\n')) {
            final key = line.trim().replaceAll('\\', '');
            if (key.isEmpty) {
              continue;
            }
            try {
              base64Decode(key);
            } catch (e) {
              return 'Each additional key must be a valid base64 key.';
            }
          }
          return null;
        },
        onSaved: (newValue) => changeListener(newValue),
      ),
    );
  }
}
