import 'package:flutter/material.dart';
import 'package:kaloriku/model/food_model.dart';

class FoodCard extends StatelessWidget {
  final FoodsModel food;
  final Function() onDismissed;

  const FoodCard({Key? key, required this.food, required this.onDismissed, required FoodResponse response}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(food.id),
      onDismissed: (direction){
        onDismissed();
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.lightBlue[200],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // if (food.insertedId != null) _buildDataRow('ID', food.insertedId),
              _buildDataRow('Nama', food.name),
              _buildDataRow('Bahan', food.ingredients),
              _buildDataRow('Deskripsi', food.description),
              _buildDataRow('Kalori', '${food.calories} kcal'),
              _buildDataRow('Kategori', food.category),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, dynamic value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10), // Jarak antara label dan titik dua
        Expanded(
          child: Text(
            ': $value',
            softWrap: true,
          ),
        ),
      ],
    );
  }
}