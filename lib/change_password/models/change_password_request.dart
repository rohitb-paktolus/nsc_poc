class ChangePasswordRequest {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordRequest({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) {
    return ChangePasswordRequest(
      oldPassword: json['oldPassword'],
      newPassword: json['newPassword'],
      confirmPassword: json['confirmPassword'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}
