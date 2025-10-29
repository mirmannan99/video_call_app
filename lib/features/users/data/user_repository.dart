import 'package:dio/dio.dart';

import '../../../core/controller/api_res_controller.dart';
import 'user_res_model.dart';

class UserRepository {
  UserRepository._();
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://reqres.in/api/',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-api-key': 'reqres-free-v1',
      },
    ),
  );

  static Future<ApiResponse<UserResModel>> fetchUsers({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final res = await _dio.get('users?page=$page&per_page=$perPage');
      if (res.statusCode == 200) {
        return ApiResponse(data: UserResModel.fromJson(res.data));
      }
      return ApiResponse(
        error: true,
        errorMessage: 'Failed to fetch users',
        responseCode: res.statusCode,
      );
    } catch (e) {
      return ApiResponse(error: true, errorMessage: e.toString());
    }
  }
}
