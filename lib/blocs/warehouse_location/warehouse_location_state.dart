import 'package:equatable/equatable.dart';

import '../../models/warehouse_location_model.dart';

abstract class WarehouseLocationState extends Equatable {
  const WarehouseLocationState();

  @override
  List<Object?> get props => [];
}

class WarehouseLocationInitial extends WarehouseLocationState {}

class WarehouseLocationLoading extends WarehouseLocationState {}

class WarehouseLocationLoaded extends WarehouseLocationState {
  final List<WarehouseLocationModel> locations;

  const WarehouseLocationLoaded(this.locations);

  @override
  List<Object?> get props => [locations];
}

class WarehouseLocationCreating extends WarehouseLocationState {
  final List<WarehouseLocationModel> locations;

  const WarehouseLocationCreating(this.locations);

  @override
  List<Object?> get props => [locations];
}

class WarehouseLocationOperationSuccess extends WarehouseLocationState {
  final String message;

  const WarehouseLocationOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class WarehouseLocationError extends WarehouseLocationState {
  final String message;

  const WarehouseLocationError(this.message);

  @override
  List<Object?> get props => [message];
}
