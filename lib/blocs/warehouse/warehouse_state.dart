import 'package:equatable/equatable.dart';

import '../../models/warehouse_model.dart';

abstract class WarehouseState extends Equatable {
  const WarehouseState();

  @override
  List<Object?> get props => [];
}

class WarehouseInitial extends WarehouseState {}

class WarehouseLoading extends WarehouseState {}

class WarehouseLoaded extends WarehouseState {
  final List<WarehouseModel> warehouses;

  const WarehouseLoaded(this.warehouses);

  @override
  List<Object?> get props => [warehouses];
}

class WarehouseCreating extends WarehouseState {
  final List<WarehouseModel> warehouses;

  const WarehouseCreating(this.warehouses);

  @override
  List<Object?> get props => [warehouses];
}

class WarehouseOperationSuccess extends WarehouseState {
  final String message;

  const WarehouseOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class WarehouseError extends WarehouseState {
  final String message;

  const WarehouseError(this.message);

  @override
  List<Object?> get props => [message];
}
