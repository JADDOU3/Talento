import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/models/kit_model.dart';
import '../../shared/services/api_result.dart';
import '../../shared/services/api_service.dart';
import 'kit_state.dart';

/// Kit details page cubit — loads a single kit via `GET /api/kits/{id}`.
class KitCubit extends Cubit<KitState> {
  KitCubit() : super(const KitInitial());

  Future<void> getKitById(int id) async {
    emit(const KitLoading());

    final result = await ApiService.getWithStatus('/kits/$id');

    if (result.isNetworkFailure) {
      emit(const KitError('Network error. Please check your connection.'));
      return;
    }
    if (result.isUnauthorized) {
      emit(const KitError('Unauthorized'));
      return;
    }
    if (result.isNotFound) {
      emit(const KitError('Kit not found'));
      return;
    }
    if (!result.isSuccess) {
      emit(KitError(_messageFromResult(result, 'Failed to load kit')));
      return;
    }

    try {
      final body = result.body;
      if (body is! Map<String, dynamic>) {
        emit(const KitError('Invalid kit response from server'));
        return;
      }
      emit(KitLoaded(KitModel.fromJson(body)));
    } catch (_) {
      emit(const KitError('Could not parse kit data'));
    }
  }

  String _messageFromResult(ApiResult result, String fallback) {
    final raw = result.rawText;
    if (raw != null && raw.trim().isNotEmpty) {
      final msg = ApiService.decodeResponseBody(raw)['message'];
      if (msg != null && msg.toString().trim().isNotEmpty) {
        return msg.toString().trim();
      }
    }
    return '$fallback (${result.status})';
  }
}
