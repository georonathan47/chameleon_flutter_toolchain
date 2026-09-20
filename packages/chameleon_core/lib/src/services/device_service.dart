// catches without on clauses are being ignored because in the current context,
// they are not needed
// ignore_for_file: avoid_catches_without_on_clauses

import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Service to get device information and headers
class DeviceService {
  const DeviceService();

  static DeviceInfoPlugin get _deviceInfo => DeviceInfoPlugin();

  /// Get a unique device identifier
  static Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown-ios-device';
      } else {
        return 'unknown-device';
      }
    } catch (e) {
      return 'unknown-device';
    }
  }

  /// Get device model
  static Future<String> getDeviceModel() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.model;
      } else {
        return 'unknown-model';
      }
    } catch (e) {
      return 'unknown-model';
    }
  }

  /// Get OS version
  static Future<String> getOSVersion() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.version.release;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.systemVersion;
      } else {
        return 'unknown-version';
      }
    } catch (e) {
      return 'unknown-version';
    }
  }

  /// Get comprehensive device headers for API requests
  static Future<Map<String, String>> getDeviceHeaders() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();
      const flutterVersion = kDebugMode ? 'Debug' : 'Release';

      final headers = <String, String>{};

      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        headers['User-Agent'] =
            '${packageInfo.appName}/${packageInfo.version} '
            '(${iosInfo.model}; iOS ${iosInfo.systemVersion}; '
            '${iosInfo.identifierForVendor}) '
            'Flutter/$flutterVersion';
        headers['X-Client-Device-ID'] =
            iosInfo.identifierForVendor ?? 'unknown-ios-device';
        headers['X-Device-Name'] = iosInfo.name;
        headers['X-Device-Model'] = iosInfo.model;
        headers['X-OS-Version'] = iosInfo.systemVersion;
        headers['X-Platform'] = 'iOS';
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        headers['User-Agent'] =
            '${packageInfo.appName}/${packageInfo.version} '
            '(${androidInfo.model}; Android ${androidInfo.version.release}; '
            '${androidInfo.id}) '
            'Flutter/$flutterVersion';
        headers['X-Client-Device-ID'] = androidInfo.id;
        headers['X-Device-Name'] = '${androidInfo.brand} ${androidInfo.model}';
        headers['X-Device-Model'] = androidInfo.model;
        headers['X-OS-Version'] = androidInfo.version.release;
        headers['X-Platform'] = 'Android';
      } else {
        headers['User-Agent'] =
            '${packageInfo.appName}/${packageInfo.version} (Unknown Device) Flutter/$flutterVersion';
        headers['X-Client-Device-ID'] = 'unknown-device';
        headers['X-Device-Name'] = 'Unknown Device';
        headers['X-Device-Model'] = 'Unknown';
        headers['X-OS-Version'] = 'Unknown';
        headers['X-Platform'] = 'Unknown';
      }

      headers['X-App-Version'] = packageInfo.version;
      headers['X-App-Build-Number'] = packageInfo.buildNumber;
      headers['X-App-Name'] = packageInfo.appName;

      return headers;
    } catch (e) {
      // Fallback headers in case of error
      return {
        'User-Agent':
            'Unknown App/Unknown Version (Unknown Device) Flutter/Unknown',
        'X-Client-Device-ID': 'unknown-device',
        'X-Device-Name': 'Unknown Device',
        'X-Device-Model': 'Unknown',
        'X-OS-Version': 'Unknown',
        'X-Platform': 'Unknown',
        'X-App-Version': 'Unknown',
        'X-App-Build-Number': 'Unknown',
        'X-App-Name': 'Unknown',
      };
    }
  }
}
