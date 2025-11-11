import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frequent_flow/authentication/login_email_bloc/login_bloc.dart';
import 'package:frequent_flow/authentication/models/email/login_details.dart';
import 'package:frequent_flow/widgets/custom_alert.dart';

import '../../utils/pref_key.dart';
import '../../utils/prefs.dart';
import '../../utils/route.dart';
import '../../utils/validation.dart';
import '../../widgets/custom_text.dart';

class LoginEmailScreen extends StatefulWidget {
  const LoginEmailScreen({super.key});

  @override
  State<LoginEmailScreen> createState() => _LoginEmailScreenState();
}

class _LoginEmailScreenState extends State<LoginEmailScreen> {
  bool _obscureText = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formEmailKey = GlobalKey<FormState>();
  Color buttonColor = const Color(0xFFE5E5E5);
  String passwordErrorText = '';
  String emailErrorText = '';
  bool isButtonEnabled = false;
  bool clickLogin = false;
  int loginAttemptCount = 2;
  bool isBiometricDialogVisible = false;

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
                  strokeCap: StrokeCap.round,
                ),
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

  @override
  void initState() {
    String savedEmail = Prefs.getString(SAVED_EMAIL);
    if (savedEmail.isNotEmpty) {
      emailController.text = Prefs.getString(SAVED_EMAIL);
    }
    super.initState();
  }

  void _updateButtonColor() {
    setState(() {
      bool isEmailValid = Validator.emailValidate(emailController.text);
      bool isPasswordValid =
      Validator.emptyFieldValidate(passwordController.text);
      isButtonEnabled = isEmailValid && isPasswordValid;
      buttonColor =
      isButtonEnabled ? const Color(0xFF2986CC) : const Color(0xFFE5E5E5);
    });
  }

  void _onButtonPressed() async {
    showLoadingDialog(context);
    setState(() {
      clickLogin = true;
    });
    FocusScope.of(context).requestFocus(FocusNode());

    LoginDetails loginDetails = LoginDetails(
      emailAddress: emailController.text,
      password: passwordController.text,
    );
    print("Login details");
    print(loginDetails.toJson());
    context.read<LoginEmailBloc>().add(LoginUser(loginDetails: loginDetails));
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlert(
          title: "Error",
          message: errorMessage,
          buttonText: "OK",
          onButtonTap: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginEmailBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          hideLoadingDialog();
          clickLogin = false;
          print(state.loginResponse.toJson());
          Prefs.setBool(LOGIN_FLAG, true);
          Navigator.of(context).pushNamedAndRemoveUntil(
            ROUT_DASHBOARD,
                (route) => false,
          );
        } else if (state is LoginError) {
          hideLoadingDialog();
          clickLogin = false;
          print("login error");
          _showErrorDialog(context, state.error);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: GestureDetector(
            onTap: () {
              // Dismiss keyboard when tapping outside
              FocusScope.of(context).unfocus();
            },
            child: Stack(
              children: [
                // Background Header
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF2986CC).withOpacity(0.9),
                        const Color(0xFF2986CC).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                ),

                // Scrollable Content
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 40),

                        // Login Card
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Login Icon
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2986CC).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    size: 40,
                                    color: Color(0xFF2986CC),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const CustomText(
                                  text: 'Welcome Back',
                                  fontSize: 18,
                                  desiredLineHeight: 24,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF171717),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const CustomText(
                                  text: 'Sign in to continue to your account',
                                  fontSize: 14,
                                  desiredLineHeight: 20,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF737373),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),

                                // Form
                                Form(
                                  key: _formEmailKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Email Field
                                      _InputField(
                                        controller: emailController,
                                        labelText: "Email",
                                        errorText: emailErrorText,
                                        isPassword: false,
                                        onChanged: (value) {
                                          setState(() {
                                            emailErrorText =
                                            Validator.emailValidate(value)
                                                ? ''
                                                : 'Please enter a valid email address';
                                          });
                                          _updateButtonColor();
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      // Password Field
                                      _PasswordField(
                                        controller: passwordController,
                                        obscureText: _obscureText,
                                        labelText: "Password",
                                        errorText: passwordErrorText,
                                        onChanged: (value) {
                                          setState(() {
                                            passwordErrorText =
                                            Validator.emptyFieldValidate(value)
                                                ? ''
                                                : '';
                                          });
                                          _updateButtonColor();
                                        },
                                        onToggleVisibility: () {
                                          setState(() {
                                            _obscureText = !_obscureText;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      // Forgot Password
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, ROUT_FORGOT_PASSWORD);
                                          },
                                          child: const CustomText(
                                            text: 'Forgot Password?',
                                            fontSize: 14,
                                            desiredLineHeight: 20,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF2986CC),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      // Login Button
                                      Container(
                                        width: double.infinity,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          color: buttonColor,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: TextButton(
                                          onPressed: isButtonEnabled
                                              ? _onButtonPressed
                                              : null,
                                          style: TextButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: state is LoginLoading
                                              ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                              : const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.login_rounded,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              SizedBox(width: 8),
                                              CustomText(
                                                text: "Sign In",
                                                fontSize: 16,
                                                desiredLineHeight: 24,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFFFFFFFF),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Register Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: 'New User? ',
                              style: const TextStyle(
                                color: Color(0xFF737373),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Register here',
                                  style: const TextStyle(
                                    color: Color(0xFF2986CC),
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      Navigator.pushNamed(
                                          context, ROUT_REGISTRATION);
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Add extra space at the bottom for keyboard
                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 100 : 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String errorText;
  final bool isPassword;
  final ValueChanged<String> onChanged;

  const _InputField({
    required this.controller,
    required this.labelText,
    required this.errorText,
    required this.onChanged,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: errorText.isNotEmpty
                  ? const Color(0xFFDF4747)
                  : const Color(0xFFE5E5E5),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              controller: controller,
              onChanged: onChanged,
              obscureText: isPassword,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF171717),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: labelText,
                labelStyle: const TextStyle(
                  color: Color(0xFF737373),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
              keyboardType: isPassword
                  ? TextInputType.visiblePassword
                  : TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
          ),
        ),
        if (errorText.isNotEmpty) ...[
          const SizedBox(height: 8),
          _ErrorText(errorText: errorText),
        ],
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final String labelText;
  final String errorText;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggleVisibility;

  const _PasswordField({
    required this.controller,
    required this.obscureText,
    required this.labelText,
    required this.errorText,
    required this.onChanged,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: errorText.isNotEmpty
                  ? const Color(0xFFDF4747)
                  : const Color(0xFFE5E5E5),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 50.0),
                child: TextFormField(
                  controller: controller,
                  obscureText: obscureText,
                  onChanged: onChanged,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF171717),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: labelText,
                    labelStyle: const TextStyle(
                      color: Color(0xFF737373),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: onToggleVisibility,
                  child: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF737373),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText.isNotEmpty) ...[
          const SizedBox(height: 8),
          _ErrorText(errorText: errorText),
        ],
      ],
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String errorText;

  const _ErrorText({required this.errorText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/icon/error_icon.svg',
            height: 14,
            width: 14,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CustomText(
              text: errorText,
              fontSize: 12,
              desiredLineHeight: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              color: const Color(0xFFDF4747),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}