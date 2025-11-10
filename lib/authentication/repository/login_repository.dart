import 'package:dio/dio.dart';
import 'package:frequent_flow/authentication/models/email/login_details.dart';
import 'package:frequent_flow/utils/api_constants.dart';

import '../models/email/login_response.dart';

class LoginRepository {
  final _dio = Dio();

  LoginRepository();

  Future<LoginResponse?> loginUser(LoginDetails loginDetails) async {
    print(loginDetails.toJson());
    try {
      final response = await _dio.post(
        '$BASE_URL$LOGIN',
        data: loginDetails.toJson(),
        options: Options(headers: {
          "Content-Type": "application/json",
        }),
      );

      var data = response.data;

      if (response.statusCode == 200) { // Need to check this
        final loginResponse = LoginResponse.fromJson(data);
        print("LoginResponse");
        print(loginResponse.toJson());
        return loginResponse;
      }
    } on DioException catch (e) {
      LoginResponse loginResponse = LoginResponse.fromJson(e.response!.data);
      return loginResponse;
    }

    return null;
  }
}
