import 'package:flutter/material.dart';
import 'package:home_info_client/resources/menu.dart';
import 'package:home_info_client/resources/palettes.dart';
import 'package:home_info_client/ui/meal_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            backgroundColor: BasicPalette.primaryColor,
            bottom: TabBar(
              indicatorColor: BasicPalette.accentColor,
              tabs: const [
                Tab(
                    icon: Icon(Icons.breakfast_dining_outlined,
                        color: Colors.white)),
                Tab(
                    icon: Icon(Icons.soup_kitchen_outlined,
                        color: Colors.white)),
                Tab(
                    icon: Icon(Icons.dinner_dining_outlined,
                        color: Colors.white)),
                Tab(
                    icon: Icon(Icons.restaurant_menu_outlined,
                        color: Colors.white)),
                Tab(
                    icon: Icon(Icons.coffee_outlined,
                        color: Colors.white)),
                Tab(
                    icon: Icon(Icons.grass_outlined,
                        color: Colors.white)),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              MealScreen('Завтрак', Menu.breakfast),
              MealScreen('Супы', Menu.soup),
              MealScreen('Основные блюда', Menu.dinner),
              MealScreen('Гарниры', Menu.garnish),
              MealScreen('Дессерты', Menu.dessert),
              MealScreen('Салаты и закуски', Menu.salad),
            ],
          )),
    );
  }
}
