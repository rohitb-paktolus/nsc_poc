class LoginMobileGetOTPResponse {
  String? error;
  Details? details;

  LoginMobileGetOTPResponse({this.error, this.details});

  LoginMobileGetOTPResponse.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    details =
    json['details'] != null ? new Details.fromJson(json['details']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['error'] = this.error;
    if (this.details != null) {
      data['details'] = this.details!.toJson();
    }
    return data;
  }
}

class Details {
  String? mobileNumber;
  bool? success;
  String? message;

  Details({this.mobileNumber, this.success, this.message});

  Details.fromJson(Map<String, dynamic> json) {
    mobileNumber = json['mobileNumber'];
    success = json['success'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mobileNumber'] = this.mobileNumber;
    data['success'] = this.success;
    data['message'] = this.message;
    return data;
  }
}
