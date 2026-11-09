import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import 'html_file_input_stub.dart'
    if (dart.library.js_interop) 'html_file_input_web.dart';

/// A visible, real HTML `<input type="file">` element, shown through an
/// [HtmlElementView].
///
/// The `file_picker` package creates a hidden input and clicks it
/// programmatically, which never opens a native file dialog in some
/// browsers (notably the automated / remote browser, where the Flutter
/// app is rendered to a canvas). A visible input that the user clicks
/// directly is a real DOM element, so the browser treats it as a
/// genuine user gesture and shows its native picker.
///
/// On non-web platforms this is a no-op stub: use the file picker or
/// paste-JSON import instead.
abstract class HtmlFileInput {
  /// Registers the platform-view factory. Safe to call more than once.
  static void register() => registerHtmlFileInput();

  /// Stream of picked file contents, one event per chosen file.
  static Stream<Uint8List> get onFilePicked => onHtmlFilePicked;

  /// The widget showing the visible file input, or an explanatory
  /// placeholder on platforms without an HTML input.
  static Widget fileInputView() => htmlFileInputView();
}
