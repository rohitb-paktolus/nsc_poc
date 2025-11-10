import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frequent_flow/onboarding/models/user_model.dart';
import 'package:frequent_flow/widgets/custom_alert.dart';

import '../../utils/app_functions.dart';
import '../../utils/route.dart';
import '../../utils/validation.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/phone_number_formate.dart';
import '../registration_bloc/registration_bloc.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  Color buttonColor = const Color(0xFF88c2f7); // Initialize the button color
  bool isButtonEnabled = false;
  bool _obscurePasswordText = true;
  bool _obscureConfirmPasswordText = true;
  String errorFirstName = '';
  String errorLastName = '';
  String errorEmail = '';
  String errorPhone = '';
  String errorPassword = '';
  String errorConfirmPassword = '';
  bool isSubmitting = false;
  Country? _selectedCountry;

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal using the back button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registration Successful'),
          content: const Text('Your account has been created successfully.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(ROUT_LOGIN_EMAIL);
              },
              child: const Text('Go to Login'),
            ),
          ],
        );
      },
    );
  }

  void _updateButtonColor() {
    setState(() {
      bool isFirstNameValid =
          Validator.stringValidate(firstNameController.text);
      bool isLastNameValid = Validator.stringValidate(lastNameController.text);
      bool isPhoneValid = Validator.mobileNumberValidate(phoneController.text);
      bool isPasswordValid =
          Validator.passwordValidate(passwordController.text);
      bool isConfirmPassword = Validator.confirmPasswordMatch(
        passwordController.text,
        confirmPasswordController.text,
      );

      isButtonEnabled = isFirstNameValid &&
          isLastNameValid &&
          isPhoneValid &&
          isPasswordValid &&
          isConfirmPassword;
      buttonColor =
          isButtonEnabled ? const Color(0xFF2986CC) : const Color(0xFF88C2F7);
    });
  }

  void _onButtonPressed(BuildContext context) {
    setState(() {
      isSubmitting = true;
    });
    String phoneNumber = phoneController.text;
    final phoneNo = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final user = UserModel(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        phoneNumber: phoneNo,
        emailAddress: emailController.text,
        password: passwordController.text);
    print(user.toJson());
    print("Submitted");
    context.read<RegistrationBloc>().add(RegisterUserEvent(user));
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) => showExitConfirmationDialog(
            context,
            'Confirm Exit',
            'Do you want to exit the registration process?',
            ROUT_SPLASH,
            false),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: BlocConsumer<RegistrationBloc, RegistrationState>(
            listener: (context, state) {
              if (state is RegistrationSuccess) {
                print("Registration successful");
                showSuccessDialog(context);
                setState(() {
                  isSubmitting = false;
                });
              } else if (state is RegistrationError) {
                setState(() {
                  isSubmitting = false;
                });
                showDialog(
                  context: context,
                  builder: (context) => CustomAlert(
                    title: "Error",
                    message: state.error,
                    buttonText: "Okay",
                    onButtonTap: () => Navigator.of(context).pop(),
                  ),
                );
              } else {
                setState(() {
                  isSubmitting = false;
                });
              }
            },
            builder: (context, state) {
              return Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 0, left: 24, right: 24),
                  color: const Color(0xFFFFFFFF),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const CustomText(
                          text: 'Welcome to <Application Name>',
                          fontSize: 24,
                          desiredLineHeight: 32,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF262626),
                          textAlign: TextAlign.center,
                        ),
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
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: TextFormField(
                                      controller: firstNameController,
                                      onChanged: (value) {
                                        setState(() {
                                          // Use the EmailValidator to validate and set error text
                                          errorFirstName = Validator
                                                  .stringValidate(value)
                                              ? ''
                                              : 'Please enter valid first name';
                                        });
                                        _updateButtonColor();
                                      },
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        color: Color(0xFF171717),
                                        fontWeight: FontWeight.w400,
                                        height: 1.50,
                                        fontSize: 16,
                                      ),
                                      keyboardType: TextInputType.name,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      decoration: const InputDecoration(
                                        labelText: '${'First Name'} *',
                                        labelStyle: TextStyle(
                                          color: Color(0xFF737373),
                                        ),
                                        counterText: '',
                                        border: InputBorder.none,
                                      ),
                                      maxLength: 17,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: errorFirstName.isNotEmpty,
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
                                              'assets/icons/error_icon.svg',
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
                                              text: errorFirstName,
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
                                      controller: lastNameController,
                                      onChanged: (value) {
                                        setState(() {
                                          // Use the EmailValidator to validate and set error text
                                          errorLastName = Validator
                                                  .stringValidate(value)
                                              ? ''
                                              : 'Please enter valid last name';
                                        });
                                        _updateButtonColor();
                                      },
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        color: Color(0xFF171717),
                                        fontSize: 16,
                                        // Other text style properties like fontWeight, fontFamily, etc. can also be added here.
                                      ),
                                      keyboardType: TextInputType.text,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      decoration: const InputDecoration(
                                        labelText: '${'Last Name'} *',
                                        labelStyle: TextStyle(
                                          color: Color(0xFF737373),
                                        ),
                                        counterText: '',
                                        border: InputBorder.none,
                                      ),
                                      maxLength: 17,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: errorLastName.isNotEmpty,
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
                                              'assets/icons/error_icon.svg',
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
                                              text: errorLastName,
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
                                      controller: emailController,
                                      onChanged: (value) {
                                        setState(() {
                                          // Use the EmailValidator to validate and set error text
                                          errorEmail = Validator.emailValidate(
                                                  value)
                                              ? ''
                                              : 'Please enter a valid email address';
                                        });
                                        _updateButtonColor();
                                      },
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        color: Color(0xFF171717),
                                        fontWeight: FontWeight.w400,
                                        height: 1.50,
                                        fontSize: 16,
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      textCapitalization:
                                          TextCapitalization.none,
                                      decoration: const InputDecoration(
                                        labelText: '${'Email Address'} *',
                                        labelStyle: TextStyle(
                                          color: Color(0xFF737373),
                                        ),
                                        counterText: '',
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: errorEmail.isNotEmpty,
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
                                              'assets/icons/error_icon.svg',
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
                                              text: errorEmail,
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
                                Row(children: [
                                  InkWell(
                                    onTap: () {
                                      showCountryPicker(
                                        context: context,
                                        exclude: <String>['KN', 'MF'],
                                        favorite: <String>[],
                                        showPhoneCode: true,
                                        onSelect: (Country country) {
                                          setState(() {
                                            _selectedCountry = country;
                                          });
                                        },
                                        // Optional. Sets the theme for the country list picker.
                                        countryListTheme: CountryListThemeData(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(40.0),
                                            topRight: Radius.circular(40.0),
                                          ),
                                          // Optional. Styles the search field.
                                          inputDecoration: InputDecoration(
                                            labelText: 'Search',
                                            hintText: 'Start typing to search',
                                            prefixIcon:
                                                const Icon(Icons.search),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: const Color(0xFF8C98A8)
                                                    .withOpacity(0.2),
                                              ),
                                            ),
                                          ),
                                          searchTextStyle: const TextStyle(
                                            color: Colors.blue,
                                            fontSize: 18,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 55,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: const Color(0xFFE5E5E5),
                                            width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Center(
                                          child: Text(
                                            _selectedCountry != null
                                                ? '+${_selectedCountry!.phoneCode}'
                                                : '+1',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Inter',
                                                color: Color(0xFF171717)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: const Color(0xFFE5E5E5),
                                            width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: TextFormField(
                                          controller: phoneController,
                                          onChanged: (value) {
                                            setState(() {
                                              errorPhone = Validator
                                                      .mobileNumberValidate(
                                                          value)
                                                  ? ''
                                                  : 'Please enter a valid phone number.';
                                            });
                                            _updateButtonColor();
                                          },
                                          inputFormatters: [
                                            PhoneNumberFormatter()
                                          ],
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            color: Color(0xFF171717),
                                            fontSize: 16,
                                          ),
                                          keyboardType: const TextInputType
                                              .numberWithOptions(
                                              signed: true, decimal: true),
                                          textInputAction: TextInputAction.done,
                                          onFieldSubmitted: (value) {
                                            FocusScope.of(context).unfocus();
                                          },
                                          decoration: const InputDecoration(
                                            labelText: '${'Phone'} *',
                                            labelStyle: TextStyle(
                                              color: Color(0xFF737373),
                                            ),
                                            counterText: '',
                                            border: InputBorder.none,
                                          ),
                                          maxLength:
                                              17, // Set maximum character limit
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                                Visibility(
                                  visible: errorPhone.isNotEmpty,
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/error_icon.svg',
                                          height: 12.67,
                                          width: 12.67,
                                        ),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        Expanded(
                                          child: CustomText(
                                            text: errorPhone,
                                            fontSize: 12,
                                            desiredLineHeight: 16,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFFDF4747),
                                            textAlign: TextAlign.left,
                                          ),
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
                                          left: 8.0, right: 46),
                                      child: TextFormField(
                                        controller: passwordController,
                                        obscureText: _obscurePasswordText,
                                        onChanged: (value) {
                                          setState(() {
                                            // Use the EmailValidator to validate and set error text
                                            errorPassword = Validator
                                                    .passwordValidate(value)
                                                ? ''
                                                : 'Password do not meet requirements:\n\u2022 Must contain at least 8 characters\n\u2022 Must contain one special symbol (#, &, % etc)\n\u2022 Must contain one number (0-9)';
                                          });
                                          if (confirmPasswordController.text !=
                                              '') {
                                            errorConfirmPassword =
                                                Validator.confirmPasswordMatch(
                                                        confirmPasswordController
                                                            .text,
                                                        value)
                                                    ? ''
                                                    : 'Passwords do not match';
                                          }
                                          _updateButtonColor();
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter Password';
                                          }
                                          return null;
                                        },
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          color: Color(0xFF171717),
                                          fontSize: 16,
                                          // Other text style properties like fontWeight, fontFamily, etc. can also be added here.
                                        ),
                                        decoration: const InputDecoration(
                                          labelText: 'Password',
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
                                            _obscurePasswordText =
                                                !_obscurePasswordText;
                                          });
                                        },
                                        child: Icon(
                                          _obscurePasswordText
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: const Color(0xFFA3A3A3),
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                                Visibility(
                                  visible: errorPassword.isNotEmpty,
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/error_icon.svg',
                                          height: 12.67,
                                          width: 12.67,
                                        ),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        Expanded(
                                          child: CustomText(
                                            text: errorPassword,
                                            fontSize: 12,
                                            desiredLineHeight: 16,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFFDF4747),
                                            textAlign: TextAlign.left,
                                          ),
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
                                          left: 8.0, right: 46),
                                      child: TextFormField(
                                        controller: confirmPasswordController,
                                        obscureText:
                                            _obscureConfirmPasswordText,
                                        onChanged: (value) {
                                          setState(() {
                                            errorConfirmPassword =
                                                Validator.confirmPasswordMatch(
                                                        passwordController.text,
                                                        value)
                                                    ? ''
                                                    : 'Passwords do not match';
                                          });
                                          _updateButtonColor();
                                        },
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          color: Color(0xFF171717),
                                          fontSize: 16,
                                          // Other text style properties like fontWeight, fontFamily, etc. can also be added here.
                                        ),
                                        decoration: InputDecoration(
                                          labelText: 'Confirm Password',
                                          labelStyle: const TextStyle(
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
                                          color: const Color(0xFFA3A3A3),
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                                Visibility(
                                  visible: errorConfirmPassword.isNotEmpty,
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/error_icon.svg',
                                          height: 12.67,
                                          width: 12.67,
                                        ),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        Expanded(
                                          child: CustomText(
                                            text: errorConfirmPassword,
                                            fontSize: 12,
                                            desiredLineHeight: 16,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFFDF4747),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ]),
                                ),
                                const SizedBox(
                                  height: 24,
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: buttonColor,
                                  ),
                                  child: TextButton(
                                    onPressed: isSubmitting
                                        ? null
                                        : (isButtonEnabled
                                            ? () => _onButtonPressed(context)
                                            : null),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const CustomText(
                                            text: 'Submit',
                                            fontSize: 16,
                                            desiredLineHeight: 24,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFFFFFFF)),
                                        if (isSubmitting)
                                          CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                        Center(
                          child: Visibility(
                            visible: isSubmitting,
                            child: const CircularProgressIndicator(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ));
  }
}
