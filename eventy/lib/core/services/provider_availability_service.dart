class ProviderAvailability {
  final String providerId;
  final Map<DateTime, List<String>> availableTimeSlots;

  ProviderAvailability({
    required this.providerId,
    required this.availableTimeSlots,
  });

  bool hasTimeSlots(DateTime date) {
    return availableTimeSlots.keys.any((key) => 
      isSameDay(key, date)
    );
  }

  List<String> getTimeSlotsForDate(DateTime date) {
    final matchingDate = availableTimeSlots.keys.firstWhere(
      (key) => isSameDay(key, date), 
      orElse: () => DateTime.now()
    );    
    return availableTimeSlots[matchingDate] ?? [];
  }
  

  // Utility method to check if two dates are the same day
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }
}