// lib/cubits/kit/kit_cubit.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/models/kit_model.dart';
import '../../shared/services/api_service.dart';
import 'dart:async';

// States
abstract class KitState {}

class KitInitial extends KitState {}

class KitLoading extends KitState {}

class KitLoaded extends KitState {
  final List<KitModel> kits;
  final int currentPage;
  final int totalPages;
  final int totalElements;
  final bool hasMore;

  KitLoaded({
    required this.kits,
    this.currentPage = 0,
    this.totalPages = 1,
    this.totalElements = 0,
    this.hasMore = false,
  });
}

class KitLoadingMore extends KitState {
  final List<KitModel> currentKits;
  KitLoadingMore(this.currentKits);
}

class KitLoadedSingle extends KitState {
  final KitModel kit;
  KitLoadedSingle(this.kit);
}

class KitError extends KitState {
  final String message;
  KitError(this.message);
}

// Cubit
class KitCubit extends Cubit<KitState> {
  Timer? _debounceTimer;

  KitCubit() : super(KitInitial());

  // Get all kits with pagination
  Future<void> getAllKits({int page = 0, int size = 10, String sort = 'createdAt,desc'}) async {
    emit(KitLoading());
    try {
      final response = await ApiService.getWithStatus('/kits/?page=$page&size=$size&sort=$sort');

      if (response.isSuccess && response.body is Map<String, dynamic>) {
        final data = response.body as Map<String, dynamic>;
        final content = data['content'] as List<dynamic>? ?? [];
        final kits = content.map((json) => KitModel.fromJson(json)).toList();
        final totalPages = data['totalPages'] ?? 1;
        final hasMore = page + 1 < totalPages;

        emit(KitLoaded(
          kits: kits,
          currentPage: page,
          totalPages: totalPages,
          totalElements: data['totalElements'] ?? 0,
          hasMore: hasMore,
        ));
      } else if (response.isUnauthorized) {
        emit(KitError('Please login to view kits'));
      } else if (response.isNotFound) {
        emit(KitError('No kits found'));
      } else {
        final errorMessage = ApiService.userFacingMessage(
            ApiService.decodeResponseBody(response.rawText)
        );
        emit(KitError(errorMessage.isNotEmpty ? errorMessage : 'Failed to load kits'));
      }
    } catch (e) {
      emit(KitError(e.toString()));
    }
  }

  // Load next page (for pagination)
  Future<void> loadNextPage() async {
    final currentState = state;
    if (currentState is KitLoaded && currentState.hasMore) {
      final nextPage = currentState.currentPage + 1;
      try {
        emit(KitLoadingMore(currentState.kits));

        final response = await ApiService.getWithStatus(
            '/kits/?page=$nextPage&size=10&sort=createdAt,desc'
        );

        if (response.isSuccess && response.body is Map<String, dynamic>) {
          final data = response.body as Map<String, dynamic>;
          final content = data['content'] as List<dynamic>? ?? [];
          final newKits = content.map((json) => KitModel.fromJson(json)).toList();
          final allKits = [...currentState.kits, ...newKits];
          final totalPages = data['totalPages'] ?? currentState.totalPages;
          final hasMore = nextPage + 1 < totalPages;

          emit(KitLoaded(
            kits: allKits,
            currentPage: nextPage,
            totalPages: totalPages,
            totalElements: data['totalElements'] ?? currentState.totalElements,
            hasMore: hasMore,
          ));
        }
      } catch (e) {
        // Revert to previous state if load fails
        emit(currentState);
        if (kDebugMode) debugPrint('Failed to load more kits: $e');
      }
    }
  }

  // Get a single kit by ID
  Future<void> getKitById(int kitId) async {
    emit(KitLoading());
    try {
      final response = await ApiService.getWithStatus('/kits/$kitId');

      if (response.isSuccess && response.body is Map<String, dynamic>) {
        final kit = KitModel.fromJson(response.body as Map<String, dynamic>);
        emit(KitLoadedSingle(kit));
      } else if (response.isNotFound) {
        emit(KitError('Kit not found'));
      } else if (response.isUnauthorized) {
        emit(KitError('Please login to view kit details'));
      } else {
        final errorMessage = ApiService.userFacingMessage(
            ApiService.decodeResponseBody(response.rawText)
        );
        emit(KitError(errorMessage.isNotEmpty ? errorMessage : 'Failed to load kit details'));
      }
    } catch (e) {
      emit(KitError(e.toString()));
    }
  }

  // Get kits by type (DISCOVERY, HOBBY, DEVELOPMENT)
  Future<void> getKitsByType(String type, {int page = 0, int size = 10}) async {
    emit(KitLoading());
    try {
      final response = await ApiService.getWithStatus(
          '/kits/type/$type?page=$page&size=$size'
      );

      if (response.isSuccess && response.body is Map<String, dynamic>) {
        final data = response.body as Map<String, dynamic>;
        final content = data['content'] as List<dynamic>? ?? [];
        final kits = content.map((json) => KitModel.fromJson(json)).toList();
        final totalPages = data['totalPages'] ?? 1;
        final hasMore = page + 1 < totalPages;

        emit(KitLoaded(
          kits: kits,
          currentPage: page,
          totalPages: totalPages,
          totalElements: data['totalElements'] ?? 0,
          hasMore: hasMore,
        ));
      } else if (response.status == 400) {
        emit(KitError('Invalid kit type. Must be DISCOVERY, HOBBY, or DEVELOPMENT'));
      } else {
        final errorMessage = ApiService.userFacingMessage(
            ApiService.decodeResponseBody(response.rawText)
        );
        emit(KitError(errorMessage.isNotEmpty ? errorMessage : 'Failed to load kits by type'));
      }
    } catch (e) {
      emit(KitError(e.toString()));
    }
  }

  // Get kits by mindset
  Future<void> getKitsByMindset(int mindsetId, {int page = 0, int size = 10}) async {
    emit(KitLoading());
    try {
      final response = await ApiService.getWithStatus(
          '/kits/mindset/$mindsetId?page=$page&size=$size'
      );

      if (response.isSuccess && response.body is Map<String, dynamic>) {
        final data = response.body as Map<String, dynamic>;
        final content = data['content'] as List<dynamic>? ?? [];
        final kits = content.map((json) => KitModel.fromJson(json)).toList();
        final totalPages = data['totalPages'] ?? 1;
        final hasMore = page + 1 < totalPages;

        emit(KitLoaded(
          kits: kits,
          currentPage: page,
          totalPages: totalPages,
          totalElements: data['totalElements'] ?? 0,
          hasMore: hasMore,
        ));
      } else {
        final errorMessage = ApiService.userFacingMessage(
            ApiService.decodeResponseBody(response.rawText)
        );
        emit(KitError(errorMessage.isNotEmpty ? errorMessage : 'Failed to load kits by mindset'));
      }
    } catch (e) {
      emit(KitError(e.toString()));
    }
  }

  // Search kits with debounce
  Future<void> searchKitsDebounced(String keyword) async {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    if (keyword.isEmpty) {
      getAllKits(page: 0);
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchKits(keyword);
    });
  }

  // Direct search
  Future<void> _searchKits(String keyword) async {
    emit(KitLoading());
    try {
      final response = await ApiService.getWithStatus(
          '/kits/search?keyword=$keyword&page=0&size=10'
      );

      if (response.isSuccess && response.body is Map<String, dynamic>) {
        final data = response.body as Map<String, dynamic>;
        final content = data['content'] as List<dynamic>? ?? [];
        final kits = content.map((json) => KitModel.fromJson(json)).toList();

        emit(KitLoaded(
          kits: kits,
          currentPage: 0,
          totalPages: data['totalPages'] ?? 1,
          totalElements: data['totalElements'] ?? 0,
          hasMore: false,
        ));
      } else {
        final errorMessage = ApiService.userFacingMessage(
            ApiService.decodeResponseBody(response.rawText)
        );
        emit(KitError(errorMessage.isNotEmpty ? errorMessage : 'Failed to search kits'));
      }
    } catch (e) {
      emit(KitError(e.toString()));
    }
  }

  // Clear search and reload all kits
  void clearSearch() {
    _debounceTimer?.cancel();
    getAllKits(page: 0);
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}