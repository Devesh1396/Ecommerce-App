import 'dart:async';
import 'package:ecom_app/bloc/product_bloc/product_event.dart';
import 'package:ecom_app/bloc/product_bloc/product_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/DataModel.dart';
import '../../remote_api/api_helper.dart';
import '../../remote_api/urls.dart';


class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ApiService apiService;

  ProductBloc(this.apiService) : super(ProductInitialState()) {
    on<LoadProductsEvent>(_onLoadProducts);
  }

  // Handle the LoadProductsEvent
  Future<void> _onLoadProducts(
      LoadProductsEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoadingState()); // Emit loading state

    try {
      // Retrieve token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        emit(ProductErrorState("User is not authenticated. Token is missing."));
        return;
      }

      // Make API call
      final response = await apiService.postAPI(
        url: Urls.product_URL, // Your product URL
        token: token,
      );

      // Convert response to ProductModel
      final productModel = ProductModel.fromJson(response);

      // Emit loaded state
      emit(ProductLoadedState(productModel));
    } catch (e) {
      emit(ProductErrorState("Failed to fetch products: $e"));
    }
  }
}
