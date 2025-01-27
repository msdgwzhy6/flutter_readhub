import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';
import 'package:flutter/foundation.dart';

export 'package:dio/dio.dart';

/// 必须是顶层函数
_parseAndDecode(String response) {
  return jsonDecode(response);
}

parseJson(String text) {
  return compute(_parseAndDecode, text);
}

///网络请求基类
abstract class BasisHttp extends DioForNative {
  BasisHttp() {
    /// 初始化 加入app通用处理
    (transformer as DefaultTransformer).jsonDecodeCallback = parseJson;
    interceptors..add(HeaderInterceptor());
    init();
  }

  void init();
}

/// 添加常用Header
class HeaderInterceptor extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.connectTimeout = 1000 * 15;
    options.receiveTimeout = 1000 * 15;
    options.responseType = ResponseType.json;
    options.contentType = Headers.jsonContentType;
    super.onRequest(options, handler);
  }
}
