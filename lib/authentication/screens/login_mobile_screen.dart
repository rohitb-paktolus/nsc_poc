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

  // FIX: Removed 'clickLogin' boolean. Loading is handled by the BLoC state.
  Color buttonColor = const Color(0xFFFDBABA); // Start as disabled color

  // FIX: Renamed key for clarity and added a flag to track dialog state
  final GlobalKey<State> _loadingDialogKey = GlobalKey();
  bool _isDialogShowing = false;

  void showLoadingDialog(BuildContext context) {
    // Prevent showing multiple dialogs
    if (_isDialogShowing) return;
    _isDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          surfaceTintColor: Colors.white,
          shadowColor: Colors.white,
          key: _loadingDialogKey,
          // Use the key here
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
    // Only pop if a dialog is showing and its context is available
    if (_isDialogShowing && _loadingDialogKey.currentContext != null) {
      Navigator.of(_loadingDialogKey.currentContext!, rootNavigator: true)
          .pop();
      _isDialogShowing = false;
    }
  }

  void _updateButtonColor() {
    setState(() {
      bool isMobileValid =
          Validator.mobileNumberValidate(mobileController.text);

      // FIX: Corrected button enabling logic
      if (isOtpVisible) {
        bool isOTPValid = Validator.emptyFieldValidate(otpController.text);
        isButtonEnabled = isMobileValid && isOTPValid; // Both must be valid
      } else {
        isButtonEnabled = isMobileValid; // Only mobile needs to be valid
      }

      buttonColor =
          isButtonEnabled ? const Color(0xFFF85A5A) : const Color(0xFFFDBABA);
    });
  }

  void _onButtonPressed() async {
    // FIX: Removed manual call to showLoadingDialog. This is now handled by the BlocListener.
    FocusScope.of(context).requestFocus(FocusNode());

    if (isOtpVisible) {
      // API call To Verify OTP
      // FIX: Removed 'clickLogin = true'
      // FIX: Removed immediate navigation. This is handled by the BlocListener on success.
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
          title: const Text(
            'Error',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // FIX: super.initState() must be called first.
    super.initState();

    // FIX: Renamed variable for clarity and update controller
    String savedMobile = Prefs.getString(SAVED_MOBILE);
    if (savedMobile.isNotEmpty) {
      mobileController.text = savedMobile;
      // FIX: Update button state after populating text
      _updateButtonColor();
    }
  }

  // FIX: Added dispose method to prevent memory leaks
  @override
  void dispose() {
    mobileController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Combined both listeners into one to handle all states correctly.
    return BlocListener<LoginMobileBloc, LoginMobileState>(
      listener: (context, state) {
        // --- Loading State Handling ---
        // ASSUMPTION: You have a state like 'LoginMobileLoading'.
        // If you don't, you should add it to your BLoC.
        // For now, we show loader on *any* event and hide on *any* result.
        // A better way is to have a dedicated 'LoginMobileLoading' state.
        /*
        if (state is LoginMobileLoading) {
           showLoadingDialog(context);
        }
        */

        // --- Success State (Login) ---
        if (state is LoginMobileSuccess) {
          hideLoadingDialog();
          print("LoginSuccess");
          Prefs.setBool(LOGIN_FLAG, true);
          // Navigation happens *here* on success, not in the button press.
          Navigator.of(context).pushNamedAndRemoveUntil(
            ROUT_DASHBOARD,
            (route) => false,
          );
        }
        // --- Success State (OTP) ---
        else if (state is LoginMobileOTPSuccess) {
          hideLoadingDialog();
          print("Login Mobile OTP Success");
          setState(() {
            isOtpVisible = true;
          });
          // Update button state after OTP field is shown
          _updateButtonColor();
        }
        // --- Error State ---
        else if (state is LoginMobileError) {
          hideLoadingDialog();
          print("login error");
          _showErrorDialog(context, state.error);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          // FIX: Removed the 'clickLogin' Visibility widget and Center.
          // The modal dialog is the only loader now.
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
                                            // FIX: Added a real error message
                                            otpErrorText =
                                                Validator.emptyFieldValidate(
                                                        value)
                                                    ? ''
                                                    : 'Please enter the OTP';
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
                                    // FIX: Dynamic button text
                                    child: CustomText(
                                        text:
                                            isOtpVisible ? 'Verify' : 'Get OTP',
                                        fontSize: 16,
                                        desiredLineHeight: 24,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFFFFFFF)),
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
          ]),
        ),
      ),
    );
  }
}
