import 'package:equatable/equatable.dart';

abstract class WarehouseEvent extends Equatable {
  const WarehouseEvent();

  @override
  List<Object?> get props => [];
}

class WarehouseLoadRequested extends WarehouseEvent {}

class WarehouseRefreshRequested extends WarehouseEvent {}

class WarehouseCreateRequested extends WarehouseEvent {
  final Map<String, dynamic> data;

  const WarehouseCreateRequested(this.data);

  @override
  List<Object?> get props => [data];
}

class WarehouseUpdateRequested extends WarehouseEvent {
  final int id;
  final Map<String, dynamic> data;

  const WarehouseUpdateRequested(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}

class WarehouseDeleteRequested extends WarehouseEvent {
  final int id;

  const WarehouseDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}
