
import 'dart:convert';

/// 
/// 服务端返回的response对象
/// 2020-3-2 16:11
/// 
class ResponseData {


  /// 版本号
  String ver;

  /// 提示信息
  String message;
  
  /// 状态码
  /// * [0] 成功
  /// * [1] 失败
  int statusCode;

  /// 返回的数据
  dynamic res;

  ResponseData({this.ver,this.message,this.statusCode,this.res});


  @override
  String toString() {
    return '{'
      + 'ver: ' + this.ver
      +', message: ' + this.message
      +', statusCode: ' + this.statusCode.toString()
      +', res: ' + res.toString()
      + '}';
  }


  /// Json转对象
  factory ResponseData.fromJson(Map<String, dynamic> json){
      return ResponseData(
          ver:json['ver'],
          message:json['message'],
          statusCode:int.parse(json['statusCode'].toString()),
          res:json.putIfAbsent('res', () => null)
      );
  }


  Map<String, dynamic> toJson(){
    return <String,dynamic>{
      'ver':this.ver,
      'message':this.message,
      'statusCode':this.statusCode,
      'res':this.res
    };
  }


}