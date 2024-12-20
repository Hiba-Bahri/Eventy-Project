import 'package:eventy/core/providers/service_provider.dart';
import 'package:eventy/features/home/widgets/filter.dart';
import 'package:eventy/features/home/widgets/service_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool filtersApplied = false;
  int i = 1;

  @override
  void initState() {
    super.initState();

    final serviceProvider =
        Provider.of<ServiceProvider>(context, listen: false);
    if (serviceProvider.services.isEmpty) {
      serviceProvider.getServices();
    }
  }

  void _onSearchChanged(String query) {
    if (query == "") {
      _clearFilters();
      return;
    }
    print(++i);
    filtersApplied = true;
    Provider.of<ServiceProvider>(context, listen: false).filterServices(query);
  }

  void _clearFilters() {
    filtersApplied = false;
    _searchController.clear();
    Provider.of<ServiceProvider>(context, listen: false).resetFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Services'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'Enter the name of service ',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.tune, color: Colors.green),
                  onPressed: () async {
                    final filterData = await showDialog(
                      context: context,
                      builder: (context) => FilterDialog(),
                    );

                    if (filterData != null) {
                      print("--------------$filterData");
                      Provider.of<ServiceProvider>(context, listen: false)
                          .filterServicesByFilters(
                              filterData['label'],
                              filterData['state'],
                              filterData['category'],
                              filterData['isNegotiable'],
                              filterData['priceRange'],
                              filterData['experience']);
                      filtersApplied = filterData['filtersApplied'];
                    }
                  },
                ),
              ],
            ),
          ),

          // "Remove Filters" Button
          Consumer<ServiceProvider>(
            builder: (context, serviceProvider, _) {
              if (filtersApplied) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _clearFilters,
                    child: const Text("Remove Filters"),
                  ),
                );
              }
              return const SizedBox
                  .shrink();
            },
          ),

          // Filtered Services
          Expanded(
            child: Consumer<ServiceProvider>(
              builder: (context, serviceProvider, _) {
                if (serviceProvider.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (serviceProvider.filteredServices.isEmpty) {
                  return const Center(
                    child: Text(
                      "No matching services found.",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ServiceCardGrid(
                  services: serviceProvider.filteredServices,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
