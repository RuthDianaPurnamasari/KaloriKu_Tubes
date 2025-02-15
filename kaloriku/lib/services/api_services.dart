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

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response data: ${response.data}');
      debugPrint('📥 Data dari API: ${response.data}');


      if (response.statusCode == 200) {
        final foodList = (response.data['data'] as List)
            .map((menu) => FoodsModel.fromJson(menu))
            .toList();

        debugPrint('✅ Berhasil parsing data: ${foodList.length} item');
        return foodList;
      }
      return null;
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint('🚨 Dio error: ${e.response!.statusCode} - ${e.response!.data}');
      } else {
        debugPrint('🚨 Request error: ${e.message}');
      }
      return null;
    } catch (e) {
      debugPrint('🚨 Unexpected error: $e');
      return null;
    }
  }


  Future<FoodResponse?> postFood(FoodInput ct) async {
    try {
      final response = await dio.post(
        '$_baseUrl/insertMenu',
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
        '$_baseUrl/updateMenu/$id',
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
      final response = await Dio().delete('$_baseUrl/deleteMenu/$id');
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
    final String url = '$_baseUrl/login';
    
    debugPrint('🔍 Request ke: $url');

    final response = await dio.post(
      url,
      data: login.toJson(),
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    debugPrint('✅ Response: ${response.data}');

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(response.data);
    }
    return null;
  } on DioException catch (e) {
    if (e.response != null) {
      debugPrint('🚨 Login error: ${e.response!.statusCode} - ${e.response!.data}');

      if (e.response!.statusCode == 404) {
        debugPrint('⚠️ Endpoint /login tidak ditemukan! Cek API backend.');
      } else if (e.response!.statusCode == 401) {
        debugPrint('⚠️ Unauthorized! Pastikan username & password benar.');
      }

      return null;
    } else {
      debugPrint('🚨 Request error: ${e.message}');
      return null;
    }
  } catch (e) {
    debugPrint('🚨 Unexpected error: $e');
    return null;
  }
}

}