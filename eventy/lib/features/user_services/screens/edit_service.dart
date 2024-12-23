import 'package:eventy/core/providers/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditServiceScreen extends StatefulWidget {
  final String serviceId;

  const EditServiceScreen({Key? key, required this.serviceId}) : super(key: key);

  @override
  _EditServiceScreenState createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _label;
  late String _category;
  late String _state;
  late String _description;
  late double _fee;
  late bool _isFeeNegotiable;
  late int _experience;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
    final service = await serviceProvider.fetchServiceById(widget.serviceId);

    if (service != null) {
      setState(() {
        _label = service.label;
        _category = service.category;
        _state = service.state;
        _description = service.description;
        _fee = service.fee;
        _isFeeNegotiable = service.isFeeNegotiable;
        _experience = service.experience;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: _label,
                  decoration: const InputDecoration(labelText: 'Service Label'),
                  onSaved: (value) => _label = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a label';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  onSaved: (value) => _category = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: _state,
                  decoration: const InputDecoration(labelText: 'State'),
                  onSaved: (value) => _state = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a state';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: _description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  onSaved: (value) => _description = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: _fee.toString(),
                  decoration: const InputDecoration(labelText: 'Fee'),
                  onSaved: (value) => _fee = double.tryParse(value!) ?? 0,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a fee';
                    }
                    return null;
                  },
                ),
                SwitchListTile(
                  title: const Text('Fee Negotiable'),
                  value: _isFeeNegotiable,
                  onChanged: (value) {
                    setState(() {
                      _isFeeNegotiable = value;
                    });
                  },
                ),
                TextFormField(
                  initialValue: _experience.toString(),
                  decoration: const InputDecoration(labelText: 'Experience (years)'),
                  onSaved: (value) => _experience = int.tryParse(value!) ?? 0,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter experience';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveForm,
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      
      final updatedData = {
        'label': _label,
        'category': _category,
        'state': _state,
        'description': _description,
        'fee': _fee,
        'is_fee_negotiable': _isFeeNegotiable,
        'experience': _experience,
      };

      final success = await serviceProvider.updateServiceData(widget.serviceId, updatedData);
      if (success) {
        Navigator.pop(context, true);
      } else {
        // Handle error, show a message
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to update service'),
        ));
      }
    }
  }
}
