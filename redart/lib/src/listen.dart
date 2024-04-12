library redart;

import '../redart.dart';

Callback listen(Callback fn) {
  final prevListener = reListener;
  final List<List<Callback>> listeners = [];
  wrappedListener() {
    listeners.clear();
    fn();
  }
  if (reReadWithoutListening) {
    reListener = null;
  } else {
    reListener = (wrappedListener, listeners);
  }
  // initial run
  fn();
  reListener = prevListener;

  // return dispose
  return () {
    for (final listener in listeners) {
      listener.remove(wrappedListener);
    }
  };
}
