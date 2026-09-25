import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class CategoryLoadRequested extends CategoryEvent {}

class CategoryRefreshRequested extends CategoryEvent {}

class CategoryCreateRequested extends CategoryEvent {
  final String name;
  final String? description;

  const CategoryCreateRequested({required this.name, this.description});

  @override
  List<Object?> get props => [name, description];
}

class CategoryUpdateRequested extends CategoryEvent {
  final int id;
  final String name;
  final String? description;

  const CategoryUpdateRequested({
    required this.id,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, description];
}

class CategoryDeleteRequested extends CategoryEvent {
  final int id;

  const CategoryDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}
