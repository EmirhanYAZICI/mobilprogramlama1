while (eventQueue.waitForEvent()) {
  eventQueue.processNextEvent();
}
