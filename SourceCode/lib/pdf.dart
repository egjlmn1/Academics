import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class PDFViewer extends StatelessWidget {

  final String url;

  const PDFViewer({Key key, this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF View'),
      ),
      body: PDF(
        //nightMode: DarkThemePreference().getTheme(),
      ).cachedFromUrl(url),
    );
  }
}
