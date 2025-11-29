import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';
import '../widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

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
            _updateState(
              model,
              "${iosInfo.systemName} ${iosInfo.systemVersion}",
            );
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
      _errorMessage = "";
    });
  }

  void _updateError(String model, String os, String message) {
    setState(() {
      _deviceModel = model;
      _osVersion = os;
      _errorMessage = message;
    });
  }

  Widget _buildDeviceField(String label, String value, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 14.sp : 12.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Flexible(
            child: SelectableText(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: value.length > 50 ? 14.sp : 11.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.grey[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 236, 185, 245),
                  Color.fromARGB(255, 172, 130, 220),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text(
            'Informasi Perangkat',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/settings'),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: _errorMessage.isNotEmpty
                ? _buildErrorMessage()
                : _buildDeviceInfoCard(isMobile),
          ),
        ),
      );
    }

    // Layout untuk Web / Desktop
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(selectedPage: 'Device Info'),
          Expanded(
            child: Column(
              children: [
                _buildHeader(isMobile),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_errorMessage.isNotEmpty)
                            _buildErrorMessage()
                          else
                            _buildDeviceInfoCard(isMobile),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 9 : 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 236, 185, 245),
            Color.fromARGB(255, 172, 130, 220),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 17.sp),
            onPressed: () => context.go('/settings'),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Informasi Perangkat',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 17.sp),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoCard(bool isMobile) {
    return Align(
      alignment: Alignment.topCenter,
      child: Card(
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.devices,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Detail Perangkat",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: isMobile ? 15.sp : 13.sp,
                    ),
                  ),
                ],
              ),
              const Divider(),

              _buildDeviceField("Model", _deviceModel, isMobile),
              _buildDeviceField("OS", _osVersion, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.redAccent),
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
    );
  }
}
