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
  Color buttonColor = const Color(0xFFE5E5E5);

  void _onButtonPressed(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
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
    }
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Error',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Success',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text('Password changed successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
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
      isButtonEnabled ? const Color(0xFF2986CC) : const Color(0xFFE5E5E5);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Change Password',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: const Color(0xFF2986CC),
      ),
      body: BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
        listener: (context, state) {
          if (state is ChangePasswordSuccess) {
            _showSuccessDialog(context);
          } else if (state is ChangePasswordError) {
            _showErrorDialog(context, state.error);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Background Header
              Container(
                height: 150,
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

              // Main Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Security Card
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
                          children: [
                            // Security Icon
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2986CC).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock_reset_rounded,
                                size: 40,
                                color: Color(0xFF2986CC),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const CustomText(
                              text: 'Update Your Password',
                              fontSize: 18,
                              desiredLineHeight: 24,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF171717),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const CustomText(
                              text: 'Create a strong and secure new password',
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
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Current Password
                                  _PasswordField(
                                    controller: _currentPasswordController,
                                    obscureText: _obscureCurrentPasswordText,
                                    labelText: "Current Password",
                                    errorText: _currentPasswordErrorText,
                                    onChanged: (value) {
                                      setState(() {
                                        _currentPasswordErrorText =
                                        Validator.emptyFieldValidate(value)
                                            ? ''
                                            : "Enter current password";
                                      });
                                      _updateButtonColor();
                                    },
                                    onToggleVisibility: () {
                                      setState(() {
                                        _obscureCurrentPasswordText =
                                        !_obscureCurrentPasswordText;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // New Password
                                  _PasswordField(
                                    controller: _newPasswordController,
                                    obscureText: _obscureNewPasswordText,
                                    labelText: "New Password",
                                    errorText: _newPasswordErrorText,
                                    onChanged: (value) {
                                      setState(() {
                                        _newPasswordErrorText = Validator
                                            .passwordValidate(value)
                                            ? Validator.oldPasswordMatch(
                                            _currentPasswordController
                                                .text,
                                            value)
                                            ? ''
                                            : "Current and new password should not be same"
                                            : "Password requirements:\n• 8+ characters\n• 1 special symbol\n• 1 number (0-9)";
                                      });
                                      _updateButtonColor();
                                    },
                                    onToggleVisibility: () {
                                      setState(() {
                                        _obscureNewPasswordText =
                                        !_obscureNewPasswordText;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Confirm Password
                                  _PasswordField(
                                    controller: _confirmPasswordController,
                                    obscureText: _obscureConfirmPasswordText,
                                    labelText: "Confirm New Password",
                                    errorText: _confirmPasswordErrorText,
                                    onChanged: (value) {
                                      setState(() {
                                        _confirmPasswordErrorText =
                                        Validator.confirmPasswordMatch(
                                            _newPasswordController.text,
                                            value)
                                            ? ''
                                            : "Passwords do not match";
                                      });
                                      _updateButtonColor();
                                    },
                                    onToggleVisibility: () {
                                      setState(() {
                                        _obscureConfirmPasswordText =
                                        !_obscureConfirmPasswordText;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Save Button
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
                            ? () => _onButtonPressed(context)
                            : null,
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: state is ChangePasswordLoading
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
                              Icons.lock_reset_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            CustomText(
                              text: "Update Password",
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
          );
        },
      ),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter $labelText";
                    }
                    return null;
                  },
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
          Container(
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
          ),
        ],
      ],
    );
  }
}