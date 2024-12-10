import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/UserSession.dart';
import '../../remote_api/api_helper.dart';
import '../../remote_api/urls.dart';
import 'events.dart';
import 'states.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final ApiService apiService;

  UserBloc(this.apiService) : super(UserInitialState()) {
    on<RegisterUserEvent>(_onRegisterUser);
    on<LoginUserEvent>(_onLoginUser);
    on<UserLogoutEvent>(_onLoggedOut);
    on<LoadUserSessionEvent>(_onLoadUserSession);
    on<CheckOnboardingEvent>(_onCheckOnboarding);
  }

  Future<void> _onRegisterUser(RegisterUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoadingState());
    try {
      final response = await apiService.postAPI(
        url: Urls.REGISTER_URL,
        body: {
          "name": event.name,
          "email": event.email,
          "password": event.password,
          "mobile_number": event.mobileNumber,
        },
      );

      if (response['status'] == true) {
        final token = response['token'];
        final username = event.name;
        print("registration done");
        // Save session
        await UserSession().saveTokenToPrefs(token);
        await UserSession().saveNameToPrefs(username);
        UserSession().loadUserSession(
          UserSessionLoadedState(token: token, username: username),
        );

        emit(UserSessionLoadedState(token: token, username: username));
      } else {
        emit(UserErrorState(response['message']));
      }
    } catch (e) {
      emit(UserErrorState("Registration failed: ${e.toString()}"));
    }
  }

  Future<void> _onLoginUser(LoginUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoadingState());
    try {
      final response = await apiService.postAPI(
        url: Urls.LOGIN_URL,
        body: {
          "email": event.email,
          "password": event.password,
        },
      );

      if (response['status'] == true) {
        final token = response['tokan'];
        // Fetch user details using the token
        final userDetails = await apiService.fetchUserDetails(url: Urls.userslist_URL, token: token, email: event.email);

        if (userDetails != null) {
          final username = userDetails['name']; // Extract 'name' from userDetails

          // Save session
          await UserSession().saveTokenToPrefs(token);
          await UserSession().saveNameToPrefs(username);

          UserSession().loadUserSession(
            UserSessionLoadedState(token: token, username: username),
          );

          emit(UserSessionLoadedState(token: token, username: username));
        }

      } else {
        emit(UserErrorState(response['message']));
      }
    } catch (e) {
      emit(UserErrorState("Login failed: ${e.toString()}"));
    }
  }

  Future<void> _onLoadUserSession(LoadUserSessionEvent event, Emitter<UserState> emit) async {
    try {
      emit(UserLoadingState()); // Emit a loading state during session validation

      // Retrieve the token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? uname = prefs.getString('username');

      if (token != null && uname != null) {

        // Load the session into the Singleton
        UserSession().loadUserSession(UserSessionLoadedState(token: token, username: uname));

        // Emit the session loaded state
        emit(UserSessionLoadedState(token: token, username: uname));
      } else {
        emit(UserLoggedOutState()); // No token found, consider user logged out
      }
    } catch (e) {
      emit(UserErrorState('An error occurred while loading session: ${e.toString()}'));
    }
  }


  Future<void> _onLoggedOut(UserLogoutEvent event, Emitter<UserState> emit) async {
    try {
      UserSession().clearSession();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all session data
      emit(UserLoggedOutState());
    } catch (e) {
      emit(UserErrorState("Logout failed: ${e.toString()}"));
    }
  }

  Future<void> _onCheckOnboarding(CheckOnboardingEvent event, Emitter<UserState> emit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    print('Has seen onboarding: $hasSeenOnboarding');

    if (!hasSeenOnboarding) {
      print('Emitting OnboardingNotSeenState');
      emit(OnboardingNotSeenState());
    } else {
      // If onboarding has been seen, check for user session
      add(LoadUserSessionEvent());
    }
  }

}
