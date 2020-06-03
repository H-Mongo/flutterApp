import 'package:bju_information_app/net/bju_net.dart';
import 'package:bju_information_app/pages/main_page.dart';
import 'package:bju_information_app/providers/bju_app_provider.dart';
import 'package:bju_information_app/providers/jpush_provider.dart';
import 'package:bju_information_app/providers/login_provider.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:splashscreen/splashscreen.dart';

void main() {
  
  runApp(BJUInformationServiceApp());

}

class BJUInformationServiceApp extends StatefulWidget {
  BJUInformationServiceApp({Key key}) : super(key: key);

  @override
  _BJUInformationServiceAppState createState() => _BJUInformationServiceAppState();
}

class _BJUInformationServiceAppState extends State<BJUInformationServiceApp> {

  List<SingleChildWidget> _providers = [
    buildProvider<BjuAppSettingsProvider>(BjuAppSettingsProvider()..init()),
    buildProvider<LoginProvider>(LoginProvider()),
    buildProvider<JPushProvider>(JPushProvider()..initNotificationPlugin()..initJPush()..setUpJPush())
  ];


  static ChangeNotifierProvider<T> buildProvider<T extends ChangeNotifier>(T value){
    return ChangeNotifierProvider<T>.value(value: value);
  }

  @override
  void initState() { 
    super.initState();
    // 初始化项目中的各种配置信息
    _initConfig();
    
    
  }

  void _initConfig() async {
     // 初始化请求Dio配置
    BjuHttp.initConfig();
    // 初始化SharedPreferences工具类
    await SpUtil.getInstance();

  }


  @override
  Widget build(BuildContext context) {
    
    return MultiProvider(
      providers: _providers,
      child: Consumer<BjuAppSettingsProvider>(builder: (context, BjuAppSettingsProvider, child){
        return OKToast(
            child: MaterialApp(
            title: BjuAppSettingsProvider.appTitle,
            debugShowCheckedModeBanner: false,
            theme: BjuAppSettingsProvider.bjuThemeData,
            // home: Scaffold(
            //   body:this._buildSplashScreenPage(MainPage()),
            // ),
            home: this._buildSplashScreenPage(MainPage()),
          ),
        );
      })
    );
  }

  SplashScreen _buildSplashScreenPage(Widget rootPage){
    return SplashScreen(
      seconds: 3,
      navigateAfterSeconds: rootPage,
      title: new Text('欢迎使用宝大IS平台',
      style: new TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20.0
      ),),
      image: new Image.asset('assets/splash/bju_splash.gif'),
      backgroundColor: Colors.white,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 100.0,
      onClick: ()=>print("Flutter Egypt"),
      loaderColor: Colors.red
    );
  }

}

