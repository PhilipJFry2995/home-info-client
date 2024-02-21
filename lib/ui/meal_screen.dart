import 'package:flutter/material.dart';
import 'package:home_info_client/resources/palettes.dart';

class MealScreen extends StatelessWidget {
  final String title;
  final List<String> meals;

  const MealScreen(this.title, this.meals, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (BuildContext context, int index) => Padding(
        padding: const EdgeInsets.all(4.0),
        child: Divider(
          color: Theme.of(context).primaryColor,
          thickness: 2.0,
        ),
      ),
      itemCount: meals.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                    color: BasicPalette.accentColor,
                  ),
                ),
              ),
            ],
          );
        }
        index -= 1;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            meals[index],
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: BasicPalette.accentColor,
            ),
          ),
        );
      },
    );
  }
}
