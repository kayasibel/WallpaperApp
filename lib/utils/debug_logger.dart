import 'package:flutter/foundation.dart';

/// Debug logging helper - Release modunda logları kapatır
void debugLog(String message) {
  if (kDebugMode) {
    print(message);
  }
}
