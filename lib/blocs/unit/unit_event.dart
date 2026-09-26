import 'package:equatable/equatable.dart';

abstract class UnitEvent extends Equatable {
  const UnitEvent();

  @override
  List<Object?> get props => [];
}

class UnitLoadRequested extends UnitEvent {}

class UnitRefreshRequested extends UnitEvent {}

class UnitCreateRequested extends UnitEvent {
  final String name;
  final String shortName;

  const UnitCreateRequested({required this.name, required this.shortName});

  @override
  List<Object?> get props => [name, shortName];
}

class UnitUpdateRequested extends UnitEvent {
  final int id;
  final String name;
  final String shortName;

  const UnitUpdateRequested({
    required this.id,
    required this.name,
    required this.shortName,
  });

  @override
  List<Object?> get props => [id, name, shortName];
}

class UnitDeleteRequested extends UnitEvent {
  final int id;

  const UnitDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}
