import 'package:equatable/equatable.dart';

import '../../models/unit_model.dart';

abstract class UnitState extends Equatable {
  const UnitState();

  @override
  List<Object?> get props => [];
}

class UnitInitial extends UnitState {}

class UnitLoading extends UnitState {}

class UnitLoaded extends UnitState {
  final List<UnitModel> units;

  const UnitLoaded(this.units);

  @override
  List<Object?> get props => [units];
}

class UnitCreating extends UnitState {
  final List<UnitModel> units;

  const UnitCreating(this.units);

  @override
  List<Object?> get props => [units];
}

class UnitOperationSuccess extends UnitState {
  final String message;

  const UnitOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class UnitError extends UnitState {
  final String message;

  const UnitError(this.message);

  @override
  List<Object?> get props => [message];
}
