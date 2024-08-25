library redart;

import '../redart.dart';

Listener? reListener; // TODO daname to activeListener
bool reReadWithoutListening = false;
final Set<Callback> scheduledCallbacks = {};
