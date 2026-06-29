import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:amazing/services/favorites_service.dart';

import 'package:amazing/screens/full_screen.dart';
import 'package:amazing/screens/favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = "🌿 Nature";
  String selectedQuery = "nature";
  String selectedKeyword = "nature";
  Map<String, List<String>> categories = {
    "🌿 Nature": [
      "nature",
      "mountains",
      "forest",
      "beach",
      "ocean",
      "sunset",
      "river",
      "waterfall",
      "sky",
      "clouds",
    ],

    "🚗 Transport": [
      "cars",
      "bike",
      "motorcycle",
      "train",
      "airplane",
      "road",
      "traffic",
    ],

    "🎮 Anime": [
      "anime",
      "naruto",
      "dragon ball",
      "manga",
      "gaming",
      "esports",
      "cartoon",
    ],

    "🍔 Food": ["food", "pizza", "burger", "sushi", "coffee", "dessert"],

    "💻 Tech": [
      "technology",
      "computer",
      "laptop",
      "smartphone",
      "AI",
      "coding",
    ],
  };

  List images = [];
  List<Map<String, dynamic>> favorites = [];

  TextEditingController searchController = TextEditingController();
  int page = 1;
  bool isLoading = false;
  bool initialLoading = true;

  @override
  void initState() {
    super.initState();

    loadFavorites();
    fetchApi();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchApi() async {
    setState(() {
      isLoading = true;
    });

    const String apiKey =
        "API_KEY";

    try {
      final response = await http.get(
        Uri.parse(
          "https://api.pexels.com/v1/search?query=$selectedQuery&per_page=80&page=$page",
        ),
        headers: {"Authorization": apiKey},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(response.body);

        setState(() {
          images.addAll(result['photos']);
          isLoading = false;
          initialLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        initialLoading = false;
      });
    }
  }

  Future<void> loadFavorites() async {
    favorites = await FavoritesService.loadFavorites();

    setState(() {});
  }

  bool isFavorite(int id) {
    return favorites.any((wallpaper) => wallpaper["id"] == id);
  }

  void loadMore() {
    setState(() {
      page++;
      isLoading = true;
    });
    fetchApi();
  }

  Future<void> toggleFavorite(Map<String, dynamic> image) async {
    int imageId = image["id"];

    if (isFavorite(imageId)) {
      favorites.removeWhere((wallpaper) => wallpaper["id"] == imageId);
    } else {
      favorites.add({
        "id": image["id"],
        "tiny": image["src"]["tiny"],
        "large2x": image["src"]["large2x"],
      });
    }

    await FavoritesService.saveFavorites(favorites);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "AMAZING WALLPAPERS",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        elevation: 10,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),

            onPressed: () {
              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (context) => FavoritesScreen(favorites: favorites),
                ),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          //Search Bar
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search Wallpapers",
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      selectedQuery = selectedKeyword;
                      page = 1;
                      images.clear();
                    });

                    fetchApi();
                  },
                ),

                filled: true,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),

              onSubmitted: (value) {
                if (value.trim().isEmpty) return;

                setState(() {
                  selectedQuery = value;
                  page = 1;
                  images.clear();
                  isLoading = true;
                });

                fetchApi();
              },
            ),
          ),

          //Category Bar
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.keys.length,
              itemBuilder: (context, index) {
                String categoryName = categories.keys.elementAt(index);

                bool isSelected = categoryName == selectedCategory;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = categoryName;
                      selectedKeyword = categories[categoryName]!.first;

                      selectedQuery = selectedKeyword;
                      page = 1;
                      images.clear();
                      isLoading = true;
                    });
                    fetchApi();
                  },

                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.deepPurpleAccent
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),

                    alignment: Alignment.center,

                    child: Text(
                      categoryName,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          //Keywords
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories[selectedCategory]!.length,
              itemBuilder: (context, index) {
                String keyword = categories[selectedCategory]![index];

                bool isSelected = keyword == selectedKeyword;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedKeyword = keyword;
                      selectedQuery = keyword;

                      page = 1;
                      images.clear();
                      isLoading = true;
                    });

                    fetchApi();
                  },

                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 8),

                    padding: EdgeInsets.symmetric(horizontal: 14),

                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.deepPurpleAccent
                          : Colors.grey.shade300,

                      borderRadius: BorderRadius.circular(20),
                    ),

                    alignment: Alignment.center,

                    child: Text(
                      keyword,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          //Wallpapers View
          Expanded(
            child: initialLoading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text(
                        "Fetching Wallpapers...",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          padding: EdgeInsets.all(8),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 5,
                                mainAxisSpacing: 5,
                                childAspectRatio: 2 / 3,
                              ),
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreen(
                                    imageurl: images[index]['src']['large2x'],
                                  ),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.network(
                                        images[index]['src']['tiny'],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                                  Positioned(
                                    top: 5,
                                    right: 5,

                                    child: GestureDetector(
                                      onTap: () =>
                                          toggleFavorite(images[index]),

                                      child: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.black54,

                                        child: Icon(
                                          isFavorite(images[index]["id"])
                                              ? Icons.favorite
                                              : Icons.favorite_border,

                                          color: Colors.red,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      InkWell(
                        onTap: isLoading ? null : loadMore,
                        child: Container(
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.deepPurpleAccent,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Center(
                            child: isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    "Load More",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
