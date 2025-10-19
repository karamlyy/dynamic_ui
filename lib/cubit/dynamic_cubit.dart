import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/dynamic_repository.dart';
import 'dynamic_state.dart';

class DynamicCubit extends Cubit<DynamicState> {
  final DynamicRepository repository;
  DynamicCubit({required this.repository}) : super(DynamicInitial());

  Future<void> loadForUser(int userId) async {
    emit(DynamicLoading());
    try {
      final sections = await repository.fetchSectionsForUser(userId);
      final selected = sections.isNotEmpty ? sections.first.id : null;
      emit(DynamicLoaded(sections: sections, selectedSectionId: selected));
    } catch (e) {
      emit(DynamicError(message: e.toString()));
    }
  }

  void selectSection(String? sectionId) {
    final current = state;
    if (current is DynamicLoaded) {
      emit(DynamicLoaded(sections: current.sections, selectedSectionId: sectionId));
    }
  }
}