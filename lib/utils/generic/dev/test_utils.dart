import "package:flutter/material.dart";

import "package:path_provider_platform_interface/path_provider_platform_interface.dart";

/// {@category Utils - Generic}
/// A generic utility class used to define a folder value for getApplicationSupportPath (PathProvider) when testing.
class PathProviderPlatformRedirectForTesting extends PathProviderPlatform {
  PathProviderPlatformRedirectForTesting(this._path);

  final String _path;

  @override
  Future<String?> getApplicationSupportPath() async => _path;
}

/// {@category Utils - Generic}
/// A getter to test if a test is being run.
bool get isInTestEnvironment =>
    WidgetsBinding.instance.runtimeType.toString().contains("Test");