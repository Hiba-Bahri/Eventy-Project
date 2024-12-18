import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String? stateValue;
  String? categoryValue;
  bool? isFeeNegotiable;
  double feeRange = 0;
  int experience = 0;
  String? label;
  bool filtersApplied = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(23),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Enter name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => setState(() => label = value),
              ),
              const SizedBox(height: 14),

              const Text('State', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: stateValue,
                items: [
                  'Ariana',
                  'Beja',
                  'Ben Arous',
                  'Bizerte',
                  'Gabes',
                  'Gafsa',
                  'Jendouba',
                  'Kairaouan',
                  'Kasserine',
                  'Kebili',
                  'Le Keef',
                  'Mahdia',
                  'La Manouba',
                  'Medenine',
                  'Monastir',
                  'Nabeul',
                  'Sfax',
                  'Sidi Bouzid',
                  'Siliana',
                  'Sousse',
                  'Tataouine',
                  'Tozeur',
                  'Tunis',
                  'Zaghouan'
                ]
                    .map((state) => DropdownMenuItem(
                          value: state,
                          child: Text(state),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => stateValue = value),
                decoration: InputDecoration(
                  hintText: 'Select state',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              const Text('Service Category',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: categoryValue,
                items: ['Catering', 'Delivery', 'Photography']
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => categoryValue = value),
                decoration: InputDecoration(
                  hintText: 'Select category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              const Text('Fee Negotiability',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: isFeeNegotiable == true
                            ? Colors.green
                            : Colors.grey,
                      ),
                      onPressed: () => setState(() => isFeeNegotiable = true),
                      child: const Text('Negotiable', style: TextStyle(color: Colors.white, fontSize: 13),)
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: isFeeNegotiable == false
                            ? Colors.red
                            : Colors.grey,
                      ),
                      onPressed: () => setState(() => isFeeNegotiable = false),
                      child: const Text('Not Negotiable', style: TextStyle(color: Colors.white, fontSize: 13),)
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              const Text('Fee Range',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: feeRange,
                min: 0,
                max: 1000,
                divisions: 10,
                label: feeRange.toStringAsFixed(0),
                onChanged: (value) => setState(() => feeRange = value),
              ),

              const Text('Experience',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter years of experience',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() => experience = int.tryParse(value) ?? 0);
                },
              ),
              const SizedBox(height: 16),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 12),
                  ),
                  onPressed: () {
                    filtersApplied = label == null &&
                        stateValue == null &&
                        categoryValue == null &&
                        isFeeNegotiable == null &&
                        feeRange == 0 &&
                        experience == 0;
                    Navigator.of(context).pop({
                      'label': label,
                      'state': stateValue,
                      'category': categoryValue,
                      'isFeeNegotiable': isFeeNegotiable,
                      'feeRange': feeRange,
                      'experience': experience,
                      'filtersApplied': !filtersApplied
                    });
                  },
                  child: const Text('Filter',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
