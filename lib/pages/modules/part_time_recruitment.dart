import 'package:bju_information_app/api/api.dart';
import 'package:bju_information_app/models/moving.dart';
import 'package:bju_information_app/models/response.dart';
import 'package:bju_information_app/net/bju_net.dart';
import 'package:bju_information_app/pages/details/moving_details.dart';
import 'package:bju_information_app/pages/publish_page.dart';
import 'package:bju_information_app/utils/bju_timeline_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' as SU;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oktoast/oktoast.dart';

///
/// 兼职招聘
/// 2020/04/06 17:32
///
class RecruitmentModule extends StatefulWidget {
  RecruitmentModule({Key key}) : super(key: key);

  @override
  _RecruitmentModuleState createState() => _RecruitmentModuleState();
}

class _RecruitmentModuleState extends State<RecruitmentModule> {

  /// 模块ID编号
  int _moduleId = 4;

  /// 滑动控制器
  ScrollController _scrollController = ScrollController();

  /// 显示编辑按钮
  bool _showEditButton = true;

  /// 兼职招聘模块页面数据列表
  List<Moving> _recruitmentDataList = [];

  @override
  void initState() { 
    super.initState();
    // 为滑动控制器添加监听器
    _scrollController.addListener(_scrollControllerListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 初始化模块页面数据
    _loadModuleData();
  }

  @override
  void dispose() { 
    
    super.dispose();
  }

  /// 滑动控制器的监听器
  void _scrollControllerListener(){
    
    // print('滑动方向：' + _scrollController.position.axis.toString());
    // 获取当前的偏移量
    final double currentOffset = _scrollController.offset;
    // print('兼职招聘，最滚动滑动距离：maxScrollExtent= ' + ( _scrollController.position.maxScrollExtent.toString()));
    // print('兼职招聘，当前滑动位置：currentOffset= ' + currentOffset.toString());
    // 获取设备的Size
    final Size size = MediaQuery.of(context).size;
    // print('兼职招聘，窗口大小：height= ' + (1 * size.height).toString());
    // 判断当前的距离是否滑出第一个页面
    if(currentOffset > (size.height / 2)){
      // 改按钮状态
      if(!mounted) return;
      setState(() {
        _showEditButton = false;
      });
    } else {
       // 改按钮状态
      if(!mounted) return;
      setState(() {
        _showEditButton = true;
      });
    }

  }
  
  Future<void> _loadModuleData() async {
    // 向服务器请求数据信息
    ResponseData resData = await BjuHttp.get(API.queryMovingByModuleId + _moduleId.toString())
          .then((onValue) => ResponseData.fromJson(onValue.data))
          .catchError((onError){
            print('兼职招聘模块请求数据异常！');
            print(onError);
            showToast('请求服务器异常！');
          });
    // if(resData == null){
    //   showToast('网络请求失败！');
    //   return;
    // }
    // 失败响应
    if(resData != null && resData.statusCode == 1){
      showToast(resData.message);
      return;
    }
    if(!mounted) return;
    setState(() {
      // 刷新数据信息
      _recruitmentDataList = (resData.res as List).map<Moving>((m) => Moving.fromJson(m)).toList();
    });
  }

  /// 构建模块体
  Widget _moduleBodyLayout(){
    
    return RefreshIndicator(
      child: _recruitmentDataList.isEmpty 
        ? Center(child: Text('暂无招聘兼职类信息！', style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black38,
              wordSpacing: 2,
            )
          )
        ) 
        : ListView.separated(
          controller: _scrollController,
          itemBuilder: (context,index){

            // 底部左侧数字的样式（赞，浏览，评论）
            final TextStyle bottomCountTextStyle = TextStyle(
              fontSize: 13,
              color: Colors.black38,
            );

            return Card(
              elevation: 4,
              margin: EdgeInsets.fromLTRB(4, 10, 4, index != (_recruitmentDataList.length - 1) ? 0 : 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  // 用户于时间信息
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 8, 5, 0),
                        child: Text('该兼职信息由 ' + _recruitmentDataList[index].movingAuthorName + ' 发布', style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.lightBlue
                        ),),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 11, 5, 0),
                        child: Text(BjuTimelineUtil.formatDateStr(_recruitmentDataList[index].movingCreateTime), style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: Colors.blueGrey[300],
                          //textBaseline: TextBaseline.ideographic
                        ),),
                      )
                    ],
                  ),
                  Divider(color: Colors.blueGrey,),
                  // 信息主体
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Text(_recruitmentDataList[index].movingContent, style: TextStyle(
                      fontSize: 14,
                      // fontWeight: FontWeight.w500,
                      // color: Colors.white54,
                      wordSpacing: 2,
                    ),),
                  ),
                  Divider(),
                  // 底部信息
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      // 左侧（赞，浏览，评论）
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            // 赞
                            Padding(
                              padding: EdgeInsets.fromLTRB(10, 0, 5, 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(right: 2),
                                    child: Icon(FontAwesomeIcons.thumbsUp, size: 14, color: Colors.black38,),
                                  ),
                                  Text(_recruitmentDataList[index].movingLike.toString(), style: bottomCountTextStyle,),
                                ],
                              ),
                            ),
                            // 浏览
                            Padding(
                              padding: EdgeInsets.fromLTRB(2, 0, 5, 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(right: 2),
                                    child: Icon(FontAwesomeIcons.eye, size: 14, color: Colors.black38,),
                                  ),
                                  Text(_recruitmentDataList[index].movingBrowse.toString(), style: bottomCountTextStyle,),
                                ],
                              ),
                            ),
                            // 评论
                            Padding(
                              padding: EdgeInsets.fromLTRB(2, 0, 5, 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(right: 2),
                                    child: Icon(FontAwesomeIcons.comment, size: 14, color: Colors.black38,),
                                  ),
                                  Text(_recruitmentDataList[index].movingCommentCount.toString(), style: bottomCountTextStyle,),
                                ],
                              ),
                            ),

                          ],
                        )
                      ),
                      // 右侧（详情点击）
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        child: GestureDetector(
                          child: Text('查看详情', style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.lightBlue,
                            wordSpacing: 2,
                          ),),
                          onTap: () {
                            final int movingId = _recruitmentDataList[index].movingId??0;
                            // 前往详情页面
                            print('兼职招聘模块前往详情页面: ' + movingId.toString());
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
                      )
                    ],
                  )

                ],
              ),
            );
          }, 
          separatorBuilder: (context,index) => SizedBox(height: SU.ScreenUtil().setHeight(10)), 
          itemCount: _recruitmentDataList.length,
        ),
      onRefresh: _loadModuleData,
    );
  }


  @override
  Widget build(BuildContext context) {

    // 屏幕适配
    SU.ScreenUtil.init(context, width:750,height:1334);
    
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed:(){
          Navigator.of(context).pop();
        }),
        title: Text('兼职招聘'),
      ),
      body: _moduleBodyLayout(),
      // bottomNavigationBar: _bottomNav(),
      floatingActionButton: _showEditButton 
          ? FlatButton(
              color: Colors.lightBlue,
              padding: EdgeInsets.all(12),
              shape: CircleBorder(side: BorderSide(color: Colors.white70)),
              child: Icon(FontAwesomeIcons.solidEdit, color: Colors.white,),
              onPressed: (){
                // 跳转到发布页面
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => PublishPage(4)));
              }, 
          ) 
          : FlatButton(
              color: Colors.lightBlue,
              padding: EdgeInsets.all(12),
              shape: CircleBorder(side: BorderSide(color: Colors.white70)),
              child: Icon(FontAwesomeIcons.arrowUp, color: Colors.white),
              onPressed: (){
                // 返回顶部
                _scrollController.jumpTo(0);
                print('跳转到页面顶部...');
                return;
              }, 
          ), 
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );

  }
}