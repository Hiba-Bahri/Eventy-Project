import 'package:carousel_slider/carousel_slider.dart';
import 'package:eventy/core/services/firebase_service_services.dart';
import 'package:eventy/features/home/widgets/bordered_image.dart';
import 'package:eventy/features/home/widgets/category_card.dart';
import 'package:eventy/features/home/widgets/service_card.dart';
import 'package:flutter/material.dart';
import 'package:eventy/data/models/Service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  final FirebaseServiceServices _Services = FirebaseServiceServices();

  Future<List<Service>>? services;

  @override
  void initState() {
    super.initState();
    services = _Services.getAllServices();
  }

  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.festival_rounded, 'title': 'Decorator'},
    {'icon': Icons.music_note_rounded, 'title': 'Music'},
    {'icon': Icons.emoji_food_beverage_rounded, 'title': 'Catering'},
    {'icon': Icons.desk_rounded, 'title': 'Workspace'},
  ];



  FutureBuilder<List<Service>> futureBuilderServices() {
    return FutureBuilder<List<Service>>(
      future: _Services.getAllServices(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final services = snapshot.data!;
        return GridView.builder(
          itemCount: services.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemBuilder: (context, index) => ServiceCard(
            title: services[index].label,
            description: services[index].description,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
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
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Furniture',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.tune, color: Colors.green),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),
          CarouselSlider(
            options: CarouselOptions(
              height: 270.0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
            ),
            items: [
              BorderedImage(imagePath: 'assets/images/birthday.jpg'),
              BorderedImage(imagePath: 'assets/images/concert.jpg'),
              BorderedImage(imagePath: 'assets/images/conference.jpg'),
              BorderedImage(imagePath: 'assets/images/wedding.jpg'),
              BorderedImage(imagePath: 'assets/images/hike.jpg'),
              BorderedImage(imagePath: 'assets/images/festival.jpg'),
            ],
          ),
          const SizedBox(height: 16.0),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Category',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CategoryCard(icon: Icons.festival_rounded, title: 'Decorator'),
                CategoryCard(icon: Icons.music_note_rounded, title: 'Music'),
                CategoryCard(icon: Icons.emoji_food_beverage_rounded, title: 'Catering'),
                CategoryCard(icon: Icons.desk_rounded, title: 'Workspace'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
