import 'package:equatable/equatable.dart';
import '../../data/DataModel.dart';

abstract class ProductState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Initial state
class ProductInitialState extends ProductState {}

// Loading state
class ProductLoadingState extends ProductState {}

// Loaded state with ProductModel
class ProductLoadedState extends ProductState {
  final ProductModel productModel;

  ProductLoadedState(this.productModel);

  @override
  List<Object?> get props => [productModel];
}

// Error state
class ProductErrorState extends ProductState {
  final String error;

  ProductErrorState(this.error);

  @override
  List<Object?> get props => [error];
}
