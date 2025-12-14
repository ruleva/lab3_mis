import 'package:flutter/material.dart';
import '../services/favorites_service.dart';
import '../services/meal_api_service.dart';
import '../models/meal_detail.dart';
import 'meal_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<MealDetail>> _future;

  Future<List<MealDetail>> _loadFavorites() async {
    final ids = await FavoritesService.load();
    final details = <MealDetail>[];

    for (final id in ids) {
      try {
        details.add(await MealApiService.getMealDetail(id));
      } catch (_) {}
    }
    return details;
  }

  @override
  void initState() {
    super.initState();
    _future = _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Омилени рецепти')),
      body: FutureBuilder<List<MealDetail>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('Немаш додадено омилени.'));
          }

          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final m = list[i];
              return ListTile(
                leading: Image.network(m.thumbnail, width: 56, fit: BoxFit.cover),
                title: Text(m.name),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MealDetailScreen(mealId: m.id)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
