import 'package:dio/dio.dart';
import '../../utils/api_constants.dart';
import '../models/mobile/login_mobile_get_otp_request.dart';
import '../models/mobile/login_mobile_get_otp_response.dart';

class LoginMobileRepository{

  final _dio = Dio();

  LoginMobileRepository();

  Future<LoginMobileGetOTPResponse> getMobileOTP(
      LoginMobileGetOTPRequest loginMobileGetOTPRequest) async {
    try {
      final response = await _dio.post(
        '$BASE_URL$MOBILE_OTP',
        data: loginMobileGetOTPRequest.toJson(),
        options: Options(headers: {
          "Content-Type": "application/json",
        }),
      );
      final data = response.data;
      print("Success $data");
      print("Success ${response.data['data']}");

      if (response.statusCode == 200) {
        LoginMobileGetOTPResponse loginMobileOTP =
        LoginMobileGetOTPResponse.fromJson(data);
        print(loginMobileOTP.details?.message);
        return loginMobileOTP;
      }
    } on DioException catch (error) {
      print(error.response?.data);
      LoginMobileGetOTPResponse loginMobileOTP =
      LoginMobileGetOTPResponse.fromJson(error.response?.data);
      return loginMobileOTP;
    }
    LoginMobileGetOTPResponse loginMobileOTP = LoginMobileGetOTPResponse(
      error: "Unknown error occurred.",
    );
    return loginMobileOTP;
  }
}

