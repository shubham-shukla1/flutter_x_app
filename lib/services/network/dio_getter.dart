import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../shared/app_logging/app_log_helper.dart';
import '../../shared/flavor/app_flutter_config.dart';
import '../local_pref/app_pref.dart';

class DioNetworkService {
  static final DioNetworkService _instance = DioNetworkService._internal();

  DioNetworkService._internal();

  factory DioNetworkService() {
    return _instance;
  }

  static DioNetworkService get instance => _instance;

  Dio? _dio;

  final bool isContentTypeJson = true;
  final bool _isHttpRequest = false;
  final bool _urlEncode = true;

  Dio getMyDio() {
    if (_dio == null) {
      _dio = Dio();

      /// Options
      _dio!.options.baseUrl = AppFlavorConfig.instance!.baseURL!;
      _dio!.options.contentType = Headers.jsonContentType;
      _dio!.options.receiveTimeout = Duration(seconds: 10).inMilliseconds;
    }

    /// Clear previous interceptors
    _dio!.interceptors.clear();

    /// Interceptors
    _dio!.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );

    if (_token == null) _token = AppPreferences.instance!.authToken;

    AppLog.log('Bearer : $token');

    /// Default 2 interceptors if user is already login
    if (_token != null && _token!.isNotEmpty) {
      _dio!.interceptors.add(
        InterceptorsWrapper(
          onResponse: (response, handler) {
            AppLog.log('DIO REQUEST RESPONSE : ${response}');
          },
          onRequest: (options, handler) {
            options.headers['Authorization'] = 'Bearer $token';

            if (isContentTypeJson)
              options.headers['Content-Type'] = 'application/json';

            if (_urlEncode)
              options.headers['Content-Type'] =
                  'application/x-www-form-urlencoded';

            if (_isHttpRequest)
              options.headers['X-Requested-With'] = 'XMLHttpRequest';
          },
          onError: (DioError e, ErrorInterceptorHandler h) {
            AppLog.log('DIO REQUEST ERROR : ${e.error}');
          },
        ),
      );
    }

    return _dio!;
  }

  /// set token for authentication
  String? _token;

  String? get token => _token;

  set setToken(String token) {
    _token = token;
  }
}
