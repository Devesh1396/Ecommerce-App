import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/DataModel.dart';
import '../../remote_api/api_helper.dart';
import '../../remote_api/urls.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final ApiService apiService;

  OrderBloc(this.apiService) : super(OrderInitialState()) {
    on<LoadOrdersEvent>(_onLoadOrders);
  }

  Future<void> _onLoadOrders(LoadOrdersEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoadingState());
    try {
      final response = await apiService.getAPI(
        url: Urls.get_order_URL,
        token: event.token,
      );

      if (response['status'] == true) {
        final orderModel = OrderModel.fromJson(response);
        emit(OrderLoadedState(orderModel: orderModel));
      } else {
        emit(OrderErrorState(error: response['message'] ?? "Failed to load orders."));
      }
    } catch (e) {
      emit(OrderErrorState(error: "Error fetching orders: $e"));
    }
  }
}
