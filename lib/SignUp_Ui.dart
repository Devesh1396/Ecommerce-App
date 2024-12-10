import 'package:ecom_app/MainApp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_colors.dart';
import 'bloc/user/bloc_code.dart';
import 'bloc/user/events.dart';
import 'bloc/user/states.dart';
import 'customback_button.dart';
import 'data/data_helper.dart';

class SignUpUi extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUpUi> {
  final TextEditingController unameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  void registerUser() {
    String username = unameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String mobile = mobileController.text;

    // Dispatch the AddUserEvent to the UserBloc
    context.read<UserBloc>().add(
      RegisterUserEvent(name: username, email: email, password: password, mobileNumber: mobile),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Using MediaQuery for responsive sizing
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: customBackWidget2(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: screenWidth * 0.9,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  SizedBox(height: screenHeight * 0.03),
                  _buildTextFieldWithLabel(
                    label: "Name",
                    controller: unameController,
                    hintText: "Enter Your Name",
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildTextFieldWithLabel(
                    label: "Email",
                    controller: emailController,
                    hintText: "Enter Your Email ID",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildTextFieldWithLabel(
                    label: "Password",
                    controller: passwordController,
                    hintText: "Enter Your Password",
                    obscureText: true,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildTextFieldWithLabel(
                    label: "Mobile Number",
                    controller: mobileController,
                    hintText: "Enter Your Mobile Number",
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  _buildSignUpButton(context, screenWidth),
                  _blocListener(context),
                ],
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
            "Create Account",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Fill your information below or register with your social account",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 17,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldWithLabel({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
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
                color: Colors.black.withOpacity(0.5),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton(BuildContext context, double screenWidth) {
    return ElevatedButton(
      onPressed: registerUser,
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
            "Create My Account",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'customFont',
            ),
          ),
        ],
      ),
    );
  }

  Widget _blocListener(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserLoadingState) {
          // Show loading indicator
        } else if (state is UserSessionLoadedState) {
          showToast("Registration Successful");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        } else if (state is UserErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(), // Placeholder
    );
  }
}
