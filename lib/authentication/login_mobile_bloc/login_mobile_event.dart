import 'package:equatable/equatable.dart';
import 'package:frequent_flow/authentication/models/mobile/login_mobile_details.dart';

import '../models/mobile/login_mobile_get_otp_request.dart';

sealed class LoginMobileEvent extends Equatable {
  const LoginMobileEvent();
}

final class LoginMobileUserOTP extends LoginMobileEvent {
  final LoginMobileGetOTPRequest loginMobileGetOTPRequest;

  const LoginMobileUserOTP({
    required this.loginMobileGetOTPRequest,
  });

  @override
  List<Object?> get props => [loginMobileGetOTPRequest];
}

final class LoginMobileUser extends LoginMobileEvent {
  final LoginMobileDetails loginMobileDetails;

  const LoginMobileUser({
    required this.loginMobileDetails,
  });

  @override
  List<Object?> get props => [loginMobileDetails];
}
