abstract class CartEvent {}

class AddToCartEvent extends CartEvent {
  final String productId;

  AddToCartEvent({required this.productId});
}

class LoadCartEvent extends CartEvent {
  final String token;

  LoadCartEvent({required this.token});
}

//Whole Cart
class DeleteCartItemEvent extends CartEvent {
  final int cartId;
  final String token;

  DeleteCartItemEvent({required this.cartId, required this.token});
}

//Single Item
class DeleteItemEvent extends CartEvent {
  final int cartId;
  final String token;

  DeleteItemEvent({required this.cartId, required this.token});
}

class UpdateCartQtyEvent extends CartEvent {
  final String productId;
  final int quantity;
  final String token;

  UpdateCartQtyEvent({required this.productId, required this.quantity, required this.token});
}

class DecrementCartQtyEvent extends CartEvent {
  final String productId;
  final int quantity;
  final String token;

  DecrementCartQtyEvent({required this.productId, required this.quantity, required this.token});
}

class PlaceOrderEvent extends CartEvent {

  final String token;

  PlaceOrderEvent({required this.token});

}
