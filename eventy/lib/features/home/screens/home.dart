import 'package:carousel_slider/carousel_slider.dart';
import 'package:eventy/core/providers/service_provider.dart';
import 'package:eventy/features/home/widgets/bordered_image.dart';
import 'package:eventy/features/home/widgets/category_card.dart';
import 'package:eventy/features/home/widgets/search.dart';
import 'package:eventy/features/home/widgets/service_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  @override
  void initState() {
    super.initState();
    Provider.of<ServiceProvider>(context, listen: false).getServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            search_section(),
            const SizedBox(height: 20.0),
            CarouselSlider(
              options: CarouselOptions(
                height: 270.0,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
              ),
              items: const [
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CategoryCard(icon: Icons.festival_rounded, title: 'Decorator'),
                  CategoryCard(icon: Icons.music_note_rounded, title: 'Music'),
                  CategoryCard(
                      icon: Icons.emoji_food_beverage_rounded, title: 'Catering'),
                  CategoryCard(icon: Icons.desk_rounded, title: 'Workspace'),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            const ServiceCardGrid(),
          ],
        ),
      ),
    );
  }
}
