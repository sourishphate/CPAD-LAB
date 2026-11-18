import 'package:flutter/material.dart';

class EmojiStack extends StatelessWidget {
  const EmojiStack({super.key, required this.food});
  final Map<String, dynamic> food;
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 75,
          height: 75,
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(food["emoji"], style: const TextStyle(fontSize: 40)),
          ),
        ),
        Positioned(
          top: 4,
          left: 4,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: food["type"] == "Veg" ? Colors.green : Colors.red,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.circle,
                size: 6,
                color: food["type"] == "Veg" ? Colors.green : Colors.red,
              ),
            ),
          ),
        ),
        if (food["bestseller"] == true)
          Positioned(
            bottom: -8,
            right: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Text(
                "🔥 Best",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
