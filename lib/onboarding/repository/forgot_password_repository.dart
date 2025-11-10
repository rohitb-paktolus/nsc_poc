import 'package:dio/dio.dart';
import 'package:frequent_flow/onboarding/models/forgot_password/forgot_password_get_otp_request.dart';
import 'package:frequent_flow/onboarding/models/forgot_password/forgot_password_get_otp_response.dart';
import 'package:frequent_flow/onboarding/models/forgot_password/set_new_password_response.dart';
import 'package:frequent_flow/onboarding/models/forgot_password/verify_otp_response.dart';
import 'package:frequent_flow/utils/api_constants.dart';

import '../models/forgot_password/set_new_password_request.dart';
import '../models/forgot_password/verify_otp_request.dart';

class ForgotPasswordRepository {
  final Dio _dio = Dio();

  ForgotPasswordRepository();

  Future<ForgotPasswordGetOTPResponse?> getOTP(
      ForgotPasswordGetOTPRequest forgotPasswordGetOTPRequest) async {
    try {
      final response = await _dio.post(
        '$BASE_URL$FORGOT_PASSWORD_OTP',
        data: forgotPasswordGetOTPRequest.toJson(),
        options: Options(headers: {
          "Content-Type": "application/json",
        }),
      );
      final data = response.data;
      print("Success $data");
      print("Success ${response.data['data']}");

      if (response.statusCode == 200) {
        ForgotPasswordGetOTPResponse forgotPasswordGetOTPResponse =
            ForgotPasswordGetOTPResponse.fromJson(data);
        print(forgotPasswordGetOTPResponse.data?.message);
        return forgotPasswordGetOTPResponse;
      }
    } on DioException catch (error) {
      print(error.response?.data);
      ForgotPasswordGetOTPResponse forgotPasswordGetOTPResponse =
          ForgotPasswordGetOTPResponse.fromJson(error.response?.data);
      return forgotPasswordGetOTPResponse;
    }

    return null;
  }

  Future<VerifyOTPResponse?> verifyOTP(
      VerifyOTPRequest verifyOTPRequest) async {
    try {
      final response = await _dio.post(
        '$BASE_URL$VERIFY_OTP',
        data: verifyOTPRequest.toJson(),
        options: Options(headers: {
          "Content-Type": "application/json",
        }),
      );
      final data = response.data;
      print("Success $data");
      print("Success ${response.data['data']}");

      if (response.statusCode == 200) {
        VerifyOTPResponse verifyOTPResponse = VerifyOTPResponse.fromJson(data);
        print(verifyOTPResponse.data?.statusCode);
        return verifyOTPResponse;
      }
    } on DioException catch (error) {
      print(error.response?.data);
      VerifyOTPResponse verifyOTPResponse =
          VerifyOTPResponse.fromJson(error.response?.data);
      return verifyOTPResponse;
    }

    return null;
  }

  Future<SetNewPasswordResponse?> setNewPassword(
      SetNewPasswordRequest setNewPasswordRequest) async {
    try {
      final response = await _dio.patch(
        '$BASE_URL$SET_NEW_PASSWORD',
        data: setNewPasswordRequest.toJson(),
        options: Options(headers: {
          "Content-Type": "application/json",
        }),
      );
      final data = response.data;
      print("Success $data");
      print("Success ${response.data['data']}");

      if (response.statusCode == 200) {
        SetNewPasswordResponse setNewPasswordResponse =
            SetNewPasswordResponse.fromJson(data);
        print(setNewPasswordResponse.data?.statusCode);
        return setNewPasswordResponse;
      }
    } on DioException catch (error) {
      print(error.response?.data);
      SetNewPasswordResponse setNewPasswordResponse =
          SetNewPasswordResponse.fromJson(error.response?.data);
      return setNewPasswordResponse;
    }

    return null;
  }
}
