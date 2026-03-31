import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:pkgmgr/pkgmgr.dart';

void main() {
  runApp(const MyApp());
}

final _pkgmgr = Pkgmgr();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<AppInfo> _apps = [];
  bool _loading = false;
  bool _onDemandIcons = false;
  String? _error;
  String? _memoryInfo;

  void _updateMemoryInfo() {
    final cacheMb = imageCache.currentSizeBytes / (1024 * 1024);
    setState(() {
      _memoryInfo =
          '${_apps.length} apps  |  image cache: ${cacheMb.toStringAsFixed(1)} MB';
    });
  }

  Future<void> _load(bool onDemand) async {
    setState(() {
      _loading = true;
      _error = null;
      _memoryInfo = null;
      _onDemandIcons = onDemand;
    });
    try {
      final apps = onDemand
          ? await _pkgmgr.getInstalledAppsInfo()
          : await _pkgmgr.getInstalledApps();
      apps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      setState(() {
        _apps = apps;
        _loading = false;
      });
      _updateMemoryInfo();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Installed Apps')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _loading ? null : () => _load(false),
                    child: const Text('All icons upfront'),
                  ),
                  ElevatedButton(
                    onPressed: _loading ? null : () => _load(true),
                    child: const Text('Icons on demand'),
                  ),
                ],
              ),
            ),
            if (_memoryInfo != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(_memoryInfo!, style: const TextStyle(fontSize: 18)),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text('Error: $_error'))
                  : RefreshIndicator(
                      onRefresh: () async => _updateMemoryInfo(),
                      child: ListView.builder(
                        itemCount: _apps.length,
                        itemBuilder: (context, index) {
                          final app = _apps[index];
                          return ListTile(
                            leading: _onDemandIcons
                                ? FutureBuilder<String?>(
                                    future: _pkgmgr.getAppIcon(app.packageId),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      }
                                      return snapshot.data != null
                                          ? Image.memory(
                                              base64Decode(snapshot.data!),
                                              width: 40,
                                              height: 40,
                                            )
                                          : const Icon(Icons.apps, size: 40);
                                    },
                                  )
                                : app.iconBase64 != null
                                ? Image.memory(
                                    base64Decode(app.iconBase64!),
                                    width: 40,
                                    height: 40,
                                  )
                                : const Icon(Icons.apps, size: 40),
                            title: Text(app.name),
                            subtitle: Text(app.packageId),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
