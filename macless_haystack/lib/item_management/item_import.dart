import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:macless_haystack/accessory/accessory_model.dart';
import 'package:macless_haystack/accessory/accessory_registry.dart';
import 'package:macless_haystack/findMy/find_my_controller.dart';
import 'package:macless_haystack/item_management/accessory_additional_keys_input.dart';
import 'package:macless_haystack/item_management/accessory_color_input.dart';
import 'package:macless_haystack/item_management/accessory_icon_input.dart';
import 'package:macless_haystack/item_management/accessory_id_input.dart';
import 'package:macless_haystack/item_management/accessory_name_input.dart';
import 'package:macless_haystack/item_management/accessory_pk_input.dart';

class AccessoryImport extends StatefulWidget {
  /// Displays an input form to manually import an accessory.
  const AccessoryImport({super.key});

  @override
  State<AccessoryImport> createState() => _AccessoryImportState();
}

class _AccessoryImportState extends State<AccessoryImport> {
  /// Stores the properties of the accessory to import.
  Accessory newAccessory = Accessory(
      id: '',
      name: '',
      hashedPublicKey: '',
      datePublished: DateTime.now(),
      hashesWithTS: {},
      locationHistory: [],
      lastBatteryStatus: null,
      additionalKeys: List.empty());
  String privateKey = '';
  String additionalKeysText = '';

  final _formKey = GlobalKey<FormState>();

  /// Parses the additional-keys text field: one Base64 private key per
  /// line, ignoring blank lines. Duplicates of the primary key are
  /// dropped, since that key is already stored as the primary key.
  List<String> _parseAdditionalKeys() {
    final seen = <String>{privateKey};
    final keys = <String>[];
    for (final line in additionalKeysText.split('\n')) {
      final key = line.trim().replaceAll('\\', '');
      if (key.isEmpty || seen.contains(key)) {
        continue;
      }
      seen.add(key);
      keys.add(key);
    }
    return keys;
  }

  /// Imports the private key and any additional (rotation) private keys
  /// to the key store. Like the file import, additional keys are stored
  /// on the accessory as their hashed public keys.
  Future<void> importKey(BuildContext context) async {
    if (_formKey.currentState != null) {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        try {
          var keyPair = await FindMyController.importKeyPair(privateKey);
          newAccessory.hashedPublicKey = keyPair.hashedPublicKey;

          final additionalHashedKeys = <String>[];
          for (final additionalKey in _parseAdditionalKeys()) {
            final additionalKeyPair =
                await FindMyController.importKeyPair(additionalKey);
            additionalHashedKeys.add(additionalKeyPair.hashedPublicKey);
          }
          newAccessory.additionalKeys = additionalHashedKeys;
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Key import failed. Check if private key is correct.'),
              ),
            );
          }
          return;
        }

        if (context.mounted) {
          AccessoryRegistry accessoryRegistry =
              Provider.of<AccessoryRegistry>(context, listen: false);
          accessoryRegistry.addAccessory(newAccessory);
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Accessory'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const ListTile(
                title: Text(
                    'Please enter the accessory parameters. They can be found in the exported accessory file.'),
              ),
              AccessoryIdInput(
                changeListener: (id) => setState(() {
                  newAccessory.id = id!;
                }),
              ),
              AccessoryNameInput(
                onSaved: (name) => setState(() {
                  newAccessory.name = name!;
                }),
              ),
              AccessoryIconInput(
                initialIcon: newAccessory.icon,
                iconString: newAccessory.rawIcon,
                color: newAccessory.color,
                changeListener: (String? selectedIcon) {
                  if (selectedIcon != null) {
                    setState(() {
                      newAccessory.setIcon(selectedIcon);
                    });
                  }
                },
              ),
              AccessoryColorInput(
                color: newAccessory.color,
                changeListener: (Color? selectedColor) {
                  if (selectedColor != null) {
                    setState(() {
                      newAccessory.color = selectedColor;
                    });
                  }
                },
              ),
              AccessoryPrivateKeyInput(
                changeListener: (String? privateKeyVal) async {
                  if (privateKeyVal != null) {
                    setState(() {
                      privateKey = privateKeyVal;
                    });
                  }
                },
              ),
              AccessoryAdditionalKeysInput(
                changeListener: (String? additionalKeysVal) {
                  setState(() {
                    additionalKeysText = additionalKeysVal ?? '';
                  });
                },
              ),
              SwitchListTile(
                value: newAccessory.isActive,
                title: const Text('Is Active'),
                onChanged: (checked) {
                  setState(() {
                    newAccessory.isActive = checked;
                  });
                },
              ),
              ListTile(
                title: ElevatedButton(
                  child: const Text('Import'),
                  onPressed: () => importKey(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
