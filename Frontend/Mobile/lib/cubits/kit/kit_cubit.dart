import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/kit/kit_service.dart';
import 'kit_state.dart';

enum _KitRequestType {
  all,
  type,
  search,
}

class KitCubit extends Cubit<KitState> {
  final KitService _kitService;

  KitCubit(this._kitService) : super(const KitInitial());

  static const int _defaultPageSize = 10;

  int _currentPage = 0;
  int _pageSize = _defaultPageSize;
  _KitRequestType _currentRequestType = _KitRequestType.all;
  String? _currentType;
  String? _currentKeyword;

  Future<void> getAllKits({int page = 0, int size = _defaultPageSize}) async {
    emit(const KitLoading());

    _currentRequestType = _KitRequestType.all;
    _currentType = null;
    _currentKeyword = null;
    _currentPage = page;
    _pageSize = size;

    try {
      final result = await _kitService.getAllKitsPage(
        page: page,
        size: size,
      );

      _currentPage = result.page;

      emit(
        KitLoaded(
          result.kits,
          hasMore: !result.isLast,
          currentPage: result.page,
        ),
      );
    } catch (e) {
      emit(KitError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> getKitsByType(String type) async {
    emit(const KitLoading());

    _currentRequestType = _KitRequestType.type;
    _currentType = type;
    _currentKeyword = null;
    _currentPage = 0;
    _pageSize = _defaultPageSize;

    try {
      final result = await _kitService.getKitsByTypePage(
        type,
        page: 0,
        size: _pageSize,
      );

      _currentPage = result.page;

      emit(
        KitLoaded(
          result.kits,
          hasMore: !result.isLast,
          currentPage: result.page,
        ),
      );
    } catch (e) {
      emit(KitError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> searchKits(String keyword) async {
    final trimmedKeyword = keyword.trim();

    if (trimmedKeyword.isEmpty) {
      await getAllKits();
      return;
    }

    emit(const KitLoading());

    _currentRequestType = _KitRequestType.search;
    _currentType = null;
    _currentKeyword = trimmedKeyword;
    _currentPage = 0;
    _pageSize = _defaultPageSize;

    try {
      final result = await _kitService.searchKitsPage(
        trimmedKeyword,
        page: 0,
        size: _pageSize,
      );

      _currentPage = result.page;

      emit(
        KitLoaded(
          result.kits,
          hasMore: !result.isLast,
          currentPage: result.page,
        ),
      );
    } catch (e) {
      emit(KitError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> loadMoreKits() async {
    final currentState = state;

    if (currentState is! KitLoaded) return;
    if (!currentState.hasMore || currentState.isLoadingMore) return;

    emit(
      currentState.copyWith(
        isLoadingMore: true,
        clearLoadMoreError: true,
      ),
    );

    try {
      final nextPage = _currentPage + 1;
      final result = await _fetchCurrentPage(nextPage);

      _currentPage = result.page;

      emit(
        KitLoaded(
          [
            ...currentState.kits,
            ...result.kits,
          ],
          hasMore: !result.isLast,
          currentPage: result.page,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          isLoadingMore: false,
          loadMoreError: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<KitPageResult> _fetchCurrentPage(int page) {
    switch (_currentRequestType) {
      case _KitRequestType.all:
        return _kitService.getAllKitsPage(
          page: page,
          size: _pageSize,
        );

      case _KitRequestType.type:
        final type = _currentType;

        if (type == null || type.isEmpty) {
          return _kitService.getAllKitsPage(
            page: page,
            size: _pageSize,
          );
        }

        return _kitService.getKitsByTypePage(
          type,
          page: page,
          size: _pageSize,
        );

      case _KitRequestType.search:
        final keyword = _currentKeyword;

        if (keyword == null || keyword.isEmpty) {
          return _kitService.getAllKitsPage(
            page: page,
            size: _pageSize,
          );
        }

        return _kitService.searchKitsPage(
          keyword,
          page: page,
          size: _pageSize,
        );
    }
  }

  Future<void> getKitById(int id) async {
    emit(const KitLoading());

    try {
      final kit = await _kitService.getKitById(id);
      emit(KitDetailsLoaded(kit));
    } catch (e) {
      emit(KitError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}