import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

void registerHtmlFileInput() {
  // No HTML input on non-web platforms.
}

Stream<Uint8List> get onHtmlFilePicked => const Stream.empty();

Widget htmlFileInputView() {
  return const Text(
      'A browser file input is only available on the web. Use the file picker or paste-JSON import instead.');
}
