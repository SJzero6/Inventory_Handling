import 'package:equatable/equatable.dart';

import '../../models/supplier_model.dart';

abstract class SupplierState extends Equatable {
  const SupplierState();

  @override
  List<Object?> get props => [];
}

class SupplierInitial extends SupplierState {}

class SupplierLoading extends SupplierState {}

class SupplierLoaded extends SupplierState {
  final List<SupplierModel> suppliers;

  const SupplierLoaded(this.suppliers);

  @override
  List<Object?> get props => [suppliers];
}

class SupplierCreating extends SupplierState {
  final List<SupplierModel> suppliers;

  const SupplierCreating(this.suppliers);

  @override
  List<Object?> get props => [suppliers];
}

class SupplierOperationSuccess extends SupplierState {
  final String message;

  const SupplierOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class SupplierError extends SupplierState {
  final String message;

  const SupplierError(this.message);

  @override
  List<Object?> get props => [message];
}
