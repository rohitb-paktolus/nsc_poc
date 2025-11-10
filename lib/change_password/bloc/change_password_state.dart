part of 'change_password_bloc.dart';

sealed class ChangePasswordState extends Equatable {
  const ChangePasswordState();
}

final class ChangePasswordInitial extends ChangePasswordState {
  @override
  List<Object> get props => [];
}

final class ChangePasswordLoading extends ChangePasswordState {
  @override
  List<Object?> get props => [];
}

final class ChangePasswordSuccess extends ChangePasswordState {
  final ChangePasswordResponse response;

  const ChangePasswordSuccess({required this.response});

  @override
  List<Object?> get props => [response];
}

final class ChangePasswordError extends ChangePasswordState {
  final String error;

  const ChangePasswordError({required this.error});

  @override
  List<Object?> get props => [error];
}
