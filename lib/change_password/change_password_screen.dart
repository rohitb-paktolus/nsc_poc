import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frequent_flow/change_password/bloc/change_password_bloc.dart';
import 'package:frequent_flow/change_password/models/change_password_request.dart';

import '../utils/validation.dart';
import '../widgets/custom_text.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  bool _obscureCurrentPasswordText = true;
  String _currentPasswordErrorText = '';
  final _newPasswordController = TextEditingController();
  bool _obscureNewPasswordText = true;
  String _newPasswordErrorText = '';
  final _confirmPasswordController = TextEditingController();
  bool _obscureConfirmPasswordText = true;
  String _confirmPasswordErrorText = '';
  bool isButtonEnabled = false;
  Color buttonColor = const Color(0xFFFDBABA);

  bool _isLoading = false;

  void _onButtonPressed(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      // setState(() {
      //   _isLoading = true;
      // });

      // API call implementation
      // await Future.delayed(Duration(seconds: 2));
      final changePasswordRequest = ChangePasswordRequest(
        oldPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      print(changePasswordRequest.toJson());
      context.read<ChangePasswordBloc>().add(
            ChangePassword(
              changePasswordRequest: changePasswordRequest,
            ),
          );

      // setState(() {
      //   _isLoading = false;
      // });

      // Response handling
      // final isSuccess = true;
      // if (isSuccess) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text("Password changed successfully!"),
      //     ),
      //   );
      //   _currentPasswordController.clear();
      //   _newPasswordController.clear();
      //   _confirmPasswordController.clear();
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text("Failed to change password. Try again."),
      //     ),
      //   );
      // }
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

  void _updateButtonColor() {
    setState(() {
      bool isCurrentPasswordValid =
          Validator.emptyFieldValidate(_currentPasswordController.text);
      bool isPasswordValid =
          Validator.passwordValidate(_newPasswordController.text);
      bool isConfirmPassword = Validator.confirmPasswordMatch(
        _newPasswordController.text,
        _confirmPasswordController.text,
      );
      bool isCompareOldPassword = Validator.oldPasswordMatch(
          _currentPasswordController.text, _newPasswordController.text);
      isButtonEnabled = isCurrentPasswordValid &&
          isPasswordValid &&
          isConfirmPassword &&
          isCompareOldPassword;
      buttonColor =
          isButtonEnabled ? const Color(0xFF2986CC) : const Color(0xFF88C2F7);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
      ),
      body: BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
        listener: (context, state) {
          if (state is ChangePasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Password changed successfully!"),
              ),
            );
            Navigator.of(context).pop();
          } else if (state is ChangePasswordError) {
            print("change password error");
            _showErrorDialog(context, state.error);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.start,
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   children: [
                //     Container(
                //       height: 50,
                //       alignment: Alignment.centerLeft,
                //       child: InkWell(
                //         onTap: () {
                //           // widget.onBackArrowTap();
                //         },
                //         child: SvgPicture.asset(
                //           'assets/icon/back_arrow_icon.svg',
                //           width: 40,
                //           height: 40,
                //         ),
                //       ),
                //     ),
                //     const SizedBox(width: 12),
                //     Container(
                //       height: 50,
                //       alignment: Alignment.centerLeft,
                //       child: const CustomText(
                //         text: "Change Password",
                //         fontSize: 20,
                //         desiredLineHeight: 28,
                //         fontFamily: 'Inter',
                //         fontWeight: FontWeight.w600,
                //         letterSpacing: 0.02,
                //         color: Color(0xFF171717),
                //         textAlign: TextAlign.center,
                //       ),
                //     ),
                //   ],
                // ),
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      // color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(children: [
                        Form(
                            key: _formKey,
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
                                    child: Stack(children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 50.0),
                                        child: TextFormField(
                                          controller:
                                              _currentPasswordController,
                                          obscureText:
                                              _obscureCurrentPasswordText,
                                          onChanged: (value) {
                                            setState(() {
                                              _currentPasswordErrorText =
                                                  Validator.emptyFieldValidate(
                                                          value)
                                                      ? ''
                                                      : "Enter current password";
                                            });
                                            _updateButtonColor();
                                          },
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Please enter password";
                                            }
                                            return null;
                                          },
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            color: Color(0xFF737373),
                                            fontSize: 16,
                                          ),
                                          decoration: const InputDecoration(
                                            labelText: "Current password",
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
                                      Positioned(
                                        right: 14,
                                        top: 0,
                                        bottom: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _obscureCurrentPasswordText =
                                                  !_obscureCurrentPasswordText;
                                            });
                                          },
                                          child: Icon(
                                            _obscureCurrentPasswordText
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: const Color(0xFF9CA3AF),
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ),
                                  Visibility(
                                    visible:
                                        _currentPasswordErrorText.isNotEmpty,
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icon/error_icon.svg',
                                            height: 12.67,
                                            width: 12.67,
                                            alignment: Alignment.center,
                                          ),
                                          const SizedBox(
                                            width: 4,
                                          ),
                                          CustomText(
                                            text: _currentPasswordErrorText,
                                            fontSize: 12,
                                            desiredLineHeight: 16,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFFDF4747),
                                            textAlign: TextAlign.left,
                                          ),
                                        ]),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xFFE5E5E5),
                                          width: 1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Stack(children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 50.0),
                                        child: TextFormField(
                                          controller: _newPasswordController,
                                          obscureText: _obscureNewPasswordText,
                                          onChanged: (value) {
                                            setState(() {
                                              _newPasswordErrorText = Validator
                                                      .passwordValidate(value)
                                                  ? _newPasswordErrorText =
                                                      Validator.oldPasswordMatch(
                                                              _currentPasswordController
                                                                  .text,
                                                              value)
                                                          ? ''
                                                          : "Current password and new password should not be same"
                                                  : "Password do not meet requirements:\n\n\u2022 Must contain at least 8 characters\n\u2022 Must contain one special symbol (#, &, % etc)\n\u2022 Must contain one number (0-9)";
                                            });
                                            _updateButtonColor();
                                          },
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Please enter Password";
                                            }
                                            return null;
                                          },
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            color: Color(0xFF737373),
                                            fontSize: 16,
                                            // Other text style properties like fontWeight, fontFamily, etc. can also be added here.
                                          ),
                                          decoration: const InputDecoration(
                                            labelText: "New Password",
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
                                      Positioned(
                                        right: 14,
                                        top: 0,
                                        bottom: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _obscureNewPasswordText =
                                                  !_obscureNewPasswordText;
                                            });
                                          },
                                          child: Icon(
                                            _obscureNewPasswordText
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: const Color(0xFF9CA3AF),
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ),
                                  Visibility(
                                    visible: _newPasswordErrorText.isNotEmpty,
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icon/error_icon.svg',
                                            height: 12.67,
                                            width: 12.67,
                                            alignment: Alignment.center,
                                          ),
                                          const SizedBox(
                                            width: 4,
                                          ),
                                          CustomText(
                                            text: _newPasswordErrorText,
                                            fontSize: 12,
                                            desiredLineHeight: 16,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFFDF4747),
                                            textAlign: TextAlign.left,
                                          ),
                                        ]),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xFFE5E5E5),
                                          width: 1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Stack(children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 50.0),
                                        child: TextFormField(
                                          controller:
                                              _confirmPasswordController,
                                          obscureText:
                                              _obscureConfirmPasswordText,
                                          onChanged: (value) {
                                            setState(() {
                                              // Use the EmailValidator to validate and set error text
                                              _confirmPasswordErrorText =
                                                  Validator.confirmPasswordMatch(
                                                          _newPasswordController
                                                              .text,
                                                          value)
                                                      ? ''
                                                      : "Passwords do not match";
                                            });
                                            _updateButtonColor();
                                          },
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            color: Color(0xFF737373),
                                            fontSize: 16,
                                            // Other text style properties like fontWeight, fontFamily, etc. can also be added here.
                                          ),
                                          decoration: const InputDecoration(
                                            labelText: "Re-type New Password",
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
                                      Positioned(
                                        right: 14,
                                        top: 0,
                                        bottom: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _obscureConfirmPasswordText =
                                                  !_obscureConfirmPasswordText;
                                            });
                                          },
                                          child: Icon(
                                            _obscureConfirmPasswordText
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: const Color(0xFF9CA3AF),
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ),
                                  Visibility(
                                    visible:
                                        _confirmPasswordErrorText.isNotEmpty,
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icon/error_icon.svg',
                                            height: 12.67,
                                            width: 12.67,
                                          ),
                                          const SizedBox(
                                            width: 4,
                                          ),
                                          CustomText(
                                            text: _confirmPasswordErrorText,
                                            fontSize: 12,
                                            desiredLineHeight: 16,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFFDF4747),
                                            textAlign: TextAlign.left,
                                          ),
                                        ]),
                                  ),
                                  const SizedBox(
                                    height: 24,
                                  ),
                                ])),
                        const SizedBox(
                          height: 50,
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
                                ? () {
                                    _onButtonPressed(context);
                                  }
                                : null,
                            child: const CustomText(
                                text: "Save Changes",
                                fontSize: 16,
                                desiredLineHeight: 24,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFFFFFF)),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
