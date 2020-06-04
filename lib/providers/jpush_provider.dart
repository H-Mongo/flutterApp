import 'dart:convert';

import 'package:bju_information_app/constants/bju_constant.dart';
import 'package:bju_information_app/models/user_message.dart';
import 'package:bju_information_app/utils/db_util.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:provider/provider.dart';

///
/// ##### JPush推送Provider
///  对JPush的数据处理，以及notification分类提醒，信息页面的数据刷新处理
///
class JPushProvider extends ChangeNotifier{

  // JPush
  final JPush _jpush = JPush();

  // AllUserMessage
  List<UserMessage> _allUserMessages = List();
  
   // 系统通知
  List<UserMessage> _noticeMessages = List();
  // @我 
  List<UserMessage> _atMessages = List();
  // 评论我
  List<UserMessage> _commentMessages = List();
  // 赞我
  List<UserMessage> _likeMessages = List();


  // notification plugin
  FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  /* 
  // global notification settings
  static AndroidInitializationSettings _androidInitializationSettings = AndroidInitializationSettings('app_icon');
  static IOSInitializationSettings _iosInitializationSettings =  IOSInitializationSettings();
  InitializationSettings _initializationSettings =  InitializationSettings(_androidInitializationSettings,_iosInitializationSettings);
 */
  // only for droid settings
  AndroidFlutterLocalNotificationsPlugin _androidFlutterLocalNotificationsPlugin  = AndroidFlutterLocalNotificationsPlugin();


  JPush get jpush => _jpush;

  // 获取信息列表
  List<UserMessage> get alluserMessages => _allUserMessages;

  // 系统通知
  List<UserMessage> get noticeMessages => _noticeMessages;
  // @我 
  List<UserMessage> get atMessages => _atMessages;
  // 评论我
  List<UserMessage> get commentMessages => _commentMessages;
  // 赞我
  List<UserMessage> get likeMessages => _likeMessages;

  // 通知记录数
  int _noticeCount;
  // @记录数
  int _atCount;
  // 评论记录数
  int _commentCount;
  // 点赞记录数
  int _likeCount;


  
  // 获取安卓通知
  AndroidFlutterLocalNotificationsPlugin get plugin => _androidFlutterLocalNotificationsPlugin;

  ///
  /// 初始化plugin
  ///
  void initNotificationPlugin(){
    // app_icon 通知显示的图标
    plugin.initialize(AndroidInitializationSettings('notice_icon'),onSelectNotification: _onSlectNotification);
  }
  
  ///
  /// 监听点击通知
  ///
  Future<void> _onSlectNotification(String payload) async {

     if (payload != null) {
      print('notification payload: ' + payload);
    }
  }

  ///
  /// 显示通知
  ///
  Future<void> _showNotification(String title, String body, {int id = 0,String payload = 'default payload'}) async {
    // Android通知设置
   AndroidNotificationDetails notifications = AndroidNotificationDetails(
     'BJUIS_MESSAGE_CHANNEL', '推送自定义消息', '向用户通知收到的自定义消息',
      importance: Importance.High,
      priority: Priority.High,
      color: Colors.orangeAccent,
      style: AndroidNotificationStyle.Default,
      ticker: 'ticker',
     );
    // 插件展示通知
    await plugin.show(id, title, body, notificationDetails: notifications, payload: payload);
  }
  

  ///
  /// 按照类型插入指定消息列表
  ///    * [0] 系统通知
  ///    * [1] @我
  ///    * [2,3] 评论我
  ///    * [4,5] 赞我
  ///
  void _addMessagesByType(UserMessage message){
    int messageType = message?.messageType;
    if(0 == messageType){
      print('插入前：noticeMessage='+this._noticeMessages.toString());
      this._noticeMessages.add(message);
      this._noticeCount++;
      print('插入后：noticeMessage='+this._noticeMessages.toString());
    } else if(1 == messageType){
      print('插入前：atMessages='+this._atMessages.toString());
      this._atMessages.add(message);
      this._atCount++;
      print('插入前：atMessages='+this._atMessages.toString());
    }
    else if(2 == messageType || 3 == messageType){
      print('插入前：commentMessages='+this._commentMessages.toString());
      this._commentMessages.add(message);
      this._commentCount++;
      print('插入前：commentMessages='+this._commentMessages.toString());
    }
    else if(4 == messageType || 5 == messageType){
      print('插入前：likeMessages='+this._likeMessages.toString());
      this._likeMessages.add(message);
      this._likeCount++;
      print('插入前：likeMessages='+this._likeMessages.toString());
    }else{
      print('插入信息出错了！$message');
      return;
    }
    notifyListeners();
    return;

  }
  
      ///
      /// 初始化JPush，添加事件监听器
      ///
      void initJPush(){
        // 添加事件监听器
        _jpush.addEventHandler(
          // 接收通知回调方法。
          onReceiveNotification: (Map<String, dynamic> message) async {
            //  print("flutter 接受通知: $message");
            // DBUtil.deleteTable();
            print("flutter 通知附带信息: $message['extras']");
            print("透传信息为："+message['extras']['cn.jpush.android.EXTRA'].toString());
           // 通过通知携带的extras构造UserMessage
           UserMessage userMessage;
          //  print('推送通知用户信息对象');
          try{
            Map<String,dynamic> map = json.decode(message['extras']['cn.jpush.android.EXTRA']);
            print('extras字串解析为map：' + map.toString());
            print(map);
            userMessage = UserMessage.fromJson(map);
          }catch (e){
            print('构造用户信息模型异常了!');
            print(e);
          }
           print(userMessage);
           print('通知的extras转为UserMessage，结果：userMessage= ' + userMessage.toString());
           if(userMessage == null){
             print('服务端通知，未携带extras参数！');
             return;
           }
           /* UserMessage本地持久化，此处采用了SQLLite来存储数据
            * 对除了系统通知之外的服务端信息进行按照登录用户来分类，避免一个设备同一个APP多个用户登录的情况
            * 对于用户退出登录，可能存在未销毁绑定的JPush alias，针对这个情况，并不添加信息到用户表中
            * 注： 后续会优化并考虑退出时，撤销alias的作用，换做离线推送。
            */
            
            // 获取登录用户的mobile
            final String owner = SpUtil.getString(BJUConstants.loginUserMobile, defValue: null);
            print('登录用户的持久化身份：owner= ' + owner);
            // 非通知类信息，owner为null，不存储，丢弃
            if(userMessage.messageType != 0 && owner == null){
              return;
            }
            // return;
           // 将UserMessage转为Map
           final Map<String,dynamic> messageMap = userMessage.toMap();
           // 添加owner属性，messageType为0时，owner 为 app_alert，
           messageMap['owner'] = userMessage.messageType == 0 ? BJUConstants.alertOwner : owner;
           // 2-3同类别,4-5同类别
           if(messageMap["messageType"] == 2 || messageMap["messageType"] == 3){
             // 评论类 === 2
             messageMap["messageType"] = 2;
           } else if (messageMap["messageType"] == 4 || messageMap["messageType"] == 5){
             // 点赞类 === 3
             messageMap["messageType"] = 3;

           }
           print('修改类别后：messageMap= ' + messageMap.toString());
           // 执行插入操作
           bool result = await DBUtil.insertMessage(messageMap);
           // 统计消息的数量
          //  SpUtil.putStringList(BJUConstants.loginUserMobile, [0,1,1,1]);
           print('执行通知后，用户消息添加数据库中的结果：result=' + result.toString());
           
          },
    
          // 点击通知回调方法。
          onOpenNotification: (Map<String, dynamic> message) async {
            print("flutter 点击通知: $message");
          },
          ///  
          /// 接收自定义消息回调方法
          onReceiveMessage: (Map<String, dynamic> message) async {
            ///
            /// 获取消息后，
            ///   1. UserMessage数据，
            ///   2. 完成对用户的推送或提醒，
            ///   3. 添加到消息列表中
            ///
            await _showNotification("收到信息了","测试定向信息推送");
            print("flutter 自定义消息: $message['extras']");
            print("透传信息为："+message['extras']['cn.jpush.android.EXTRA'].toString());
           // 构造对象
           UserMessage userMessage = UserMessage.fromJson(jsonDecode(message['extras']['cn.jpush.android.EXTRA'].toString()));
           if(userMessage == null){
             print('用户信息为空！');
             return;
           }
           // 调用本地通知
           await _showNotification(userMessage.title,userMessage.content);
           print('解析的信息为：$userMessage');
           // 添加
           _addMessagesByType(userMessage);
            
          },
        );

        // 初始化数据库
        
      }


  ///
  /// 初始化消息页面计数的count
  ///
  void initCount(){

    final List<String> defaultList = ["0","0","0","0"];

    // 通知记录数 === 0
    _noticeCount = int.parse(SpUtil.getStringList(BJUConstants.loginUserMobile, defValue: defaultList).elementAt(0));
    // @记录数 === 1
    _atCount = int.parse(SpUtil.getStringList(BJUConstants.loginUserMobile, defValue: defaultList).elementAt(1));
    // 评论记录数 === 2
    _commentCount = int.parse(SpUtil.getStringList(BJUConstants.loginUserMobile, defValue: defaultList).elementAt(2));
    // 赞我记录数 === 3
    _likeCount = int.parse(SpUtil.getStringList(BJUConstants.loginUserMobile, defValue: defaultList).elementAt(3));
    
  }

  ///
  /// 保存消息计数
  /// * [type] 信息页面中的类别 （通知,@我,评论我,赞我）
  ///
 void saveMessageCount(int type){
   // 获取计数集合
   switch(type){
        // 通知类
        case 0 : {
          print('更新前 noticeCount: '+this._noticeCount.toString());
          this._noticeCount += 1;
          print('更新后 noticeCount: '+this._noticeCount.toString());
          break;
        } 
        // @我
        case 1: {
          print('更新前 atCount: '+this._atCount.toString());
          this._atCount += 1;
          print('更新前 atCount: '+this._atCount.toString());
          break;
        }
        // 评论我
        case 2 : {
          print('更新前 commentCount: '+this._commentCount.toString());
          this._commentCount += 1;
          print('更新前 commentCount: '+this._commentCount.toString());
          break;
        } 
        // 赞我
        case 3: {
          print('更新前 likeCount: '+this._likeCount.toString());
          this._likeCount += 1;
          print('更新前 likeCount: '+this._likeCount.toString());
          break;
        }
        default:
          print("更新消息列表已读状态错误，参数不正确，$type");
      }
      notifyListeners();
 }






    ///
    /// 记录数
    ///   * [type] 信息页面中的类别 （通知,@我,评论我,赞我）
    ///
    void updateMessagesReadCount(int type){
      switch(type){
        // 通知类
        case 0 : {
          print('更新前 noticeCount: '+this._noticeCount.toString());
          this._noticeCount += 1;
          print('更新后 noticeCount: '+this._noticeCount.toString());
          break;
        } 
        // @我
        case 1: {
          print('更新前 atCount: '+this._atCount.toString());
          this._atCount += 1;
          print('更新前 atCount: '+this._atCount.toString());
          break;
        }
        // 评论我
        case 2 : {
          print('更新前 commentCount: '+this._commentCount.toString());
          this._commentCount += 1;
          print('更新前 commentCount: '+this._commentCount.toString());
          break;
        } 
        // 赞我
        case 3: {
          print('更新前 likeCount: '+this._likeCount.toString());
          this._likeCount += 1;
          print('更新前 likeCount: '+this._likeCount.toString());
          break;
        }
        default:
          print("更新消息列表已读状态错误，参数不正确，$type");
      }
      notifyListeners();
      
    }
    
      ///
      /// 启动JPush
      ///
      void setUpJPush(){
        _jpush.setup(
          appKey: "your jpush appKey",
          channel: "flutter_channel",
          production: false,
          debug: true, // 设置是否打印 debug 日志
        );
        //_jpush.sendLocalNotification(null);
      }
    
      ///
      /// 设置JPush的别名（使用登录用户的电话号码）
      ///
      void setAlias(String mobile){
        
        _jpush.setAlias(mobile);
        notifyListeners();
      }

     ///
     /// 获取MessageCount
     /// * ['通知','@我','评论我','赞我']
     ///
     int messageCount(int index){
        switch (index) {
          case 0:
            return this._noticeCount;
          case 1:
            return this._atCount;
          case 2:
            return this._commentCount;
          case 3:
            return this._likeCount;
          default: print('无效消息index！');
        }
      }

      ///
     /// 获取MessageCount
     /// * ['通知','@我','评论我','赞我']
     ///
     List<UserMessage> messageList(int index){
        switch (index) {
          case 0:
            return this.noticeMessages;
          case 1:
            return this.atMessages;
          case 2:
            return this.commentMessages;
          case 3:
            return this.likeMessages;
          default: print('无效消息index！');
        }
      }
      
    
    
    
    }