import 'package:flutter/material.dart';
///
/// BJU APP的全局状态及settings管理
/// 
class BjuAppSettingsProvider extends ChangeNotifier{

    // 主题色彩
  ThemeData _bjuThemeData;
  String _appTitle;

  ThemeData get bjuThemeData => _bjuThemeData;
  String get appTitle => _appTitle;

  /// 初始化Setting
  void init(){
    _bjuThemeData = ThemeData(
      primaryColor: Color(0xFF42A5F5)
    );
    _appTitle = '宝鸡大学信息服务平台';
  }

}