import 'package:equatable/equatable.dart';

abstract class SupplierEvent extends Equatable {
  const SupplierEvent();

  @override
  List<Object?> get props => [];
}

class SupplierLoadRequested extends SupplierEvent {}

class SupplierRefreshRequested extends SupplierEvent {}

class SupplierCreateRequested extends SupplierEvent {
  final Map<String, dynamic> data;

  const SupplierCreateRequested(this.data);

  @override
  List<Object?> get props => [data];
}

class SupplierUpdateRequested extends SupplierEvent {
  final int id;
  final Map<String, dynamic> data;

  const SupplierUpdateRequested(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}

class SupplierDeleteRequested extends SupplierEvent {
  final int id;

  const SupplierDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}
