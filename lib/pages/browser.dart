import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

///
/// 网页视图
/// 2020/04/02 15:20
///
class BrowserPage extends StatefulWidget {

  /// 页面标题
  final String _pageTitle;
  /// 网页连接
  final String _url;

  BrowserPage(this._pageTitle,this._url,{Key key}) : super(key: key);

  @override
  _BrowserPageState createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {



  
  ///
  /// web页面体
  Widget _webBody(){
    
    return widget._url == null || widget._url == ''
     ? Center(child: Text('无效页面！连接地址错误...', style: TextStyle(color: Colors.red),),)
     : WebView(
        /* onWebViewCreated: (webViewController){
          webViewController.
        }, */
        initialUrl: widget._url,
        javascriptMode: JavascriptMode.unrestricted,
        
    );

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed:(){
          Navigator.of(context).pop();
        }),
        title: Text(widget._pageTitle??'无效页面'),
      ),
      body: _webBody(),
    );
  }
}