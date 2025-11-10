import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({super.key});

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  String _deviceModel = "Memuat...";
  String _osVersion = "Memuat...";
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    setState(() {
      _deviceModel = "Memuat...";
      _osVersion = "Memuat...";
      _errorMessage = "";
    });

    try {
      if (kIsWeb) {
        final webInfo = await deviceInfoPlugin.webBrowserInfo;
        String browserName = webInfo.browserName.name;
        String osHost = _extractOsFromUserAgent(webInfo.userAgent ?? "");
        String model = "Web Browser";
        String osDetail = "$osHost | Browser: $browserName";
        _updateState(model, osDetail);
      } else {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
          final androidInfo = await deviceInfoPlugin.androidInfo;
          _updateState(
            androidInfo.model,
            "Android ${androidInfo.version.release}",
          );
            break;
          case TargetPlatform.iOS:
          final iosInfo = await deviceInfoPlugin.iosInfo;
          String model = iosInfo.name.isNotEmpty
              ? iosInfo.name
              : iosInfo.utsname.machine;
          _updateState(model, "${iosInfo.systemName} ${iosInfo.systemVersion}");
            break;
          case TargetPlatform.windows:
          final windowsInfo = await deviceInfoPlugin.windowsInfo;
          String osName = windowsInfo.buildNumber >= 22000
              ? "Windows 11"
              : "Windows ${windowsInfo.buildNumber > 0 ? 10 : ''}";
          String modelName = windowsInfo.computerName.isNotEmpty
              ? windowsInfo.computerName
              : (windowsInfo.editionId.isNotEmpty
                  ? "Edisi ${windowsInfo.editionId}"
                  : 'Windows');
          _updateState(
            modelName,
            "$osName (Build ${windowsInfo.buildNumber}, Release ${windowsInfo.releaseId})",
          );
            break;
          case TargetPlatform.macOS:
            final mac = await deviceInfoPlugin.macOsInfo;
            _updateState(
              mac.computerName ?? 'Mac',
              'macOS ${mac.osRelease}',
            );
            break;
          case TargetPlatform.linux:
            final linux = await deviceInfoPlugin.linuxInfo;
            _updateState(
              linux.prettyName ?? 'Linux',
              linux.version ?? '',
            );
            break;
          default:
            _updateState('Perangkat', 'OS tidak dikenal');
        }
      }
    } catch (e) {
      _updateError(
        "GAGAL DETEKSI",
        "Error: $e",
        "Gagal mengambil info perangkat. Coba jalankan 'flutter clean' dan 'flutter pub get'.",
      );
      debugPrint("Device Info Error: $e");
    }
  }

  String _extractOsFromUserAgent(String userAgent) {
    if (userAgent.contains('Windows NT 10.0')) return 'Windows 10/11';
    if (userAgent.contains('Macintosh')) return 'macOS';
    if (userAgent.contains('iPhone')) return 'iOS';
    if (userAgent.contains('Android')) return 'Android';
    if (userAgent.contains('Linux')) return 'Linux';
    return 'Unknown Host OS';
  }

  void _updateState(String model, String os) {
    setState(() {
      _deviceModel = model;
      _osVersion = os;
    });
  }

  void _updateError(String model, String os, String message) {
    setState(() {
      _deviceModel = model;
      _osVersion = os;
      _errorMessage = message;
    });
  }

  Widget _buildDeviceField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.deepPurple,
            ),
          ),
          Flexible(
            child: SelectableText(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: value.length > 50 ? 12 : 15,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _deviceModel == "Memuat..." && _errorMessage.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Informasi Perangkat"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    shadowColor: Colors.deepPurple.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.devices,
                                color: Colors.deepPurple,
                                size: 30,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Detail Perangkat",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.deepPurple, thickness: 1),
                          const SizedBox(height: 6),
                          _buildDeviceField("Model", _deviceModel),
                          _buildDeviceField("OS", _osVersion),
                        ],
                      ),
                    ),
                  ),
                  if (_errorMessage.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: GoogleFonts.poppins(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
