import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Event to load products
class LoadProductsEvent extends ProductEvent {}
