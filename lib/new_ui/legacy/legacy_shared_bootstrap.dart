import 'dart:async';

import 'package:dsm_helper/models/Syno/Core/Desktop/InitData.dart';
import 'package:dsm_helper/providers/init_data_provider.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef LegacyInitDataLoader = Future<InitDataModel> Function();

class LegacySharedBootstrap {
  LegacySharedBootstrap({LegacyInitDataLoader? loadInitData})
      : _loadInitData = loadInitData ?? InitDataModel.get;

  final LegacyInitDataLoader _loadInitData;

  Future<void> ensureLoaded(InitDataProvider provider) async {
    final existing = provider.initData;
    final existingMajorVersion = existing.session?.majorversion;
    if (existingMajorVersion != null) {
      Utils.version = int.parse(existingMajorVersion);
      return;
    }

    final initData = await _loadInitData();
    final majorVersion = int.parse(initData.session!.majorversion!);

    // Version-dependent legacy consumers may rebuild as soon as InitDataProvider
    // notifies, so publish the matching DSM version first.
    Utils.version = majorVersion;
    provider.setInitData(initData);
  }
}

class LegacySharedBootstrapBoundary extends StatefulWidget {
  const LegacySharedBootstrapBoundary({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  State<LegacySharedBootstrapBoundary> createState() =>
      _LegacySharedBootstrapBoundaryState();
}

class _LegacySharedBootstrapBoundaryState
    extends State<LegacySharedBootstrapBoundary> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      unawaited(_prepare());
    } else {
      _ready = true;
    }
  }

  Future<void> _prepare() async {
    try {
      final provider = context.read<InitDataProvider>();
      await LegacySharedBootstrap().ensureLoaded(provider);
    } catch (_) {
      // Preserve the existing shell/offline fallback semantics if this
      // compatibility bootstrap cannot be completed.
    } finally {
      if (mounted) {
        setState(() {
          _ready = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Center(child: CircularProgressIndicator());
    }
    return widget.child;
  }
}
