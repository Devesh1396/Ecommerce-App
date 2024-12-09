import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/DataModel.dart';
import '../../remote_api/api_helper.dart';
import '../../remote_api/urls.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final ApiService apiService;

  CartBloc(this.apiService) : super(CartInitialState()) {
    on<AddToCartEvent>(_onAddToCart);
    on<LoadCartEvent>(_ViewCart);
    on<DeleteCartItemEvent>(_deleteCartAllItem);
    on<UpdateCartQtyEvent>(_onUpdateQty);
    on<DecrementCartQtyEvent>(_onDecrementQty);
    on<PlaceOrderEvent>(_onPlaceOrder);
    on<DeleteItemEvent>(_deleteCartItem);
  }

  Future<void> _onAddToCart(AddToCartEvent event, Emitter<CartState> emit) async {
    emit(CartLoadingState());
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await apiService.postAPI(
        url: Urls.add_cart_URL, // Replace with your cart URL
        body: {
          "product_id": event.productId,
          "quantity": 1, // Default quantity
        },
        token: token,
      );

      if (response['status'] == "true") {    // Note: status is in string format
        emit(CartSuccessState(message: response['message']));
      } else {
        emit(CartErrorState(error: response['message']));
      }
    } catch (e) {
      emit(CartErrorState(error: "Failed to add product to cart: $e"));
    }
  }

  Future<void> _ViewCart(LoadCartEvent event, Emitter<CartState> emit) async {
    emit(CartLoadingState());
    try {
      // Fetch the cart data using the token passed in the event
      final response = await apiService.getAPI(
        url: Urls.view_cart_URL, // Replace with your actual cart endpoint
        token: event.token, // Use token from event
      );

      if (response['status'] == true) {
        // Parse the response into CartModel
        CartModel cart = CartModel.fromJson(response);
        emit(CartLoadedState(cart: cart));
      } else if (response['status'] == false && response['data']==null)
        {
          emit(CartEmptyState());
        }
      else {
        emit(CartErrorState(error: response['message'] ?? "Failed to load cart"));
      }
    } catch (e) {
      emit(CartErrorState(error: e.toString()));
    }
  }

  Future<void> _deleteCartAllItem(DeleteCartItemEvent event, Emitter<CartState> emit) async {
    emit(CartDeletingState());
    try {
      final response = await apiService.postAPI(
        url: Urls.delete_cart_URL,
        token: event.token,
        body: {
          "cart_id": event.cartId,
        },
      );

      if (response['status'] == true) {
        emit(CartDeletedState());
      } else {
        emit(CartErrorState(error: response['message'] ?? "Failed to delete item"));
      }
    } catch (e) {
      emit(CartErrorState(error: e.toString()));
    }
  }

  Future<void> _deleteCartItem(DeleteItemEvent event, Emitter<CartState> emit) async {
    emit(CartItemDeletingState());
    try {
      final response = await apiService.postAPI(
        url: Urls.delete_cart_URL,
        token: event.token,
        body: {
          "cart_id": event.cartId,
        },
      );

      if (response['status'] == true) {
        final cartResponse = await apiService.getAPI(
          url: Urls.view_cart_URL,
          token: event.token,
        );

        if (cartResponse['status'] == true) {
          // Parse the API response into the CartModel
          final cart = CartModel.fromJson(cartResponse);

          // Emit CartUpdatedState for UI-specific reactions (e.g., success messages)
          emit(CartItemDeletedState(message: response['message'] ?? "Failed to Delete Product from Cart."));

          // Emit CartLoadedState with the updated cart data to refresh the UI
          emit(CartLoadedState(cart: cart));
        } else if (cartResponse['status'] == false && cartResponse['data']==null)
        {
          emit(CartItemDeletedState(message: response['message'] ?? "Failed to Delete Product from Cart."));
          emit(CartEmptyState());
        } else {
          emit(CartErrorState(error: "Failed to reload cart after deleting."));
        }
      } else {
        emit(CartErrorState(error: response['message']));
      }
    } catch (e) {
      emit(CartErrorState(error: "Failed to decrement quantity: $e"));
    }
  }

  Future<void> _onUpdateQty(UpdateCartQtyEvent event, Emitter<CartState> emit) async {
    emit(CartUpdatingState()); // Emit CartUpdatingState to indicate progress
    try {
      // Call the API to update the quantity
      final response = await apiService.postAPI(
        url: Urls.add_cart_URL,
        body: {
          "product_id": event.productId,
          "quantity": event.quantity,
        },
        token: event.token,
      );

      if (response['status'] == true) {
        // Reload cart data explicitly after updating
        final cartResponse = await apiService.getAPI(
          url: Urls.view_cart_URL,
          token: event.token,
        );

        if (cartResponse['status'] == true) {
          // Parse the API response into the CartModel
          final cart = CartModel.fromJson(cartResponse);

          // Emit CartUpdatedState for UI-specific reactions (e.g., success messages)
          emit(CartUpdatedState(message: response['message'] ?? "Quantity updated successfully."));

          // Emit CartLoadedState with the updated cart data to refresh the UI
          emit(CartLoadedState(cart: cart));
        } else {
          emit(CartErrorState(error: "Failed to reload cart after update."));
        }
      } else {
        emit(CartErrorState(error: response['message'] ?? "Failed to update quantity."));
      }
    } catch (e) {
      emit(CartErrorState(error: "An unexpected error occurred: $e"));
    }
  }

  Future<void> _onDecrementQty(DecrementCartQtyEvent event, Emitter<CartState> emit) async {
    emit(CartUpdatingState()); // Show updating state for decrement operation
    try {
      final response = await apiService.postAPI(
        url: Urls.decrement_URL, // Replace with your decrement cart URL
        body: {
          "product_id": event.productId, // Product ID to decrement
          "quantity": event.quantity,   // Quantity to decrement
        },
        token: event.token,
      );

      if (response['status'] == true) {
        final cartResponse = await apiService.getAPI(
          url: Urls.view_cart_URL,
          token: event.token,
        );

        if (cartResponse['status'] == true) {
          // Parse the API response into the CartModel
          final cart = CartModel.fromJson(cartResponse);

          // Emit CartUpdatedState for UI-specific reactions (e.g., success messages)
          emit(CartUpdatedState(message: response['message'] ?? "Quantity updated successfully."));

          // Emit CartLoadedState with the updated cart data to refresh the UI
          emit(CartLoadedState(cart: cart));
        } else {
          emit(CartErrorState(error: "Failed to reload cart after update."));
        }
      } else {
        emit(CartErrorState(error: response['message']));
      }
    } catch (e) {
      emit(CartErrorState(error: "Failed to decrement quantity: $e"));
    }
  }

  // cart_bloc.dart
  Future<void> _onPlaceOrder(PlaceOrderEvent event, Emitter<CartState> emit) async {
    emit(OrderPlacingState());

    try {

      final response = await apiService.postAPI(
        url: Urls.create_order_URL,
        token: event.token,
      );

      if (response['status'] == true) {
        emit(OrderPlacedState(message: response['message']));
      } else {
        emit(CartErrorState(error: response['message'] ?? "Failed to place order"));
      }
    } catch (e) {
      emit(CartErrorState(error: "Failed to place order: $e"));
    }
  }


}
