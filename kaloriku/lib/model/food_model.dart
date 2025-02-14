//DIGUNAKAN UNTUK GET ALL DATA
class FoodsModel {
  final String id;
  final String name;
  final String ingredients;
  final String description;
  final double calories;
  final String category;

  FoodsModel({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.description,
    required this.calories,
    required this.category,
  });

  factory FoodsModel.fromJson(Map<String, dynamic> json) => FoodsModel(
        id: json["_id"],
        name: json["name"],
        ingredients: json["ingredients"],
        description: json["description"],
        calories: json["calories"],
        category: json["category"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "ingredients": ingredients,
        "description": description,
        "calories": calories,
        "category": category,
      };
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