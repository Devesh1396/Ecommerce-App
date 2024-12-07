import '../../data/DataModel.dart';

abstract class OrderState {}

class OrderInitialState extends OrderState {}

class OrderLoadingState extends OrderState {}

class OrderLoadedState extends OrderState {
  final OrderModel orderModel;

  OrderLoadedState({required this.orderModel});
}

class OrderErrorState extends OrderState {
  final String error;

  OrderErrorState({required this.error});
}
