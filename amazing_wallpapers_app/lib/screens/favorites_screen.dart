import 'package:flutter/material.dart';


class FavoritesScreen extends StatelessWidget {

  final List<Map<String, dynamic>> favorites;

  const FavoritesScreen({
    super.key,
    required this.favorites,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Favorite Wallpapers",
        ),
      ),

      body: favorites.isEmpty

          ? const Center(
              child: Text(
                "No Favorites Yet ❤️",
              ),
            )

          : GridView.builder(

              padding: const EdgeInsets.all(8),

              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(

                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 2 / 3,
              ),

              itemCount: favorites.length,

              itemBuilder: (context, index) {

                return ClipRRect(

                  borderRadius:
                      BorderRadius.circular(15),

                  child: Image.network(

                    favorites[index]["tiny"],

                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
    );
  }
}