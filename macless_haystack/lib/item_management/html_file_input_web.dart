// Web-only implementation of the visible HTML file input.
//
// Uses dart:html / dart:ui_web, which only exist on web. This file is
// only imported when dart.library.js_interop is available, via the
// conditional import in html_file_input.dart.
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

final _pickedController = StreamController<Uint8List>.broadcast();
bool _registered = false;

void registerHtmlFileInput() {
  if (_registered) {
    return;
  }
  _registered = true;
  ui_web.platformViewRegistry.registerViewFactory(
    'html-json-file-input',
    (int viewId) {
      final input = html.FileUploadInputElement()
        ..accept = '.json,application/json'
        ..style.width = '100%'
        ..style.fontSize = '16px';
      input.onChange.listen((_) {
        final files = input.files;
        if (files == null || files.isEmpty) {
          return;
        }
        final file = files.first;
        final reader = html.FileReader();
        reader.onLoadEnd.listen((_) {
          final result = reader.result;
          if (result is ByteBuffer) {
            _pickedController.add(result.asUint8List());
          } else if (result is List<int>) {
            _pickedController.add(Uint8List.fromList(result));
          }
        });
        reader.readAsArrayBuffer(file);
      });
      final container = html.DivElement()
        ..style.padding = '8px'
        ..append(input);
      return container;
    },
  );
}

Stream<Uint8List> get onHtmlFilePicked => _pickedController.stream;

Widget htmlFileInputView() {
  return const HtmlElementView(viewType: 'html-json-file-input');
}
