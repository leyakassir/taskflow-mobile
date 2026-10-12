import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/core/constants/api_constants.dart';
import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/network/dio_client.dart';
import 'package:taskflow_mobile/features/realtime/domain/entities/realtime_event.dart';

final realtimeRemoteDataSourceProvider = Provider<RealtimeRemoteDataSource>(
  (ref) => RealtimeRemoteDataSource(ref.watch(dioProvider)),
);

/// Opens the backend's Server-Sent Events stream (GET /events).
class RealtimeRemoteDataSource {
  RealtimeRemoteDataSource(this._dio);
  final Dio _dio;

  /// The server sends a heartbeat every 25 s; a minute of silence means the
  /// connection is dead even if the socket never reported it.
  static const idleTimeout = Duration(seconds: 60);

  /// Emits events until the connection ends (the stream then completes or
  /// errors) or [cancelToken] is cancelled. Throws [ApiException] if the
  /// connection cannot be opened.
  Future<Stream<RealtimeEvent>> connect(CancelToken cancelToken) async {
    try {
      final response = await _dio.get<ResponseBody>(
        ApiConstants.events,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: idleTimeout,
          headers: const {'Accept': 'text/event-stream'},
        ),
      );
      final body = response.data;
      if (body == null) throw const ApiException.generic();
      return parseServerSentEvents(
        body.stream
            .cast<List<int>>()
            .transform(utf8.decoder)
            .transform(const LineSplitter()),
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw const ApiException.generic();
    }
  }
}

/// Turns SSE text lines into events: `data:` lines are joined until a blank
/// line ends the event. Comments, other fields and malformed JSON are
/// skipped.
Stream<RealtimeEvent> parseServerSentEvents(Stream<String> lines) async* {
  final data = StringBuffer();
  await for (final line in lines) {
    if (line.isEmpty) {
      if (data.isEmpty) continue;
      try {
        final json = jsonDecode(data.toString());
        if (json is Map<String, dynamic>) yield RealtimeEvent.fromJson(json);
      } catch (_) {
        // Not JSON: ignore this event.
      }
      data.clear();
    } else if (line.startsWith('data:')) {
      data.write(line.substring(5).trimLeft());
    }
  }
}
