import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frequent_flow/authentication/login_mobile_bloc/login_mobile_bloc.dart';
import 'package:frequent_flow/authentication/login_mobile_bloc/login_mobile_state.dart';
import 'package:frequent_flow/authentication/models/mobile/login_mobile_details.dart';
import 'package:frequent_flow/authentication/models/mobile/login_mobile_get_otp_request.dart';

import '../../utils/pref_key.dart';
import '../../utils/prefs.dart';
import '../../utils/route.dart';
import '../../utils/validation.dart';
import '../../widgets/custom_text.dart';
import '../login_mobile_bloc/login_mobile_event.dart';

class LoginMobileScreen extends StatefulWidget {
  const LoginMobileScreen({super.key});

  @override
  State<LoginMobileScreen> createState() => _LoginMobileScreenState();
}

class _LoginMobileScreenState extends State<LoginMobileScreen> {
  final _formMobileKey = GlobalKey<FormState>();
  TextEditingController mobileController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  String mobileErrorText = '';
  String otpErrorText = '';
  bool isButtonEnabled = false;
  bool isOtpVisible = false;
  bool clickLogin = false;
  Color buttonColor = const Color(0xFF88c2f7);

  GlobalKey<State> loadingDialogKey = GlobalKey();

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          surfaceTintColor: Colors.white,
          shadowColor: Colors.white,
          key: loadingDialogKey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
          child: Container(
            height: 180,
            padding: const EdgeInsets.all(16),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                    strokeWidth: 10.0,
                    color: Color(0xFF2986CC),
                    strokeCap: StrokeCap.round),
                SizedBox(height: 24),
                Text(
                  'Please Wait...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF171717),
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.40,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void hideLoadingDialog() {
    if (loadingDialogKey.currentContext != null) {
      Navigator.of(loadingDialogKey.currentContext!, rootNavigator: true).pop();
    }
  }

  void _updateButtonColor() {
    setState(() {
      bool isMobileValid =
          Validator.mobileNumberValidate(mobileController.text);
      bool isOTPValid = Validator.emptyFieldValidate(otpController.text);
      isButtonEnabled = isMobileValid && isOTPValid;
      buttonColor =
          isButtonEnabled ? const Color(0xFFF85A5A) : const Color(0xFFFDBABA);
    });
  }

  void _onButtonPressed() async {
    showLoadingDialog(context);
    if (isOtpVisible) {
      //API call To Verify OTP
      setState(() {
        clickLogin = true;
      });
      FocusScope.of(context).requestFocus(FocusNode());
      Navigator.pushReplacementNamed(context, ROUT_DASHBOARD);
      LoginMobileDetails loginMobileDetails = LoginMobileDetails(
        phoneNumber: mobileController.text,
        otp: otpController.text,
      );
      BlocProvider.of<LoginMobileBloc>(context)
          .add(LoginMobileUser(loginMobileDetails: loginMobileDetails));
    } else {
      // API to get OTP
      LoginMobileGetOTPRequest loginMobileGetOTPRequest =
          LoginMobileGetOTPRequest(phoneNumber: mobileController.text);
      BlocProvider.of<LoginMobileBloc>(context).add(LoginMobileUserOTP(
          loginMobileGetOTPRequest: loginMobileGetOTPRequest));
    }
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Error',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    String savedEmail = Prefs.getString(SAVED_MOBILE);
    if (savedEmail.isNotEmpty) {
      mobileController.text = Prefs.getString(SAVED_MOBILE);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginMobileBloc, LoginMobileState>(
      listener: (context, state) {
        hideLoadingDialog();
        if (state is LoginMobileSuccess) {
          print("LoginSuccess");
          hideLoadingDialog();
          clickLogin = false;
          print(state.loginMobileResponse.toJson());
          Prefs.setBool(LOGIN_FLAG, true);
          // Navigate to Dashboard
          Navigator.of(context).pushNamedAndRemoveUntil(
            ROUT_DASHBOARD,
            (route) => false,
          );
        } else if (state is LoginMobileError) {
          clickLogin = false;
          print("login error");
          _showErrorDialog(context, state.error);
        }
      },
      child: BlocListener<LoginMobileBloc, LoginMobileState>(
        listener: (context, state) {
          hideLoadingDialog();
          if (state is LoginMobileOTPSuccess) {
            print("Login Mobile OTP Success");
            setState(() {
              isOtpVisible = true;
            });
          } else {
            setState(() {
              isOtpVisible = false;
            });
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFFFFFFF),
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Form(
                    key: _formMobileKey,
                    child: Container(
                        width: double.infinity,
                        height: null,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(19),
                          color: const Color(0xFFFFFFFF),
                        ),
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 48),
                              child: CustomText(
                                  text: 'Login',
                                  fontSize: 24,
                                  desiredLineHeight: 29.05,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF262626)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0,
                                  right: 16.0,
                                  top: 32.0,
                                  bottom: 32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xFFE5E5E5),
                                          width: 1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: TextFormField(
                                        controller: mobileController,
                                        onChanged: (value) {
                                          setState(() {
                                            mobileErrorText = Validator
                                                    .mobileNumberValidate(value)
                                                ? ''
                                                : 'Please enter a valid Mobile Number';
                                          });
                                          _updateButtonColor();
                                        },
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          color: Color(0xFF171717),
                                          fontWeight: FontWeight.w400,
                                          height: 1.25,
                                          fontSize: 16,
                                        ),
                                        decoration: const InputDecoration(
                                          labelText: 'Mobile Number',
                                          labelStyle: TextStyle(
                                            color: Color(0xFF737373),
                                          ),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: mobileErrorText.isNotEmpty,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, top: 12.0),
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: SvgPicture.asset(
                                                'assets/icon/error_icon.svg',
                                                height: 12.67,
                                                width: 12.67,
                                                alignment: Alignment.center,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            Expanded(
                                              child: CustomText(
                                                text: mobileErrorText,
                                                fontSize: 12,
                                                desiredLineHeight: 16,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFFF85A5A),
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Visibility(
                                    visible: isOtpVisible,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: const Color(0xFFE5E5E5),
                                            width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 46),
                                        child: TextFormField(
                                          controller: otpController,
                                          onChanged: (value) {
                                            setState(() {
                                              otpErrorText =
                                                  Validator.emptyFieldValidate(
                                                          value)
                                                      ? ''
                                                      : '';
                                            });
                                            _updateButtonColor();
                                          },
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            color: Color(0xFF171717),
                                            fontWeight: FontWeight.w400,
                                            height: 1.25,
                                            fontSize: 16,
                                          ),
                                          decoration: const InputDecoration(
                                            labelText: 'OTP',
                                            labelStyle: TextStyle(
                                              color: Color(0xFF737373),
                                            ),
                                            border: InputBorder.none,
                                          ),
                                          keyboardType:
                                              TextInputType.visiblePassword,
                                          textInputAction: TextInputAction.done,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: otpErrorText.isNotEmpty,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, top: 12.0),
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: SvgPicture.asset(
                                                'assets/icon/error_icon.svg',
                                                height: 12.67,
                                                width: 12.67,
                                                alignment: Alignment.center,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            Expanded(
                                              child: CustomText(
                                                text: otpErrorText,
                                                fontSize: 12,
                                                desiredLineHeight: 16,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFFF85A5A),
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 32,
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: buttonColor,
                                    ),
                                    child: TextButton(
                                      onPressed: isButtonEnabled
                                          ? _onButtonPressed
                                          : null,
                                      child: const CustomText(
                                          text: 'Verify',
                                          fontSize: 16,
                                          desiredLineHeight: 24,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFFFFFFF)),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            text: 'New User? ',
                            style: const TextStyle(
                              color: Color(0xFF737373),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 16.94 / 14.0,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Register here',
                                style: const TextStyle(
                                    color: Color(0xFF737373),
                                    fontSize: 13,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    height: 16.94 / 13.0),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    Navigator.pushNamed(
                                        context, ROUT_REGISTRATION);
                                  },
                              ),
                            ]),
                      ),
                    ),
                  ),
                ],
              ),
              Center(
                child: Visibility(
                  visible: clickLogin,
                  child: const CircularProgressIndicator(
                    color: Color(0XFFF85A5A),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
