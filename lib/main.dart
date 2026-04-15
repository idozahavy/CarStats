import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers.dart';
import 'core/theme.dart';
import 'data/database/database.dart';
import 'screens/home/home_screen.dart';
import 'services/gps_service.dart';
import 'services/recording_engine.dart';
import 'services/sensor_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(AccelStatsApp(prefs: prefs));
}

class AccelStatsApp extends StatefulWidget {
  final SharedPreferences prefs;
  const AccelStatsApp({super.key, required this.prefs});

  @override
  State<AccelStatsApp> createState() => _AccelStatsAppState();
}

class _AccelStatsAppState extends State<AccelStatsApp> {
  late final SensorService _sensorService;
  late final GpsService _gpsService;
  late final AppDatabase _db;

  @override
  void initState() {
    super.initState();
    _sensorService = SensorService();
    _gpsService = GpsService();
    _db = AppDatabase();
  }

  @override
  void dispose() {
    _sensorService.dispose();
    _gpsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<RecordingStore>.value(value: _db),
        ChangeNotifierProvider(create: (_) => ThemeProvider(widget.prefs)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(widget.prefs)),
        ChangeNotifierProvider(
          create: (_) => RecordingEngine(
            db: _db,
            sensorService: _sensorService,
            gpsService: _gpsService,
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'AccelStats',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeProvider.themeMode,
            home: const _PermissionGate(),
          );
        },
      ),
    );
  }
}

class _PermissionGate extends StatefulWidget {
  const _PermissionGate();

  @override
  State<_PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<_PermissionGate> {
  bool _granted = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    bool granted = false;
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      granted = permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    }
    setState(() {
      _granted = granted;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    if (!_granted) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Location Permission Required',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'AccelStats needs GPS access to measure speed. Please grant location permission.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _checkPermission,
                    child: const Text('Grant Permission'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return const HomeScreen();
  }
}
