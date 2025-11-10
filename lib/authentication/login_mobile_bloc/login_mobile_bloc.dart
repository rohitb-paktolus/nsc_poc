import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/login_mobile_repository.dart';
import 'login_mobile_event.dart';
import 'login_mobile_state.dart';

class LoginMobileBloc extends Bloc<LoginMobileEvent, LoginMobileState> {
  LoginMobileRepository loginMobileRepository;

  LoginMobileBloc({required this.loginMobileRepository})
      : super(LoginMobileInitial()) {
    on<LoginMobileUserOTP>((event, emit) async {
      try {
        final loginOTPResponse = await loginMobileRepository
            .getMobileOTP(event.loginMobileGetOTPRequest);
        emit(
            LoginMobileOTPSuccess(loginMobileGetOTPResponse: loginOTPResponse));
      } catch (e) {
        emit(LoginMobileOTPError(error: e.toString()));
      }
    });
  }
}
