// lib/features/catalog/cubits/kit/kit_cubit.dart

import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
//import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/models/kit_model.dart';
import '../../../../shared/services/api_service.dart';  // ← uses ApiService.LocalStorage
import 'kit_state.dart';

class KitCubit extends Cubit<KitState> {
  KitCubit() : super(const KitInitial());

  static const String _baseUrl  = 'https://talentokids.com/api';
  static const int    _pageSize = 10;

  Timer? _searchDebounce;

  // ── HTTP GET via dart:html ─────────────────────────────────────────────────
  Future<({int status, dynamic body})?> _get(String url) async {
    final token = await LocalStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      emit(const KitError('Unauthorized'));
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      final body = (response.body.isNotEmpty) ? json.decode(response.body) : null;
      return (status: response.statusCode, body: body);
    } on TimeoutException {
      return (status: 0, body: null);
    } catch (e) {
      // Catch any other connection errors
      return (status: 0, body: null);
    }
  }
  // ── Parse response ─────────────────────────────────────────────────────────
  ({List<KitModel> kits, bool hasMore}) _parse(dynamic body, int page) {
    if (body == null) return (kits: [], hasMore: false);

    List<dynamic> raw = [];
    bool hasMore = false;

    if (body is Map<String, dynamic>) {
      if (body.containsKey('content')) {
        raw = body['content'] as List<dynamic>;
        final totalPages = body['totalPages'] as int? ?? 1;
        hasMore = page + 1 < totalPages;
      } else if (body.containsKey('kits')) {
        raw = body['kits'] as List<dynamic>;
        hasMore = (body['hasMore'] as bool?) ?? false;
      }
    } else if (body is List) {
      raw = body;
    }

    return (
      kits: raw.map((e) => KitModel.fromJson(e as Map<String, dynamic>)).toList(),
      hasMore: hasMore,
    );
  }

  List<MindsetModel> _currentMindsets() {
    if (state is KitLoaded) return (state as KitLoaded).mindsets;
    if (state is KitLoadingMore) return (state as KitLoadingMore).mindsets;
    return [];
  }

  Future<List<MindsetModel>> _fetchMindsets() async {
    final res = await _get('$_baseUrl/mindsets');
    if (res == null || res.status != 200 || res.body == null) return [];
    try {
      return (res.body as List<dynamic>)
          .map((e) => MindsetModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── GET all kits ───────────────────────────────────────────────────────────
  Future<void> getAllKits({int page = 0}) async {
    if (page == 0) {
      emit(const KitLoading());
    } else {
      final prev = state is KitLoaded ? (state as KitLoaded).kits : <KitModel>[];
      emit(KitLoadingMore(List<KitModel>.from(prev), mindsets: _currentMindsets()));
    }

    final res = await _get('$_baseUrl/kits/?page=$page&size=$_pageSize');
    if (res == null) return;

    if (res.status == 200) {
      final parsed   = _parse(res.body, page);
      final mindsets = page == 0 ? await _fetchMindsets() : _currentMindsets();
      final prevKits = page == 0
          ? <KitModel>[]
          : (state is KitLoadingMore
              ? (state as KitLoadingMore).currentKits
              : <KitModel>[]);

      emit(KitLoaded(
        kits: [...prevKits, ...parsed.kits],
        currentPage: page,
        hasMore: parsed.hasMore,
        mindsets: mindsets,
      ));
    } else if (res.status == 401) {
      emit(const KitError('Unauthorized'));
    } else if (res.status == 0) {
      emit(const KitError('Request timed out. Please try again.'));
    } else {
      emit(KitError('Failed to load kits (${res.status})'));
    }
  }

  Future<void> loadNextPage() async {
    if (state is! KitLoaded) return;
    final current = state as KitLoaded;
    if (!current.hasMore) return;
    await getAllKits(page: current.currentPage + 1);
  }

  Future<void> getKitsByType(KitType type) async {
    emit(const KitLoading());
    final res = await _get('$_baseUrl/kits/type/${type.apiValue}');
    if (res == null) return;
    if (res.status == 200) {
      final parsed = _parse(res.body, 0);
      emit(KitLoaded(kits: parsed.kits, currentPage: 0, hasMore: false, mindsets: _currentMindsets()));
    } else if (res.status == 401) {
      emit(const KitError('Unauthorized'));
    } else if (res.status == 0) {
      emit(const KitError('Request timed out.'));
    } else {
      emit(KitError('Failed to filter by type (${res.status})'));
    }
  }

  Future<void> getKitsByMindset(int mindsetId) async {
    emit(const KitLoading());
    final res = await _get('$_baseUrl/kits/mindset/$mindsetId');
    if (res == null) return;
    if (res.status == 200) {
      final parsed = _parse(res.body, 0);
      emit(KitLoaded(kits: parsed.kits, currentPage: 0, hasMore: false, mindsets: _currentMindsets()));
    } else if (res.status == 401) {
      emit(const KitError('Unauthorized'));
    } else if (res.status == 0) {
      emit(const KitError('Request timed out.'));
    } else {
      emit(KitError('Failed to filter by mindset (${res.status})'));
    }
  }

  void searchKitsDebounced(String keyword) {
    _searchDebounce?.cancel();
    if (keyword.trim().isEmpty) {
      getAllKits(page: 0);
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 300), () => searchKits(keyword));
  }

  Future<void> searchKits(String keyword) async {
    if (keyword.trim().isEmpty) { await getAllKits(page: 0); return; }
    emit(const KitLoading());
    final encoded = Uri.encodeComponent(keyword);
    final res = await _get('$_baseUrl/kits/search?keyword=$encoded');
    if (res == null) return;
    if (res.status == 200) {
      final parsed = _parse(res.body, 0);
      emit(KitLoaded(kits: parsed.kits, currentPage: 0, hasMore: false, mindsets: _currentMindsets()));
    } else if (res.status == 401) {
      emit(const KitError('Unauthorized'));
    } else if (res.status == 0) {
      emit(const KitError('Request timed out.'));
    } else {
      emit(KitError('Search failed (${res.status})'));
    }
  }

  Future<void> getKitById(int id) async {
    emit(const KitLoading());
    final res = await _get('$_baseUrl/kits/$id');
    if (res == null) return;
    if (res.status == 200 && res.body != null) {
      emit(KitDetailsLoaded(KitModel.fromJson(res.body as Map<String, dynamic>)));
    } else if (res.status == 401) {
      emit(const KitError('Unauthorized'));
    } else if (res.status == 404) {
      emit(const KitError('Kit not found'));
    } else if (res.status == 0) {
      emit(const KitError('Request timed out.'));
    } else {
      emit(KitError('Failed to load kit (${res.status})'));
    }
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}