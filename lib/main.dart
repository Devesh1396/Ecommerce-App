import 'package:ecom_app/OrdersUI.dart';
import 'package:ecom_app/SignIn_Ui.dart';
import 'package:ecom_app/SignUp_Ui.dart';
import 'package:ecom_app/SplashUi.dart';
import 'package:ecom_app/bloc/orders_bloc/order_bloc.dart';
import 'package:ecom_app/remote_api/api_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/cart_bloc/cart_bloc.dart';
import 'bloc/product_bloc/product_bloc.dart';
import 'bloc/theme_bloc/themebloc.dart';
import 'bloc/user/bloc_code.dart';
import 'bloc/user/states.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(ApiService()),
        ),
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc(),
        ),
        BlocProvider<ProductBloc>(
          create: (context) => ProductBloc(ApiService()),
        ),
        BlocProvider<CartBloc>(
          create: (context) => CartBloc(ApiService()),
        ),
        BlocProvider<OrderBloc>(
          create: (context) => OrderBloc(ApiService()),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserLoggedOutState) {
              // Navigate to SignIn screen on logout
              navigatorKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => SigninUi()),
                    (route) => false, // Remove all previous routes
              );
            }
          },
          child: MaterialApp(
            title: 'Naya eCommerce',
            theme: themeState.themeData,
            navigatorKey: navigatorKey, // Assign the global navigator key
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            routes: {
              '/': (context) => SplashUI(),
              '/signUp': (context) => SignUpUi(),
            },
          ),
        );
      },
    );
  }
}


