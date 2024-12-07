class AppExceptions implements Exception {
  String title;
  String msg;

  AppExceptions({required this.title, required this.msg});

  String toErrorMsg() {
    return "$title : $msg";
  }
}

class FetchDataExceptions extends AppExceptions {
  FetchDataExceptions({required String errorMsg})
      : super(title: "Network Error", msg: errorMsg);
}

class BadRequestExceptions extends AppExceptions {
  BadRequestExceptions({required String errorMsg})
      : super(title: "Invalid request", msg: errorMsg);
}

class UnauthorizedExceptions extends AppExceptions {
  UnauthorizedExceptions({required String errorMsg})
      : super(title: "Unauthorized", msg: errorMsg);
}

class InvalidInputExceptions extends AppExceptions {
  InvalidInputExceptions({required String errorMsg})
      : super(title: "Invalid Input", msg: errorMsg);
}
