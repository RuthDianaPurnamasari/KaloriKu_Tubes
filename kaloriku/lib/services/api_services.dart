import 'package:dio/dio.dart';
import 'package:kaloriku/model/food_model.dart';
import 'package:kaloriku/model/login_model.dart';
import 'package:flutter/material.dart';

class ApiServices {
  final Dio dio = Dio();
  final String _baseUrl = 'https://ws-kaloriku-4cf736febaf0.herokuapp.com';

  Future<Iterable<FoodsModel>?> getAllMenuItem() async {
    try {
      var response = await dio.get('$_baseUrl/menu');
      if (response.statusCode == 200) {
        final foodList = (response.data['data'] as List)
            .map((menu) => FoodsModel.fromJson(menu))
            .toList();
        return foodList;
      }
      return null;
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode != 200) {
        debugPrint('Client error - the request cannot be fulfilled');
        return null;
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<FoodResponse?> postFood(FoodInput ct) async {
    try {
      final response = await dio.post(
        '$_baseUrl/insert',
        data: ct.toJson(),
      );
      if (response.statusCode == 200) {
        return FoodResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<FoodsModel?> getSingleFood(String id) async {
    try {
      var response = await dio.get('$_baseUrl/menu/$id');

      if (response.statusCode == 200) {
        final data = response.data;
        return FoodsModel.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode != 200) {
        debugPrint('Client error - the request cannot be fulfilled');
        return null;
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<FoodResponse?> putMenu(String id, FoodInput ct) async {
    try {
      final response = await Dio().put(
        '$_baseUrl/update/$id',
        data: ct.toJson(),
      );
      if (response.statusCode == 200) {
        return FoodResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future deleteFood(String id) async {
    try {
      final response = await Dio().delete('$_baseUrl/delete/$id');
      if (response.statusCode == 200) {
        return FoodResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<LoginResponse?> login(LoginInput login) async {
  try {
    final response = await Dio().post(
      '$_baseUrl/login',
      data: login.toJson(),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(response.data);
    }
    return null;
  } on DioException catch (e) {
    if (e.response != null && e.response!.statusCode != 200) {
      debugPrint('Client error - the request cannot be fulfilled');
      return LoginResponse.fromJson(e.response!.data);
    }
    rethrow;
  } catch (e) {
    rethrow;
  }
}
}