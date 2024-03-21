library redart;

import '../redart.dart';

Function listen(Callback fn) {
  final prevListener = reListener;
  // initial run
  final List<List<Callback>> listeners = [];
  reListener = (fn, listeners);
  fn();
  reListener = prevListener;

  // return dispose
  return () {
    for (final listener in listeners) {
      listener.remove(fn);
    }
  };
}
