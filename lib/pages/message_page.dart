import 'package:bju_information_app/constants/bju_constant.dart';
import 'package:bju_information_app/pages/details/message_details.dart';
import 'package:bju_information_app/providers/jpush_provider.dart';
import 'package:bju_information_app/providers/login_provider.dart';
import 'package:bju_information_app/utils/db_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class MessagePage extends StatefulWidget {
  MessagePage({Key key}) : super(key: key);

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {

  final List<String> _msgItems = ['平台通知','@我的','评论我','赞我'];

  final List<Icon> _msgItemIcons = [
    Icon(FontAwesomeIcons.bullhorn, color: Colors.lightBlue[400],),
    Icon(FontAwesomeIcons.at, color: Colors.lightBlue[400]),
    Icon(FontAwesomeIcons.comments, color: Colors.lightBlue[400]),
    Icon(FontAwesomeIcons.thumbsUp,color: Colors.lightBlue[400])
  ];




  @override
  Widget build(BuildContext context) {
    
    // 初始化屏幕大小用于适配
    ScreenUtil.init(context, width:750,height:1334);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        //leading:Icon(Icons.account_circle),
        title: Text('消息'),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(Icons.help_outline), 
          )
        ],
      ),
      body: Consumer2<LoginProvider,JPushProvider>(
          builder: (context, loginProvider, jpushProvider, child){
            // loginProvider.isLogin ? Center(child: Text('同学，您还没有登录唷~')) : 
            return ListView.separated(
                padding: EdgeInsets.only(left:5, right:5),
                itemBuilder: (context,index){

                  return ListTile(
                      leading: _msgItemIcons[index],
                      title: Text(_msgItems[index]),
                      trailing: Icon(FontAwesomeIcons.chevronRight, size: 32, color: Colors.grey[400],),
                      onTap: (){
                         // 用户未登录并点击了 ['@我','评论我','赞我'],给出提示信息
                        if(!loginProvider.isLogin && index != 0){
                          showCupertinoDialog(context: context, builder: (context){
                              return CupertinoAlertDialog(
                                title: Icon(Icons.warning,color: Colors.deepOrangeAccent,),
                                content: Text('同学请先登录，在查看！'),
                                actions:[
                                  FlatButton(
                                    onPressed: () => Navigator.pop(context), 
                                    child: Text('知道了'),
                                  ),
                                ]
                              );
                          });
                          return;
                        }
                        print('用户点击了---$index]');
                        print('messageList:'+jpushProvider.messageList(index).toString());

                        // 跳转到消息详情页面
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => MessageDetailsPage(index)
                          )
                        );

                      },
                    );
                }, 
                separatorBuilder: (context,index){
                  return child;
                }, 
                itemCount: _msgItems.length
            );
          },
        child: Divider(height:10),
        ),
    );
  }


 
  

}

