import 'package:bju_information_app/api/api.dart';
import 'package:bju_information_app/models/response.dart';
import 'package:bju_information_app/net/bju_net.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

///
/// 推送信息到全员用户
/// 2020/04/20 15:15
///
class BackManagement extends StatefulWidget {
  BackManagement({Key key}) : super(key: key);

  @override
  _BackManagementState createState() => _BackManagementState();
}

class _BackManagementState extends State<BackManagement> {


  /// 文本编辑控制器
  TextEditingController  _contentTextController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed:(){
          Navigator.of(context).pop();
        }),
        title: Text('后台管理'),
      ),
      body: SingleChildScrollView(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(5),
              child: TextField(
                controller: _contentTextController,
                keyboardType: TextInputType.text,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '请输入全平台推送通知的信息...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10,),
              child: RaisedButton(
                padding: EdgeInsets.fromLTRB(0, 3, 0, 3),
                color: Colors.lightBlue[400],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Text('全员推送（ALL STAFF PUSH）',style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
                onPressed: () async {
                  print('全员信息推送开始...');
                  if(!(_contentTextController.text.trim().length > 0)){
                      showToast('请输入推送的内容！');
                      return;
                  }
                  // 向服务器发起推送请求
                  ResponseData resData = await BjuHttp.post(API.pushAll,params: {
                    'messageType' : 0,
                    'content' : _contentTextController.text
                  }).then((onValue) => ResponseData.fromJson(onValue.data))
                  .catchError((onError){
                    print('全员推送，请求服务器异常！');
                    print(onError);
                    showToast('服务器请求异常！');
                    return;
                  });

                if(resData == null){
                  Future.delayed(Duration(milliseconds: 1500),() => showToast('请求失败！'));
                  return;
                }
                // 弹出提示
                showToast(resData.message);
                if(resData.statusCode == 0){
                  // 清空输入框文本
                  _contentTextController.clear();
                }



                }
              ),
            )
          ],
        ),
        ),
    );
  }
}