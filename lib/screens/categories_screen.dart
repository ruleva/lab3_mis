import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/meal_api_service.dart';
import '../widgets/category_card.dart';
import 'favorites_screen.dart';
import 'meal_detail_screen.dart';
import 'meals_by_category_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Future<List<Category>> _futureCategories;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _futureCategories = MealApiService.getCategories();
  }

  Future<void> _openRandomMeal() async {
    try {
      final randomMeal = await MealApiService.getRandomMeal();
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MealDetailScreen(mealId: randomMeal.id),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не успеа random рецепт.')),
      );
    }
  }

  void _openFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Категории'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Омилени',
            onPressed: _openFavorites,
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Random рецепт',
            onPressed: _openRandomMeal,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Пребарај категорија...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _search = value.toLowerCase().trim()),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Category>>(
              future: _futureCategories,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Грешка: ${snapshot.error}'));
                }

                final categories = snapshot.data ?? [];
                final filtered = categories
                    .where((c) => c.name.toLowerCase().contains(_search))
                    .toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('Нема резултати.'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final category = filtered[index];
                    return CategoryCard(
                      category: category,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MealsByCategoryScreen(
                              categoryName: category.name,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
