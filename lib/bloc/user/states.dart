abstract class UserState {}

class UserInitialState extends UserState {}

class UserLoadingState extends UserState {}

class UserSessionLoadedState extends UserState {
  final String token;
  final String username;

  UserSessionLoadedState({
    required this.token,
    required this.username,
  });
}

class UserErrorState extends UserState {
  final String message;

  UserErrorState(this.message);
}

class UserLoggedOutState extends UserState {}

class OnboardingNotSeenState extends UserState {}

