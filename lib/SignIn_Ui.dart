import 'package:ecom_app/MainApp.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'bloc/user/bloc_code.dart';
import 'bloc/user/events.dart';
import 'bloc/user/states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class SigninUi extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

  class _SignInState extends State<SigninUi> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void loginUser() {
    String email = emailController.text;
    String password = passwordController.text;

    // Dispatch FetchUserEvent to the UserBloc
    context.read<UserBloc>().add(
      LoginUserEvent(email: email, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get screen size information
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocListener<UserBloc, UserState>(
        listener: (context, state) {
      if (state is UserLoadingState) {
        // Optionally show a loading indicator
      } else if (state is UserSessionLoadedState) {
        // Login successful
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } else if (state is UserErrorState) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                margin: EdgeInsets.only(top:36),
                constraints: BoxConstraints(
                  maxWidth: screenWidth * 0.9,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    SizedBox(height: screenHeight * 0.05),
                    _buildSignInText(context),
                    SizedBox(height: screenHeight * 0.03),
                    _buildInputField(context, "Email Address", emailController, Icons.email_outlined, false),
                    SizedBox(height: screenHeight * 0.02),
                    _buildInputField(context, "Password", passwordController, Icons.lock_outline, true),
                    _buildForgotPassword(context),
                    SizedBox(height: screenHeight * 0.03),
                    _buildSignInButton(context, screenWidth),
                    SizedBox(height: screenHeight * 0.03),
                    _buildSignUpOption(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            "NAYA",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
              letterSpacing: 2.0,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Expense Tracking Made Easy",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInText(BuildContext context) {
    return Center(
      child: Text(
        "Sign In",
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInputField(BuildContext context, String label, TextEditingController controller, IconData icon, bool obscureText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
        ),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.4),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(
                color: Colors.black.withOpacity(0.2),
                width: 2,
              ),
            ),
            hintText: obscureText ? 'Enter Your Password' : 'Enter Your Email ID',
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        child: Text(
          "Forgot Password?",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context, double screenWidth) {
    return ElevatedButton(
      onPressed: loginUser,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        padding: EdgeInsets.symmetric(vertical: 20.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Sign in to Continue",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpOption(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/signUp');
          },
          child: Text(
            "Sign Up",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
