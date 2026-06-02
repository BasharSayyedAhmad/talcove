import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/api_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio dio;
  String? _accessToken;
  late PersistCookieJar _cookieJar;
  String? get accessToken => _accessToken;
  PersistCookieJar get cookieJar => _cookieJar;
  Future<void> init() async {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 90),
        receiveTimeout: const Duration(seconds: 120),
        sendTimeout: const Duration(seconds: 60),
        //form data
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      ),
    );

    // تزبيط ال كوكي جار
    final appDocDir = await getApplicationDocumentsDirectory();
    _cookieJar = PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage("${appDocDir.path}/.cookies/"),
    );
    dio.interceptors.add(CookieManager(cookieJar));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }

          if (options.data is Map &&
              options.headers['Content-Type'] ==
                  'application/x-www-form-urlencoded') {
            options.data = FormData.fromMap(
              options.data as Map<String, dynamic>,
            );
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            print('⚠️ Token expired, need refresh');
          }
          return handler.next(error);
        },
      ),
    );

    // Logging للتصحيح
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );
  }

  void setAccessToken(String token) {
    _accessToken = token;
  }

  void clearAccessToken() {
    _accessToken = null;
  }

  Future<void> clearAllCookies() async {
    final cookieJar = PersistCookieJar();
    await cookieJar.deleteAll();
  }
}
