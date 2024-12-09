import '../../data/DataModel.dart';

abstract class CartState {}

class CartInitialState extends CartState {}

class CartLoadingState extends CartState {}

class CartLoadedState extends CartState {
  final CartModel cart;

  CartLoadedState({required this.cart});
}

class CartSuccessState extends CartState {
  final String message;

  CartSuccessState({required this.message});
}

class CartErrorState extends CartState {
  final String error;

  CartErrorState({required this.error});
}

class CartDeletingState extends CartState {}

class CartDeletedState extends CartState {}

class CartItemDeletingState extends CartState {}

class CartItemDeletedState extends CartState {
  final String message;

  CartItemDeletedState({required this.message});
}

class CartEmptyState extends CartState {}

class CartUpdatingState extends CartState {}

class CartUpdatedState extends CartState {
  final String message;

  CartUpdatedState({required this.message});
}

// cart_states.dart
class OrderPlacingState extends CartState {}

class OrderPlacedState extends CartState {
  final String message;
  OrderPlacedState({required this.message});
}




