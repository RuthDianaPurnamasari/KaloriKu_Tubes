//DIGUNAKAN UNTUK GET ALL DATA
import 'package:flutter/material.dart';

class FoodsModel {
  final String id;
  final String name;
  final String ingredients;
  final String description;
  final double calories; // Ubah dari double ke String
  final String category;

  FoodsModel({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.description,
    required this.calories,
    required this.category,
  });

 factory FoodsModel.fromJson(Map<String, dynamic> json) {
  debugPrint('📡 Parsing JSON: $json'); //  Tambahkan ini untuk debug
  return FoodsModel(
    id: json['_id'] is Map ? json['_id']['\$oid'] ?? '' : json['_id'] ?? '',
    name: json['name'] ?? '',
    ingredients: json['ingredients'] ?? '',
    description: json['description'] ?? '',
    calories: _parseCalories(json['calories']), // Gunakan fungsi helper
    category: json['category'] ?? '',
  );
}

// Fungsi helper untuk konversi calories
static double _parseCalories(dynamic value) {
  if (value is int) {
    return value.toDouble(); // 🔥 Ubah int ke double
  } else if (value is String) {
    return double.tryParse(value) ?? 0.0; // 🔥 Ubah String ke double
  } else if (value is double) {
    return value;
  }
  return 0.0; // Default jika null atau tipe lain
}


  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "ingredients": ingredients,
        "description": description,
        "calories": calories,
        "category": category,
      };
      // Getter untuk format "gram kcal"
  String get formattedCalories => '${calories.toStringAsFixed(1)} kcal';
}

//DIGUNAKAN UNTUK FORM INPUT
class FoodInput {
  final String name;
  final String ingredients;
  final String description;
  final double calories;
  final String category;

  FoodInput({
    required this.name,
    required this.ingredients,
    required this.description,
    required this.calories,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "ingredients": ingredients,
        "description": description,
        "calories": calories,
        "category": category,
      };
}

//DIGUNAKAN UNTUK RESPONSE
class FoodResponse {
  final String? insertedId;
  final String message;
  final int status;

  FoodResponse({
    this.insertedId,
    required this.message,
    required this.status,
  });

  factory FoodResponse.fromJson(Map<String, dynamic> json) =>
      FoodResponse(
        insertedId: json["inserted_id"],
        message: json["message"],
        status: json["status"],
      );
}