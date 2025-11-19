import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frequent_flow/authentication/login_email_bloc/login_bloc.dart';
import 'package:frequent_flow/authentication/login_mobile_bloc/login_mobile_bloc.dart';
import 'package:frequent_flow/authentication/repository/login_mobile_repository.dart';
import 'package:frequent_flow/authentication/repository/login_repository.dart';
import 'package:frequent_flow/authentication/screens/login_mobile_screen.dart';
import 'package:frequent_flow/biometrics/screens/biometric_auth_screen.dart';
import 'package:frequent_flow/change_password/bloc/change_password_bloc.dart';
import 'package:frequent_flow/change_password/change_password_screen.dart';
import 'package:frequent_flow/change_password/repository/change_password_repository.dart';
import 'package:frequent_flow/onboarding/bloc/forgot_password_bloc/forgot_password_bloc.dart';
import 'package:frequent_flow/onboarding/registration_bloc/registration_bloc.dart';
import 'package:frequent_flow/onboarding/repository/forgot_password_repository.dart';
import 'package:frequent_flow/onboarding/repository/registration_repository.dart';
import 'package:frequent_flow/onboarding/screens/forgot_password.dart';
import 'package:frequent_flow/qr_code/generate_qr_code.dart';
import 'package:frequent_flow/qr_code/scan_qr_code.dart';
import 'package:frequent_flow/utils/prefs.dart';
import 'package:frequent_flow/utils/route.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frequent_flow/video_player/video_player_screen.dart';
import 'authentication/screens/login_option_screen.dart';
import 'firebase_options.dart';
import 'SplashScreen.dart';
import 'authentication/screens/login_email_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'map/map_integration.dart';
import 'onboarding/screens/registration.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Prefs.init();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<RegistrationBloc>(
          create: (context) => RegistrationBloc(RegistrationRepository()),
        ),
        BlocProvider<LoginEmailBloc>(
          create: (context) =>
              LoginEmailBloc(loginRepository: LoginRepository()),
        ),
        BlocProvider<ChangePasswordBloc>(
          create: (context) => ChangePasswordBloc(
              changePasswordRepository: ChangePasswordRepository()),
        ),
        BlocProvider<ForgotPasswordBloc>(
          create: (context) => ForgotPasswordBloc(
              forgotPasswordRepository: ForgotPasswordRepository()),
        ),
        BlocProvider<LoginMobileBloc>(
          create: (context) =>
              LoginMobileBloc(loginMobileRepository: LoginMobileRepository()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POC NSC',
      debugShowCheckedModeBanner: false,
      navigatorKey: rootNavigatorKey,
      theme: ThemeData(
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: Color(0xFF2986CC)),
        primaryColor: const Color(0xFF2986CC),
        dialogTheme: const DialogThemeData(
          backgroundColor: Colors.white,
        ),
      ),
      initialRoute: ROUT_SPLASH,
      onGenerateRoute: (setting) {
        switch (setting.name) {
          case ROUT_SPLASH:
            return MaterialPageRoute(builder: (BuildContext context) {
              return const SafeArea(top: false, child: SplashScreen());
            });
          case ROUT_LOGIN_OPTION:
            return MaterialPageRoute(builder: (BuildContext context) {
              return const SafeArea(top: false, child: LoginOptionScreen());
            });
          case ROUT_LOGIN_EMAIL:
            return MaterialPageRoute(builder: (BuildContext context) {
              return const SafeArea(top: false, child: LoginEmailScreen());
            });
          case ROUT_LOGIN_MOBILE:
            return MaterialPageRoute(builder: (BuildContext context) {
              return const SafeArea(top: false, child: LoginMobileScreen());
            });
          case ROUT_DASHBOARD:
            return MaterialPageRoute(builder: (BuildContext context) {
              return const SafeArea(top: true, child: DashboardScreen());
            });
          case ROUT_REGISTRATION:
            return MaterialPageRoute(builder: (BuildContext context) {
              return const SafeArea(top: true, child: Registration());
            });
          case ROUT_MAP_INTEGRATION:
            return MaterialPageRoute(
              builder: (context) {
                return const SafeArea(child: MapSampleScreen());
              },
            );
          case ROUT_CHANGE_PASSWORD:
            return MaterialPageRoute(
              builder: (context) {
                return const SafeArea(child: ChangePasswordScreen());
              },
            );
          case ROUT_FORGOT_PASSWORD:
            return MaterialPageRoute(
              builder: (context) {
                return const SafeArea(child: ForgotPasswordScreen());
              },
            );
          case ROUT_BIOMETRIC:
            return MaterialPageRoute(
              builder: (context) {
                return const SafeArea(child: BiometricAuthScreen());
              },
            );

          case ROUT_QR_CODE:
            return MaterialPageRoute(
              builder: (context) {
                return const SafeArea(child: GenerateQrCode());
              },
            );
          case ROUT_SCAN_QR_CODE:
            return MaterialPageRoute(
              builder: (context) {
                return const SafeArea(child: ScanQrCode());
              },
            );
          case ROUTE_VIDEO:
            return MaterialPageRoute(builder: (context) {
              return const SafeArea(
                child: VideoPlayerScreen(
                    source:
                        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"),
              );
            });
          case ROUTE_BIOMETRICS:
            return MaterialPageRoute(builder: (context) {
              return const SafeArea(child: BiometricAuthScreen());
            },);
        }
        return null;
      },
    );
  }
}
