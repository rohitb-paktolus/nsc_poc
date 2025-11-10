import 'package:dio/dio.dart';
import 'package:frequent_flow/change_password/models/change_password_request.dart';
import 'package:frequent_flow/change_password/models/change_password_response.dart';
import 'package:frequent_flow/utils/api_constants.dart';
import 'package:frequent_flow/utils/pref_key.dart';
import 'package:frequent_flow/utils/prefs.dart';

class ChangePasswordRepository {
  final _dio = Dio();

  ChangePasswordRepository();

  Future<ChangePasswordResponse?> changePassword(
      ChangePasswordRequest changePasswordRequest) async {
    print("Change Password request initiated");
    try {
      print(Prefs.getString(TOKEN));
      final response = await _dio.patch(
        '$BASE_URL$CHANGE_PASSWORD',
        data: changePasswordRequest.toJson(),
        options: Options(headers: {
          "Authorization": 'Bearer ${Prefs.getString(TOKEN)}',
          "Content-Type": "application/json",
        }),
      );

      var data = response.data;

      if (response.statusCode == 200) {
        final changePasswordResponse =
            ChangePasswordResponse.fromJson(data['data'] ?? data['details']);
        print(changePasswordResponse.toJson());
        return changePasswordResponse;
      }
    } on DioException catch (e) {
      print(e.response!.data);
      ChangePasswordResponse changePasswordResponse =
          ChangePasswordResponse.fromJson(e.response!.data['details']);
      print('Error ${changePasswordResponse.toJson()}');
      return changePasswordResponse;
    } catch (e) {
      print(e.toString());
      return null;
    }

    return null;
  }
}
