import 'package:bju_information_app/api/api.dart';
import 'package:bju_information_app/models/moving.dart';
import 'package:bju_information_app/models/response.dart';
import 'package:bju_information_app/net/bju_net.dart';
import 'package:bju_information_app/providers/login_provider.dart';
import 'package:bju_information_app/utils/bju_timeline_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:getflutter/components/carousel/gf_carousel.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

///
/// 动态草稿页面
/// 2020/05/03 09:59
/// 

class DraftMovingPage extends StatefulWidget {
  DraftMovingPage({Key key}) : super(key: key);

  @override
  _DraftMovingPageState createState() => _DraftMovingPageState();
}

class _DraftMovingPageState extends State<DraftMovingPage> {




  
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
    final ResponseData resData = await BjuHttp.get(API.draftMovingWithUser + userId.toString())
      .then((onValue) => ResponseData.fromJson(onValue.data))
      .catchError((onError){
        print('请求草稿箱列表出错了！');
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
       return Card(
        elevation: 4,
        margin: EdgeInsets.fromLTRB(2, 5, 2, index != (_movingList.length - 1) ? 0 : 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 时间线
            Padding(
              padding: EdgeInsets.only(top: 5, left: 10),
              child: Text(BjuTimelineUtil.formatDateStr(_movingList[index].movingCreateTime), style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.lightBlue,
                letterSpacing: 2.0,
              ),),
            ),
            Divider(color: Colors.grey[400], thickness: 0.5,),
            // 内容
             Padding(
              padding: EdgeInsets.fromLTRB(10,0,10,10),
              child: Text(_movingList[index].movingContent, style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),),
            ),
            // 图片区域
            _movingList[index].movingImages == null || _movingList[index].movingImages.isEmpty 
            ? SizedBox()
            : GFCarousel(
                items: _movingList[index].movingImages.map(
                  (url) => Container(
                    margin: EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/gif/loading.jpg',
                          image: API.baseUri + url,
                          fit: BoxFit.cover,
                          width: ScreenUtil().setWidth(1000.0),
                          height: ScreenUtil().setHeight(500.0),
                        ),
                      ),
                    )
                  ).toList(),
                // onPageChanged: (index) {
                //   setState(() {
                //     index;
                //   });
                // },
            ),
            Divider(color: Colors.grey[400], thickness: 0.5,),
            // 动态类型及标签
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left:6,right:3),
                  child: Text(_movingList[index].movingType??'出错了',style: TextStyle(
                    fontSize: 16,
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                    ),),
                ),
                Expanded(
                  child: Padding(
                  padding: EdgeInsets.all(0),
                  child: _movingList[index].movingTopics == null 
                  ? Text("没有标签信息！") 
                  : Wrap(
                    spacing: 1,
                    runAlignment: WrapAlignment.center,
                    children: _movingList[index].movingTopics.map(
                      (t) => ChoiceChip(
                        // avatar: Icon(FontAwesomeIcons.heart),
                        selectedColor: Colors.grey[300], // 选中时的颜色
                        label: Text(t,
                          style: TextStyle(
                            color: Colors.lightBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w300
                          ),
                        ), 
                        selected: true,
                      )
                    ).toList(),
                  ),
                ),
              )
              ],
            ),
            // 操作
            Padding(
              padding: EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    color: Colors.lightBlue,
                    child: Text('发布', style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2.0,
                      color: Colors.white,
                    ),),
                    onPressed: () async {
                      
                      // showToastWidget(
                      //   CircularProgressIndicator(backgroundColor: Colors.black38),
                      //   context: context,
                      //   duration: Duration(milliseconds: 1500),
                      // );

                      final int movingId = _movingList[index].movingId??0;
                      print('草稿箱动态发布：movingId=' + movingId.toString());
                      if(movingId == 0){
                        showToast('无效ID');
                        return;
                      }
                      final ResponseData resData = await BjuHttp.put(API.republishMoving + movingId.toString())
                        .then((onValue) => ResponseData.fromJson(onValue.data))
                        .catchError((onError){
                          print('草稿箱动态发布请求异常！');
                          print(onError);
                          showToast('请求服务器异常！');
                        });
                      if(resData == null){
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
                  RaisedButton(
                    color: Colors.red[400],
                    child: Text('删除',style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2.0,
                      color: Colors.white,
                    )),
                    onPressed: () async {

                      // showToastWidget(
                      //   CircularProgressIndicator(backgroundColor: Colors.black38),
                      //   context: context,
                      //   duration: Duration(milliseconds: 1500),
                      // );

                      final int movingId = _movingList[index].movingId??0;
                      print('草稿箱删除动态：movingId=' + movingId.toString());
                      if(movingId == 0){
                        showToast('无效ID');
                        return;
                      }
                      final ResponseData resData = await BjuHttp.delete(API.deleteMoving + movingId.toString())
                        .then((onValue) => ResponseData.fromJson(onValue.data))
                        .catchError((onError){
                          print('草稿箱动态删除请求异常！');
                          print(onError);
                          showToast('请求服务器异常！');
                        });
                      if(resData == null){
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
                ],
              ),
            )

          ],
        ),
      );
     }, 
     separatorBuilder: (context,index) => Divider(indent: 2, endIndent: 2,), 
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
        title: Text('草稿箱'),
      ),
      body: _bodyLayout(),
    );
  }
}
