import 'package:equatable/equatable.dart';

abstract class BrandEvent extends Equatable {
  const BrandEvent();

  @override
  List<Object?> get props => [];
}

class BrandLoadRequested extends BrandEvent {}

class BrandRefreshRequested extends BrandEvent {}

class BrandCreateRequested extends BrandEvent {
  final String name;

  const BrandCreateRequested({required this.name});

  @override
  List<Object?> get props => [name];
}

class BrandUpdateRequested extends BrandEvent {
  final int id;
  final String name;

  const BrandUpdateRequested({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class BrandDeleteRequested extends BrandEvent {
  final int id;

  const BrandDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}
