import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher_module/url_launcher_module.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({super.key, required this.url});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  bool _triedLaunch = false;
  late final OpenUrlUseCase _openUrlUseCase;

  @override
  void initState() {
    super.initState();
    _openUrlUseCase = context.read<OpenUrlUseCase>();
    // Launch after first frame to ensure context is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _openUrl();
    });
  }

  Future<void> _openUrl() async {
    if (_triedLaunch) return; // guard against multiple calls
    _triedLaunch = true;

    final opened = await _openUrlUseCase(widget.url);
    if (opened && mounted) {
      Navigator.of(context).maybePop();
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
