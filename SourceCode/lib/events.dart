

class EventHandler {

  Map callbacks = {};

  void add(Function callback, String callIn) {
    if (callbacks.keys.contains(callIn)) {
      callbacks[callIn].add(callback);
    } else {
      callbacks[callIn] = [callback];
    }
  }

  void call(String callIn) {
    for (Function call in callbacks[callIn]) {
      call();
    }
  }
}