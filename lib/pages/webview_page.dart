import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({super.key, required this.url});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  bool _triedLaunch = false;

  @override
  void initState() {
    super.initState();
    // Launch after first frame to ensure context is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _openUrl();
    });
  }

  Future<void> _openUrl() async {
    if (_triedLaunch) return; // guard against multiple calls
    _triedLaunch = true;

    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
        webOnlyWindowName: '_blank', // open new tab on web
      );
      // Return to previous page after launching
      if (mounted) Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Membuka tautan')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Membuka tautan di peramban...'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _openUrl,
              child: const Text('Buka ulang'),
            ),
          ],
        ),
      ),
    );
  }
}
