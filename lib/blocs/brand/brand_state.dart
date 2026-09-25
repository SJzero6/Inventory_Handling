import 'package:equatable/equatable.dart';

import '../../models/brand_model.dart';

abstract class BrandState extends Equatable {
  const BrandState();

  @override
  List<Object?> get props => [];
}

class BrandInitial extends BrandState {}

class BrandLoading extends BrandState {}

class BrandLoaded extends BrandState {
  final List<BrandModel> brands;

  const BrandLoaded(this.brands);

  @override
  List<Object?> get props => [brands];
}

class BrandCreating extends BrandState {
  final List<BrandModel> brands;

  const BrandCreating(this.brands);

  @override
  List<Object?> get props => [brands];
}

class BrandOperationSuccess extends BrandState {
  final String message;

  const BrandOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class BrandError extends BrandState {
  final String message;

  const BrandError(this.message);

  @override
  List<Object?> get props => [message];
}
