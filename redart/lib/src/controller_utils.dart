import 'dart:async';

import 'package:redart/redart.dart';

/// mixin for any class that has reactive fields
/// should be removed and replaced by a macro, or augmented library
mixin ControllerUtils {
  void scheduleCallback(Callback callback) {
    if(scheduledCallbacks.isEmpty) {
      scheduleMicrotask(() {
        for (final callback in [...scheduledCallbacks]) {
          callback();
        }
        scheduledCallbacks.clear();
      });
    }
    scheduledCallbacks.add(callback);
  }

  final List<Callback> disposeListeners = [];

  void dispose() {
    for (final dispose in disposeListeners) {
      dispose();
    }
  }
}
