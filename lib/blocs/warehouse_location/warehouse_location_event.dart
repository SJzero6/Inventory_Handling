import 'package:equatable/equatable.dart';

abstract class WarehouseLocationEvent extends Equatable {
  const WarehouseLocationEvent();

  @override
  List<Object?> get props => [];
}

class WarehouseLocationLoadRequested extends WarehouseLocationEvent {}

class WarehouseLocationRefreshRequested extends WarehouseLocationEvent {}

class WarehouseLocationCreateRequested extends WarehouseLocationEvent {
  final Map<String, dynamic> data;

  const WarehouseLocationCreateRequested(this.data);

  @override
  List<Object?> get props => [data];
}

class WarehouseLocationUpdateRequested extends WarehouseLocationEvent {
  final int id;
  final Map<String, dynamic> data;

  const WarehouseLocationUpdateRequested(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}

class WarehouseLocationDeleteRequested extends WarehouseLocationEvent {
  final int id;

  const WarehouseLocationDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}
