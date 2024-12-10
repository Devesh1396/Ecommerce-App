import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

ValueNotifier<num> cartItemCountNotifier = ValueNotifier<num>(0);

void updateCartItemCount(List<dynamic> cartData) {
  num newCount = cartData.length;
  cartItemCountNotifier.value = newCount;
}

ValueNotifier<num> getCartItemCountNotifier() {
  return cartItemCountNotifier;
}

void showToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.TOP,
    backgroundColor: Colors.black,
    textColor: Colors.white,
  );
}