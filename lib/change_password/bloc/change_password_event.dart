part of 'change_password_bloc.dart';

sealed class ChangePasswordEvent extends Equatable {
  const ChangePasswordEvent();
}

class ChangePassword extends ChangePasswordEvent {
  final ChangePasswordRequest changePasswordRequest;

  const ChangePassword({required this.changePasswordRequest});

  @override
  List<Object?> get props => [changePasswordRequest];
}
