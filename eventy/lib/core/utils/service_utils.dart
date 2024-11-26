class ServiceUtils {
static void addService(Map<String, List<String>> eventServices, String eventType, String service) {
    if (eventServices[eventType] != null && !eventServices[eventType]!.contains(service)) {
      eventServices[eventType]!.add(service);
    }
  }

  static void removeService(Map<String, List<String>> eventServices, String eventType, String service) {
    eventServices[eventType]?.remove(service);
  }
}