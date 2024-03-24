library redart;

import '../redart.dart';

Callback listen(Callback fn) {
  final prevListener = reListener;
  final List<List<Callback>> listeners = [];
  if (reReadWithoutListening) {
    reListener = null;
  } else {
    reListener = (fn, listeners);
  }
  // initial run
  fn();
  reListener = prevListener;

  // return dispose
  return () {
    for (final listener in listeners) {
      listener.remove(fn);
    }
  };
}
