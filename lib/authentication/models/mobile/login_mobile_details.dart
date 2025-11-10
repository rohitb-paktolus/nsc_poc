class LoginMobileDetails {
  String? phoneNumber;
  String? otp;

  LoginMobileDetails({required this.phoneNumber, required this.otp});

  LoginMobileDetails.fromJson(Map<String, dynamic> json) {
    phoneNumber = json['phoneNumber'];
    otp = json['otp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['phoneNumber'] = this.phoneNumber;
    data['otp'] = this.otp;
    return data;
  }
}
