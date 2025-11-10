import 'package:equatable/equatable.dart';
import 'package:frequent_flow/authentication/models/mobile/login_mobile_get_otp_response.dart';

import '../models/mobile/login_mobile_response.dart';

sealed class LoginMobileState extends Equatable {
  const LoginMobileState();
}

final class LoginMobileOTPInitial extends LoginMobileState {
  @override
  List<Object> get props => [];
}

final class LoginMobileOTPLoading extends LoginMobileState {
  @override
  List<Object?> get props => [];
}

final class LoginMobileOTPSuccess extends LoginMobileState {
  final LoginMobileGetOTPResponse loginMobileGetOTPResponse;

  const LoginMobileOTPSuccess({required this.loginMobileGetOTPResponse});

  @override
  List<Object?> get props => [loginMobileGetOTPResponse];
}

final class LoginMobileOTPError extends LoginMobileState {
  final String error;

  const LoginMobileOTPError({required this.error});

  @override
  List<Object?> get props => [error];
}

final class LoginMobileInitial extends LoginMobileState {
  @override
  List<Object> get props => [];
}

final class LoginMobileLoading extends LoginMobileState {
  @override
  List<Object?> get props => [];
}

final class LoginMobileSuccess extends LoginMobileState {
  final LoginMobileResponse loginMobileResponse;

  const LoginMobileSuccess({required this.loginMobileResponse});

  @override
  List<Object?> get props => [loginMobileResponse];
}

final class LoginMobileError extends LoginMobileState {
  final String error;

  const LoginMobileError({required this.error});

  @override
  List<Object?> get props => [error];
}
