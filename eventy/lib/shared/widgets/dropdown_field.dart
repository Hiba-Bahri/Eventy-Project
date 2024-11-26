import 'package:flutter/material.dart';

class DropdownField<T> extends StatelessWidget {
  final T? value;
  final String hintText;
  final List<T> items;
  final void Function(T?) onChanged;
  final bool Function(T)? filterItems;

  const DropdownField({
    super.key,
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.filterItems,
  });

  @override
  Widget build(BuildContext context) {
    // Filter items if a filter function is provided
    final filteredItems = filterItems != null 
      ? items.where(filterItems!).toList() 
      : items;

    return DropdownButtonFormField<T>(
      value: _validateValue(value, filteredItems),
      hint: Text(hintText),
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
      items: filteredItems.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(item.toString()),
        );
      }).toList(),
      onChanged: (T? newValue) {
        onChanged(newValue);
      },
    );
  }

  // Validate and adjust the selected value
  T? _validateValue(T? currentValue, List<T> availableItems) {
    // If no items, return null
    if (availableItems.isEmpty) return null;

    // If current value is null or not in the list, return null
    if (currentValue == null || 
        !availableItems.contains(currentValue)) {
      return null;
    }

    return currentValue;
  }
}