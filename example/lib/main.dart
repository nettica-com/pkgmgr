import 'package:flutter/material.dart';
import 'dart:async';

import 'dart:convert';
import 'package:pkgmgr/pkgmgr.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _pkgmgrPlugin = Pkgmgr();
  List<AppInfo> _apps = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    try {
      final apps = await _pkgmgrPlugin.getInstalledApps();
      if (!mounted) return;
      setState(() {
        _apps = List<AppInfo>.from(apps)
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        _loading = false;
      });
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
        appBar: AppBar(
          title: const Text('Installed Apps'),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: \\$_error'))
                : ListView.builder(
                    itemCount: _apps.length,
                    itemBuilder: (context, index) {
                      final app = _apps[index];
                      return ListTile(
                        leading: app.iconBase64 != null
                            ? Image.memory(
                                base64Decode(app.iconBase64!),
                                width: 40,
                                height: 40,
                              )
                            : const Icon(Icons.apps),
                        title: Text(app.name),
                        subtitle: Text(app.packageId),
                      );
                    },
                  ),
      ),
    );
  }
}
