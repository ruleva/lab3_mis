import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/favorites_service.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onTap;

  const MealCard({
    super.key,
    required this.meal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Image.network(
                    meal.thumbnail,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    meal.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 6,
              right: 6,
              child: _FavButton(mealId: meal.id),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavButton extends StatefulWidget {
  final String mealId;
  const _FavButton({required this.mealId});

  @override
  State<_FavButton> createState() => _FavButtonState();
}

class _FavButtonState extends State<_FavButton> {
  bool _fav = false;

  @override
  void initState() {
    super.initState();
    FavoritesService.isFavorite(widget.mealId).then((v) {
      if (mounted) setState(() => _fav = v);
    });
  }

  Future<void> _toggle() async {
    final nowFav = await FavoritesService.toggle(widget.mealId);
    if (mounted) setState(() => _fav = nowFav);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(nowFav ? 'Додадено во омилени' : 'Тргнато од омилени'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white70,
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(_fav ? Icons.favorite : Icons.favorite_border, color: Colors.red),
        onPressed: _toggle,
        tooltip: 'Омилено',
      ),
    );
  }
}
