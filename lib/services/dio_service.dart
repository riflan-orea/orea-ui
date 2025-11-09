import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Dio-based API Service
/// Demonstrates why Dio is preferred for production apps
class DioService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  late final Dio _dio;

  DioService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      // Validate status codes
      validateStatus: (status) => status != null && status < 500,
    ));

    // Add interceptors
    _setupInterceptors();
  }

  /// Setup interceptors for logging, auth, error handling
  void _setupInterceptors() {
    // 1. Request Interceptor (Add auth token, modify requests)
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add authentication token to all requests
        // final token = await _getAuthToken();
        // options.headers['Authorization'] = 'Bearer $token';

        if (kDebugMode) {
          print('┌──────────────────────────────────────────────────');
          print('│ REQUEST: ${options.method} ${options.path}');
          print('│ Headers: ${options.headers}');
          if (options.data != null) {
            print('│ Body: ${options.data}');
          }
          print('└──────────────────────────────────────────────────');
        }

        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('┌──────────────────────────────────────────────────');
          print('│ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
          print('│ Data: ${response.data}');
          print('└──────────────────────────────────────────────────');
        }

        return handler.next(response);
      },
      onError: (error, handler) async {
        if (kDebugMode) {
          print('┌──────────────────────────────────────────────────');
          print('│ ERROR: ${error.message}');
          print('│ Status: ${error.response?.statusCode}');
          print('│ Path: ${error.requestOptions.path}');
          print('└──────────────────────────────────────────────────');
        }

        // Handle 401 Unauthorized - Refresh token
        if (error.response?.statusCode == 401) {
          try {
            // Refresh token
            // final newToken = await _refreshToken();

            // Retry the request with new token
            // error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            // final response = await _dio.fetch(error.requestOptions);
            // return handler.resolve(response);
          } catch (e) {
            // Refresh failed, logout user
            // await _logout();
          }
        }

        return handler.next(error);
      },
    ));

    // 2. Logging Interceptor (only in debug mode)
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload file with progress
  Future<Response> uploadFile(
    String path,
    String filePath, {
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...?data,
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Download file with progress
  Future<Response> downloadFile(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Request timeout. Please try again.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Unknown error';

        switch (statusCode) {
          case 400:
            return BadRequestException('Bad request: $message');
          case 401:
            return UnauthorizedException('Unauthorized. Please login again.');
          case 403:
            return ForbiddenException('Access forbidden: $message');
          case 404:
            return NotFoundException('Resource not found');
          case 500:
          case 502:
          case 503:
            return ServerException('Server error. Please try again later.');
          default:
            return ServerException('HTTP Error: $statusCode');
        }

      case DioExceptionType.cancel:
        return RequestCancelledException('Request was cancelled');

      case DioExceptionType.connectionError:
        return NetworkException(
          'No internet connection. Please check your network.',
        );

      default:
        return Exception('Unexpected error: ${error.message}');
    }
  }
}

/// Custom Exception Classes
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class TimeoutException extends ApiException {
  TimeoutException(super.message);
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}

class BadRequestException extends ApiException {
  BadRequestException(super.message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message);
}

class ForbiddenException extends ApiException {
  ForbiddenException(super.message);
}

class NotFoundException extends ApiException {
  NotFoundException(super.message);
}

class ServerException extends ApiException {
  ServerException(super.message);
}

class RequestCancelledException extends ApiException {
  RequestCancelledException(super.message);
}
