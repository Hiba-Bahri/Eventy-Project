class Serviceprovideravailability {
  final String providerId;
  final Map<DateTime, List<String>> availableTimeSlots;

  Serviceprovideravailability({
    required this.providerId,
    required this.availableTimeSlots,
  });

  /// Returns a list of available dates.
  List<DateTime> get availableDates => availableTimeSlots.keys.toList();

  /// Checks if the provider has available time slots for a specific date.
  bool hasTimeSlots(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return availableTimeSlots.keys.any((availableDate) =>
        DateTime(availableDate.year, availableDate.month, availableDate.day) ==
        normalizedDate);
  }

  /// Returns the available time slots for a specific date.
  List<String> getTimeSlotsForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final matchingDate = availableTimeSlots.keys.firstWhere(
      (availableDate) =>
          DateTime(availableDate.year, availableDate.month, availableDate.day) ==
          normalizedDate,
      orElse: () => DateTime(0),
    );
    return matchingDate == DateTime(0)
        ? []
        : availableTimeSlots[matchingDate] ?? [];
  }
}