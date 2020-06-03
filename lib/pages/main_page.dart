import 'package:bju_information_app/pages/personal_center_page.dart';
import 'package:bju_information_app/pages/message_page.dart';
import 'package:bju_information_app/pages/publish_page.dart';
import 'package:bju_information_app/pages/square_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  /// 底部导航栏的索引值
  int _currentIndex = 0;
  /// BottomIconSize
  final double _bottomIconSize = 32;
  // BottomIconColor

  /// body
  final List<Widget> _bodys = [HomePage(),SquarePage(),MessagePage(),PersonalCenterPage()];

  /// 
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();



  ///
  /// 创建底部导航栏
  ///
  BottomAppBar _createBottomAppBar(){
    return BottomAppBar(
        color: Colors.lightBlueAccent,
        shape: CircularNotchedRectangle(), // 凹槽
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              iconSize:_bottomIconSize,
              icon: Icon(Icons.apps), onPressed: () {
              setState(() {
                _currentIndex = 0;
              });
            }),
            IconButton(
              iconSize:_bottomIconSize,
              icon: Icon(Icons.camera),onPressed: () {
              setState(() {
                // _currentIndex = 1;
                // 跳转到朋友圈页面
                Navigator.push(context, MaterialPageRoute(builder: (context) => SquarePage()));
              });
            }),
            IconButton(
              iconSize:_bottomIconSize,
              icon: Icon(Icons.mail), onPressed: () {
              setState(() {
                _currentIndex = 2;
              });
            }),
            IconButton(
              iconSize:_bottomIconSize,
              icon: Icon(Icons.person), onPressed: () {
              setState(() {
                _currentIndex = 3;
              });
            }),
          ],
        ),
      );
  }


  /// 发布栏目
  Widget _showPublishItem(){

     return Container(
       padding: EdgeInsets.all(10),
      /*  decoration: BoxDecoration(
         color: Colors.white54,
         borderRadius: BorderRadius.all(Radius.circular(20))
       ), */
       child: Column(
         mainAxisSize:MainAxisSize.min,
         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
         crossAxisAlignment: CrossAxisAlignment.stretch,
         children: <Widget>[

            FlatButton(
               child: Text(
                 "表白墙",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    wordSpacing: 5,
                  ),
               ),
               onPressed: (){
                 print("****表白墙--1****");
                 // 手动关闭模态框
                 Navigator.pop(context);
                 Navigator.push(context, MaterialPageRoute(builder: (context){
                    return PublishPage(1);
                 }));

               }, 
             ),
            Divider(height: 2,color: Colors.white,),
            FlatButton(
               child: Text("万能墙",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    wordSpacing: 5,
                  ),
               ),
               onPressed: (){
                 print("****万能墙--2****");
                  // 手动关闭模态框
                 Navigator.pop(context);
                 Navigator.push(context, MaterialPageRoute(builder: (context){
                    return PublishPage(2);
                 }));
                 
               }, 
             ),
            Divider(height: 2,color: Colors.white,),
            FlatButton(
               child: Text("谏言贴",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    wordSpacing: 5,
                  ),
               ),
               onPressed: (){
                 print("****谏言贴--3****");
                // 手动关闭模态框
                 Navigator.pop(context);
                 Navigator.push(context, MaterialPageRoute(builder: (context){
                    return PublishPage(3);
                 }));

               }, 
             ),
            Divider(height: 2,color: Colors.white,),
            FlatButton(
               child: Text("兼职汇",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    wordSpacing: 5,
                  ),
               ),
               onPressed: (){
                 print("****兼职汇---4****");
                // 手动关闭模态框
                 Navigator.pop(context);
                 Navigator.push(context, MaterialPageRoute(builder: (context){
                    return PublishPage(4);
                 }));

               }, 
             ),

         ],

       ),
     );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
     // key: _scaffoldKey,
      body: this._bodys[this._currentIndex],
      bottomNavigationBar: this._createBottomAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 挑转到发布页面
          /* Scaffold.of(context).showBottomSheet(
            (context){
              return _showPublishItem();
            }
          ); */

         // showCupertinoModalPopup(context: context, builder: (context) => _showPublishItem());
         showModalBottomSheet(
            backgroundColor: Colors.lightBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topLeft:Radius.circular(20),topRight: Radius.circular(20),)
            ),
            context: context, 
            builder: (context){
              return _showPublishItem();
            }
          );
          

        },
        tooltip: '发布',
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }



}

///
/// 顶部BannerBar组件
///
class BjuISAppTopBar extends StatefulWidget {
  BjuISAppTopBar({Key key}) : super(key: key);

  @override
  _BjuISAppTopBarState createState() => _BjuISAppTopBarState();
}

class _BjuISAppTopBarState extends State<BjuISAppTopBar> {
  // 文本编辑控制器
  final TextEditingController _textEditingController = new TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(child: TextField(
          controller:_textEditingController,
          onChanged: null,
          onSubmitted: null,
          decoration: InputDecoration(),
        ))
      ],
    );
  }
}
