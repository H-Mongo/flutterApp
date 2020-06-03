import 'package:bju_information_app/api/api.dart';
import 'package:bju_information_app/models/moving.dart';
import 'package:bju_information_app/models/response.dart';
import 'package:bju_information_app/net/bju_net.dart';
import 'package:bju_information_app/pages/details/moving_details.dart';
import 'package:bju_information_app/providers/login_provider.dart';
import 'package:bju_information_app/utils/bju_timeline_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

///
/// 所有动态页面
/// 2020/05/03 09:43
///

class AllMovingPage extends StatefulWidget {
  AllMovingPage({Key key}) : super(key: key);

  @override
  _AllMovingPageState createState() => _AllMovingPageState();
}

class _AllMovingPageState extends State<AllMovingPage> {



  /// 动态集合
  List<Moving> _movingList = [];



  @override
  void initState() { 
    super.initState();
    _initPageData();
  }


  /// 初始化页面数据
  Future<void> _initPageData() async {
    final int userId = Provider.of<LoginProvider>(context, listen: false).loginUser.userId;
    final ResponseData resData = await BjuHttp.get(API.allMovingWithUser + userId.toString())
      .then((onValue) => ResponseData.fromJson(onValue.data))
      .catchError((onError){
        print('请求用户动态列表出错了！');
        print(onError);
        showToast('服务器请求异常！');
      });
    if(resData == null){
      showToast('请求失败！');
      return;
    }
    print(resData.message);
    if(resData.statusCode == 1) return; 
    if(!mounted) return;
    setState(() {
      _movingList = (resData.res as List).map<Moving>((m) => Moving.fromJson(m)).toList();
    });
  }

 ///
 /// 主体布局
 ///
 Widget _bodyLayout(){
   
   final TextStyle noticeTextStyle = TextStyle(
     fontSize: 18,
     fontWeight: FontWeight.w500,
     color: Colors.black38,
     wordSpacing: 2,
   );

   return _movingList.isEmpty ? Center(child: Text('暂无动态信息！',style: noticeTextStyle,),) : ListView.separated(
     itemBuilder: (context,index){
       return Container(
         margin: EdgeInsets.only(top: index == 0 ? 10 : 0,bottom: index == _movingList.length - 1 ? 15 : 0,),
         height: ScreenUtil().setHeight(300),
         child: Row(
           mainAxisSize: MainAxisSize.max,
           mainAxisAlignment: MainAxisAlignment.start,
           children: <Widget>[
             Container(
               margin: EdgeInsets.only(left: 10),
               color: Colors.white54,
               child: Text(BjuTimelineUtil.formatDateStr(_movingList[index].movingCreateTime), style: TextStyle(
                 fontSize: 16,
                 fontWeight: FontWeight.w500,
                 color: Colors.lightBlue,
               ),),
             ),
             VerticalDivider(color: Colors.lightBlue,),
             Expanded(
               child: Column(
                 mainAxisSize: MainAxisSize.max,
                 mainAxisAlignment: MainAxisAlignment.start,
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: <Widget>[
                   Expanded(
                     child: Row(
                       mainAxisSize: MainAxisSize.max,
                       mainAxisAlignment: MainAxisAlignment.start,
                       children: <Widget>[
                         Expanded(child: Text(_movingList[index].movingContent, style: TextStyle(
                           fontSize: 15,
                           fontWeight: FontWeight.w400,
                           color: Colors.black54
                         ),)),
                         Padding(
                           padding: EdgeInsets.only(left: 3, right: 10),
                           child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              MaterialButton(
                                minWidth: ScreenUtil().setWidth(60),
                                height: ScreenUtil().setHeight(60),
                                  color: Colors.red[400],
                                  child: Text('删除',style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),),
                                  onPressed: () async {

                                    // showToastWidget(
                                    //     CircularProgressIndicator(backgroundColor: Colors.black38),
                                    //     context: context,
                                    //     duration: Duration(milliseconds: 1500),
                                    //   );

                                    final int movingId = _movingList[index].movingId??0;
                                    print('删除动态: movingId=' + movingId.toString());
                                    if(movingId == 0){
                                      showToast('无效ID');
                                      return;
                                    }
                                    final ResponseData resData = await BjuHttp.delete(API.deleteMoving + movingId.toString())
                                      .then((onValue) => ResponseData.fromJson(onValue.data))
                                      .catchError((onError){
                                        print('删除动态请求异常！');
                                        print(onError);
                                        showToast('请求服务器异常！');
                                      });
                                    if(resData == null) {
                                      showToast('请求失败！');
                                      return;
                                    }
                                    showToast(resData.message);
                                    if(resData.statusCode == 1){
                                      return;
                                    }
                                    if(!mounted) return;
                                    setState(() {
                                      _movingList.removeAt(index);
                                    });
                                  },
                                ),
                              MaterialButton(
                                minWidth: ScreenUtil().setWidth(60),
                                height: ScreenUtil().setHeight(60),
                                color: Colors.lightBlue,
                                child: Text('详情',style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white
                                  ),),
                                  onPressed: (){
                                    final int movingId =_movingList[index]?.movingId??0;
                                    if(movingId == 0){
                                      showToast('无效ID');
                                      return;
                                    }
                                    // 跳转到动态详情页面
                                    Navigator.push<Map<String,int>>(context, MaterialPageRoute(builder: (context)=> MovingDetailsPage(movingId)));
                                  },
                                )
                            ],
                          ),
                         ),
                       ],
                     )
                   ),
                   Divider(endIndent: 5, color: Colors.grey[400],),
                   Row(
                     mainAxisSize: MainAxisSize.max,
                     mainAxisAlignment: MainAxisAlignment.end,
                     children: <Widget>[
                       Expanded(
                         child: Text(_movingList[index].movingType,style: TextStyle(
                           fontSize: 16,
                           fontWeight: FontWeight.w600,
                           color: Colors.lightBlue,
                           letterSpacing: 0.5,
                         ),)
                       ),
                       Padding(
                         padding: EdgeInsets.only(left: 5),
                         child: Row(
                           mainAxisSize: MainAxisSize.min,
                           mainAxisAlignment: MainAxisAlignment.spaceAround,
                           children: <Widget>[
                             Icon(FontAwesomeIcons.eye, color: Colors.lightBlue[400],size: 14),
                             Padding(
                               padding: EdgeInsets.only(left: 3),
                               child: Text(_movingList[index]?.movingBrowse?.toString()??'0',style: TextStyle(
                                 fontSize: 12,
                                 color: Colors.black38
                               ),),
                             ),
                           ],
                         ),
                       ),
                       Padding(
                         padding: EdgeInsets.only(left: 5),
                         child: Row(
                           mainAxisSize: MainAxisSize.min,
                           mainAxisAlignment: MainAxisAlignment.spaceAround,
                           children: <Widget>[
                             Icon(FontAwesomeIcons.solidThumbsUp, color: Colors.lightBlue[400],size: 14),
                             Padding(
                               padding: EdgeInsets.only(left: 3),
                               child: Text(_movingList[index]?.movingLike?.toString()??'0',style: TextStyle(
                                 fontSize: 12,
                                 color: Colors.black38
                               ),),
                             ),
                           ],
                         ),
                       ),
                       Padding(
                         padding: EdgeInsets.only(left: 5, right: 20),
                         child: Row(
                           mainAxisSize: MainAxisSize.min,
                           mainAxisAlignment: MainAxisAlignment.spaceAround,
                           children: <Widget>[
                             Icon(FontAwesomeIcons.commentDots, color: Colors.lightBlue[400],size: 14),
                             Padding(
                               padding: EdgeInsets.only(left: 3),
                               child: Text(_movingList[index]?.movingCommentCount?.toString()??'0',style: TextStyle(
                                 fontSize: 12,
                                 color: Colors.black38
                               ),),
                             ),
                           ],
                         ),
                       ),
                     ],
                   )
                 ],
              )
             ),
           ],
         )
       );
     }, 
     separatorBuilder: (context,index) => Divider(indent: 2, endIndent: 2, color: Colors.lightBlue[600], thickness: 1.0,), 
     itemCount: _movingList.length
    );
   
 }




  @override
  Widget build(BuildContext context) {

      // 初始化屏幕大小用于适配
    ScreenUtil.init(context, width:750,height:1334);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed:()=>Navigator.of(context).pop()),
        title: Text('全部动态'),
      ),
      body: _bodyLayout(),
    );
  }
}

