import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/auth_storage.dart';
import '../../services/category_service.dart';

import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryService categoryService;
  final AuthStorage authStorage;

  CategoryBloc({required this.categoryService, required this.authStorage})
    : super(CategoryInitial()) {
    on<CategoryLoadRequested>(_loadCategories);
    on<CategoryRefreshRequested>(_loadCategories);
    on<CategoryCreateRequested>(_createCategory);
    on<CategoryUpdateRequested>(_updateCategory);
    on<CategoryDeleteRequested>(_deleteCategory);
  }

  Future<String> _getToken() async {
    final token = await authStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found.');
    }

    return token;
  }

  Future<void> _loadCategories(
    CategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());

    try {
      final token = await _getToken();

      final categories = await categoryService.getCategories(token: token);

      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _createCategory(
    CategoryCreateRequested event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      final token = await _getToken();

      await categoryService.createCategory(
        name: event.name,
        description: event.description,
        token: token,
      );

      emit(const CategoryOperationSuccess('Category created successfully.'));

      add(CategoryLoadRequested());
    } catch (e) {
      emit(CategoryError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _updateCategory(
    CategoryUpdateRequested event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      final token = await _getToken();

      await categoryService.updateCategory(
        id: event.id,
        name: event.name,
        description: event.description,
        token: token,
      );

      emit(const CategoryOperationSuccess('Category updated successfully.'));

      add(CategoryLoadRequested());
    } catch (e) {
      emit(CategoryError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _deleteCategory(
    CategoryDeleteRequested event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      final token = await _getToken();

      await categoryService.deleteCategory(id: event.id, token: token);

      emit(const CategoryOperationSuccess('Category deleted successfully.'));

      add(CategoryLoadRequested());
    } catch (e) {
      emit(CategoryError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
