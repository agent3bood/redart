library redart;

import '../redart.dart';

Listener? reListener;
bool reReadWithoutListening = false;
final Set<Callback> scheduledCallbacks = {};
