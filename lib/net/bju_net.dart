
import 'package:bju_information_app/api/api.dart';
import 'package:dio/dio.dart';

///
/// BJU网络
///
class BjuHttp {

  /// Dio 请求的配置
  // static final BaseOptions baseOptions = BaseOptions(
  //       // baseUrl: API.baseUri,
  //       connectTimeout: 6000,
  //       receiveTimeout: 4000,
  //       contentType: Headers.jsonContentType,
  //       headers: {
  //         Headers.contentTypeHeader: Headers.jsonContentType,
  //         'Authorization': 'Bearer '
  //       }
  //   );

  /// Dio请求
 static final Dio dio = Dio();


  
  /// 初始化Dio配置
 static void initConfig(){
    // 基础选项设置
    // dio.options = BaseOptions(
    //     // baseUrl: API.baseUri,
    //     // connectTimeout: 6000,
    //     // receiveTimeout: 4000,
    //     // contentType: Headers.jsonContentType,
    //     // headers: {
    //     //   // Headers.contentTypeHeader: Headers.jsonContentType,
    //     //   // 'Authorization': 'Bearer '
    //     // }
    // );
    // print('DIO请求配置信息为: ');
    // print('connectTimeout: ' + dio.options?.connectTimeout.toString());
    // print('receiveTimeout: ' + dio.options?.receiveTimeout.toString());
    // print('contentType: ' + dio?.options?.contentType??null);
    // print('headers: ' + dio?.options?.headers.toString()??null);
    // print('params: ' + dio?.options?.queryParameters.toString()??null);
    // 请求拦截器设置
    dio.interceptors.add(InterceptorsWrapper(
        onRequest:(RequestOptions options) async {
          print('请求前打印options: ');
          print('contentType: ' + options.contentType);
          print('headers: ' + options.headers.toString());
          print('data: ' + options.data.toString());
          print('params: ' + options.queryParameters.toString());
        // Do something before request is sent
        return options; //continue
        // If you want to resolve the request with some custom data，
        // you can return a `Response` object or return `dio.resolve(data)`.
        // If you want to reject the request with a error message,
        // you can return a `DioError` object or return `dio.reject(errMsg)`
        },
        onResponse:(Response response) async {
        // Do something with response data
        return response; // continue
        },
        onError: (DioError e) async {
        // Do something with response error
        return  e;//continue
        }
    ));
    
  }
  /// 设置访问Token
  static token(dynamic token){
    dio.options.contentType = 'application/json';
    dio.options.headers['Authorization'] = token;
    print('[set token] dio header :'+dio.options.headers.toString());
  }

  // 销毁token
  static disposeToken(){
    dio.options.contentType = 'application/json';
    dio.options.headers['Authorization'] = 'Bearer ';
    print('[dispose token] dio header :'+dio.options.headers.toString());
  }
  

  //Dio get instance => _dio;

  /// 
  /// GET请求
  ///   * [path] 路径字符串
  ///   * [params] 请求参数
  /// 
  static Future<Response> get(String path,{Map<String, dynamic> params}) async => await dio.get(path, queryParameters: params);

  /// 
  /// POST请求
  ///   * [path] 路径字符串
  ///   * [data] body数据
  ///   * [params] 请求参数（URL编码后）
  ///   * [options] 请求设置
  /// 
  static Future<Response> post(String path,{dynamic data, Map<String, dynamic> params, Options options}) async => await dio.post(path, queryParameters: params, options: options);

  /// 
  /// POST请求
  ///   * [path] 路径字符串
  ///   * [data] body数据(支持FormData)
  ///   * [params] 请求参数（URL编码后）
  /// 
  static Future<Response> put(String path,{dynamic data, Map<String, dynamic> params}) async => await dio.put(path, queryParameters: params);

  /// 
  /// POST请求
  ///   * [path] 路径字符串
  ///   * [data] body数据
  ///   * [params] 请求参数（URL编码后）
  /// 
  static Future<Response> delete(String path,{dynamic data, Map<String, dynamic> params}) async => await dio.delete(path, queryParameters: params);







}