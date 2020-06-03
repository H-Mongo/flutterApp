import 'package:bju_information_app/api/api.dart';
import 'package:bju_information_app/models/moving.dart';
import 'package:bju_information_app/models/response.dart';
import 'package:bju_information_app/net/bju_net.dart';
import 'package:bju_information_app/pages/details/moving_details.dart';
import 'package:bju_information_app/utils/bju_timeline_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getflutter/components/carousel/gf_carousel.dart';
import 'package:oktoast/oktoast.dart';

///
/// 墙上有你
/// 2020/04/06 17:31
///
class WallModule extends StatefulWidget {
  WallModule({Key key}) : super(key: key);

  @override
  _WallModuleState createState() => _WallModuleState();
}

class _WallModuleState extends State<WallModule> {

  /// 模块ID号 [1：表白墙；2：万能墙]
  int _moduleId = 1;

  /// 页面索引号 [0：表白墙；1：万能墙]
  int _wallType = 0;

  /// 滚动控制器
  ScrollController _wallScrollController = ScrollController();

  /// 数据列表
  List<Moving> _wallDataList = [];


  @override
  void initState() {
    super.initState();
    
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 初始化页面数据
    _loadData();
  }

  @override
  void dispose() { 
    _wallScrollController.dispose();
    super.dispose();
  }


  /// 加载数据列表
  void _loadData() async {
    // 向服务器请求数据
    ResponseData resData = await BjuHttp.get(API.queryMovingByModuleId + _moduleId.toString())
          .then((onValue) => ResponseData.fromJson(onValue.data))
          .catchError((onError){
            print('墙上有你模块请求数据异常！');
            print(onError);
            showToast('请求服务器异常！');
          });
    if(resData == null){
      // showToast('网络请求失败！');
      return;
    }
    // 失败响应
    if(resData != null && resData.statusCode == 1){
      showToast(resData.message);
      return;
    }
    if(!mounted) return;
    setState(() {
      // 刷新数据信息
      _wallDataList = (resData.res as List).map<Moving>((m) => Moving.fromJson(m)).toList();
    });

  }

  /// 加载动画
 void _showLoadding(){
    // 弹出加载框
              showToastWidget(
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.white54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(),
                        SizedBox(height: ScreenUtil().setHeight(6),),
                        Text('加载中...', style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          wordSpacing: 2,
                          color: Colors.lightBlue,
                        ),),
                      ],
                    ),
                  ),
                ),
                duration: Duration(seconds: 3),
                // position: ToastPosition.center,
              );
  }

  /// 底部导航栏
  Widget _bottomNav(){

    // 底部导航的文字样式
    /* final TextStyle bottomNavTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      wordSpacing: 3,
      color: Colors.lightBlue,
    ); */
    return Container(
      width: MediaQuery.of(context).size.width,
      height: ScreenUtil().setHeight(100),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: kElevationToShadow[2],
        borderRadius: BorderRadius.vertical(top:Radius.circular(10)) 
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:[
            Padding(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              child: GestureDetector(
                child: Text('表白墙',style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    wordSpacing: 3,
                    color: _wallType != 0 ? Colors.black54 : Colors.lightBlue,
                    // backgroundColor: Colors.white54,
                  ),
                ),
                onTap: (){
                  if(_wallType == 0){
                    print('点击了表白墙（重复点击时显示）');
                    return;
                  }
                  if(!mounted) return;
                  setState(() {
                    _wallType = 0;
                    _moduleId = 1;
                    print('点击了表白墙：'+_wallType.toString());
                    // 查询数据
                    _loadData();
                  });
                },
                onDoubleTap: (){
                  _showLoadding();
                  // 刷新数据
                  _loadData();
                },
              ),
            ),
            VerticalDivider(indent: ScreenUtil().setHeight(30), endIndent: ScreenUtil().setHeight(30),color: Colors.grey[400],),
            Padding(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              child: GestureDetector(
                child: Text('万能墙',style:  TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    wordSpacing: 3,
                    color: _wallType != 1 ? Colors.black54 : Colors.lightBlue,
                    // backgroundColor: Colors.white54,
                  ),
                ),
                onTap: () async {
                  if(_wallType == 1){
                    print('点击了万能墙（重复点击时显示）');
                    return;
                  }
                  if(!mounted) return;
                  setState(() {
                    _wallType = 1;
                    _moduleId = 2;
                    print('点击了万能墙：'+_wallType.toString());
                    // 查询数据
                    _loadData();

                  });
                },
                onDoubleTap: (){ // 双击刷新
                  _showLoadding();
                  // 请求数据
                  _loadData();
                },
              ),
            ),
        ]
      ),
    );
  }

  /// 图片布局
  Widget _imageLayout(List<String> imageList){
    
    return GFCarousel(
              items: imageList.map(
              (url) {
              return Container(
                margin: EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      width: ScreenUtil().setWidth(1000.0),
                      height: ScreenUtil().setHeight(500.0),
                    ),
                  ),
                );
                },
              ).toList(),
              // onPageChanged: (index) {
              //   setState(() {
              //     index;
              //   });
              // },
          );
  }
  /// 创建页面体
  Widget _buildWallBody(){

    return _wallDataList == null || _wallDataList.length == 0 
        ? Center(child:Text('没有数据可提供！', style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black38,
            wordSpacing: 2,
          ))) 
        : ListView.separated(
            itemBuilder: (context,index){
              return Card(
                elevation: 4,
                margin: EdgeInsets.fromLTRB(4, 4, 4, index != (_wallDataList.length - 1) ? 0 : 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[

                    // 图片区域
                    (_wallDataList[index].movingImages != null && _wallDataList[index].movingImages.length > 0) 
                    ? _imageLayout(_wallDataList[index].movingImages.map<String>((imgUrl) => (API.baseUri + imgUrl)).toList())
                    : SizedBox(),

                  // 文本内容
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 4, 8, 0),
                    child: Text(
                      _wallDataList[index].movingContent,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        wordSpacing: 2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  ),
                  Divider(),
                  // 作者信息等
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(padding: EdgeInsets.only(left: 8, right: 5, bottom: 5),child: Text(_wallDataList[index].movingAuthorName),),
                            Padding(
                              padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                              child: Text(BjuTimelineUtil.formatDateStr(_wallDataList[index].movingCreateTime), style: TextStyle(
                                color: Colors.black38,
                              ),),
                            )
                          ],
                        )
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8, right: 20, bottom: 5),
                        child: GestureDetector(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('查看详情', style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.lightBlue,
                                    wordSpacing: 2,
                                ),
                              ),
                              Icon(FontAwesomeIcons.angleDoubleRight, color: Colors.lightBlue,size: 16,)
                            ],
                          ),
                          onTap: (){
                            print('墙上有你前往详情页面：' + _wallDataList[index].movingId.toString());
                            final int movingId = _wallDataList[index].movingId;
                            if(movingId == 0){
                              print('跳转的动态ID不存在!');
                              showToast('动态信息有误！');
                              return;
                            }
                            // 跳转到动态详情页面
                            Navigator.push<Map<String,int>>(context, MaterialPageRoute(builder: (context)=> MovingDetailsPage(movingId) ));
                            return;
                          },
                        ),
                      ),
                    ],
                  )


                  ],
                ),
              );
            }, 
            separatorBuilder: (context,index){
              return SizedBox(height: ScreenUtil().setHeight(10));
            }, 
            itemCount: _wallDataList.length
    );
  }

  @override
  Widget build(BuildContext context) {

    // 屏幕适配
    ScreenUtil.init(context, width:750,height:1334);
    
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed:(){
          Navigator.of(context).pop();
        }),
        title: Text('墙上有你'),
      ),
      body: _buildWallBody(),
      bottomNavigationBar: _bottomNav(),
    );
  }
}