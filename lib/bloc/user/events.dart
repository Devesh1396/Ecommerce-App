abstract class UserEvent {}

class RegisterUserEvent extends UserEvent {
  final String name;
  final String email;
  final String password;
  final String mobileNumber;

  RegisterUserEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.mobileNumber,
  });
}

class LoginUserEvent extends UserEvent {
  final String email;
  final String password;

  LoginUserEvent({
    required this.email,
    required this.password,
  });
}

class LoadUserSessionEvent extends UserEvent {}

class CheckOnboardingEvent extends UserEvent {}

class UserLogoutEvent extends UserEvent {}




