library redart;

import 'package:redart/redart.dart';

class Reactive<T> with ControllerUtils {
  T _value;

  final List<Callback> _listeners = [];

  Reactive(this._value);

  T get value {
    final prevListener = reListener;
    if (reReadWithoutListening) {
      reListener = null;
    }
    if (reListener != null) {
      if (!_listeners.contains(reListener!.$1)) {
        _listeners.add(reListener!.$1);
        reListener!.$2.add(_listeners);
      }
    }
    reListener = prevListener;
    return _value;
  }

  set value(T value) {
    _value = value;
    for (final listener in _listeners) {
      scheduleCallback(listener);
    }
  }
}
