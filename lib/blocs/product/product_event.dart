import 'package:equatable/equatable.dart';

import '../../models/product_request.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class ProductLoadRequested extends ProductEvent {}

class ProductRefreshRequested extends ProductEvent {}

class ProductCreateRequested extends ProductEvent {
  final ProductRequest request;

  const ProductCreateRequested(this.request);

  @override
  List<Object?> get props => [request];
}

class ProductUpdateRequested extends ProductEvent {
  final int id;
  final ProductRequest request;

  const ProductUpdateRequested({required this.id, required this.request});

  @override
  List<Object?> get props => [id, request];
}

class ProductDeleteRequested extends ProductEvent {
  final int id;

  const ProductDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}
