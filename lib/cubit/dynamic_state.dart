import 'package:equatable/equatable.dart';
import '../models/dynamic_models.dart';

abstract class DynamicState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DynamicInitial extends DynamicState {}

class DynamicLoading extends DynamicState {}

class DynamicLoaded extends DynamicState {
  final List<DynamicSection> sections;
  final String? selectedSectionId;

  DynamicLoaded({required this.sections, this.selectedSectionId});

  DynamicSection? get selectedSection {
    if (sections.isEmpty) return null;
    final id = selectedSectionId ?? sections.first.id;
    return sections.firstWhere((s) => s.id == id, orElse: () => sections.first);
  }

  @override
  List<Object?> get props => [sections, selectedSectionId];
}

class DynamicError extends DynamicState {
  final String message;
  DynamicError({required this.message});

  @override
  List<Object?> get props => [message];
}