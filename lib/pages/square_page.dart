import 'package:badges/badges.dart';
import 'package:bju_information_app/api/api.dart';
import 'package:bju_information_app/models/moving.dart';
import 'package:bju_information_app/models/response.dart';
import 'package:bju_information_app/net/bju_net.dart';
import 'package:bju_information_app/pages/details/moving_details.dart';
import 'package:bju_information_app/pages/search_page.dart';
import 'package:bju_information_app/utils/bju_timeline_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getflutter/getflutter.dart';
import 'package:oktoast/oktoast.dart';


class SquarePage extends StatefulWidget {
  SquarePage({Key key}) : super(key: key);

  @override
  _SquarePageState createState() => _SquarePageState();
}

class _SquarePageState extends State<SquarePage> with SingleTickerProviderStateMixin{

  /// tab控制器 
  TabController _tabController;

  /// 默认头像地址
  //String _defaultAvatar = 'http://kc4c7m.natappfree.cc/bjuInformationService/static/avatars/default_avatar.jpg';

  /// tab item 
  final List<Widget> _tabs = [
   _createTab(Icon(Icons.fiber_new), '最新'),
   _createTab(Icon(FontAwesomeIcons.fire),'热门'),
  ];

  /// 动态列表
  List<Moving> _movingList;
  
  
  @override
  void initState() { 
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener((){
      print(_tabController.index);
      // 加载框
      showToastWidget(
        CircularProgressIndicator(backgroundColor: Colors.black38),
        context: context,
        duration: Duration(milliseconds: 3000),
        position: ToastPosition.center,
      );
      this._getMovingsWithTabIndex(_tabController.index);
    });
    
    
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    this._getMovingsWithTabIndex(_tabController.index);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }


  ///
  /// ##### 获取动态列表（依据tab的index属性确定：最新or最热）
  /// * [index] tab的index切换与否
  ///
  Future _getMovingsWithTabIndex(int index) async {

      print('当前索引为：');
      print(index);
      ResponseData resData = await BjuHttp.get(index == 0 ? API.newMoving : API.hotMoving)
                                      .then((onValue) => ResponseData.fromJson(onValue.data))
                                      .catchError((onError){
                                        print("获取动态出错了！");
                                        print(onError);
                                        showToast('请求服务器异常！');
                                        return;
                                      });
          if(resData != null && resData.statusCode == 0){
            print("获取的动态为：$resData");
            // _movingList = Moving.fromJson(resData.res);
            if(!mounted) return;
            setState(() {
              print('返回类型为');
              print(resData.res?.runtimeType);
              _movingList =  (resData.res as List<dynamic>).map<Moving>((moving){
                                    return Moving.fromJson(moving);
                                  }).toList();
            });
            print("包装的Moving列表为："+_movingList.toString());
          }

  }



  ///
  /// 构建Tabs
  ///
  static Widget _createTab(Icon icon, String tabName){
    return Tab(
              //icon: icon,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  icon,
                  Text(
                    tabName,
                  )
                ],
              ),
            );
  }

  ///
  ///  前往详情页面
 Future<void> _gotoMovingDetails(int index) async {

    // 获取当前点击的动态ID
    final int movingId =_movingList[index]?.movingId??0;
    if(movingId == 0){
      print('跳转的动态ID不存在!');
      showToast('动态信息有误！');
      return;
    }

  //网络请求浏览量刷新
  // ResponseData resData = await BjuHttp.put(API.updateBrowseCount,params: {"movingId": movingId})
  //       .then((onValue) => ResponseData.fromJson(onValue.data))
  //       .catchError((onError){
  //         print('更新动态浏览量数据请求异常！');
  //         showToast('请求服务器异常！');
  //       });
  //   // 打印请求的结果
  //   print(resData.message);
        
    print('进入用户动态详情页面: movingId='+movingId.toString());
    // 跳转到动态详情页面，返回时自动修改当前动态中的数据（点赞量，浏览量，评论量）
    final Map<String,int> countsMap = await Navigator.push<Map<String,int>>(context, MaterialPageRoute(builder: (context)=> MovingDetailsPage(movingId) ));
    print('获得返回的数据为：countsMap= ' + countsMap.toString());
    return;

    
    // 修改当前动态的数据



  }


  ///
  /// 创建TabBarView
  ///
  Widget _crateTabBarView(){

    // 测试的图片数据
    // List<String> imgs = [];
    
    return _movingList == null ? Center(
      child: Text('没有动态信息！', style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black38,
                wordSpacing: 2,
              )
            )
          ) : ListView.separated(

      itemBuilder: (context,index){
       /*  return Container(
          width: ScreenUtil.mediaQueryData.size.width,
          //height: ScreenUtil().setHeight(50),
          padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
          decoration: BoxDecoration(
            color: Colors.orangeAccent, // 底色
            borderRadius: BorderRadius.circular(10), // 边界圆角半径
            border: Border.all(
              color: Colors.white, // 边框颜色
              //width: 3, // 边框宽度
            )
          ),
          child: 
        ); */
    // final List<String> _topics = ['女神','小仙女','男神','二次元','小姐姐','小哥哥'];
        final List<String> _topics = _movingList[index].movingTopics;
        final List<String> imgs = _movingList[index].movingImages;
        return Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
          margin: EdgeInsets.fromLTRB(5,0,5,index != _movingList.length-1 ? 0:10),
          child: Column(
              mainAxisSize: MainAxisSize.min, // 实际高度为所有子元素的高度和
              //mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start, // 水平对齐方式
              children: <Widget>[
                // 动态发布者信息
                ListTile(
                  leading: ClipOval(
                     child:FadeInImage.assetNetwork(
                        placeholder: 'assets/gif/loading.jpg', 
                        image: API.baseUri+_movingList[index].movingAuthorAvatar??API.defaultAvatarURL, 
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                    )
                  ),
                  title: GestureDetector(
                    child: Text(_movingList[index].movingAuthorName??'芒果A',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: Colors.lightBlue,
                      ),
                    ),
                    onTap: (){
                        // 进入用户详情页面
                    },
                  ),
                  subtitle: Text(BjuTimelineUtil.formatDateStr(_movingList[index].movingCreateTime)??'无效时间'),
                ),
                //Divider(),
                // 动态文本内容
                Padding(
                  padding: EdgeInsets.only(left:5,right:3),
                  child: Text(_movingList[index].movingContent??
                    '今天天气很棒，晴空万里！飞机划过天空留下了一条优美的掠影，仿佛在向我们示意它要去何方？希望疫情快点结束，我从未向现在这样渴望上学过。中国加油，武汉加油！',
                    textAlign: TextAlign.start,
                  ),
                ),
                // 图片信息
                (imgs != null && imgs.length > 0) ? GridView.count(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(2), // 内边距
                    crossAxisCount: 3, // 列
                    mainAxisSpacing: 2, // 纵向间距
                    crossAxisSpacing: 2, // 水平间距
                    //childAspectRatio: 16 / 9, // 宽高比，默认1.0
                    children:imgs.map((img) => FadeInImage.assetNetwork(placeholder: 'assets/gif/loading.jpg', image: API.baseUri + img, fit: BoxFit.fill,)).toList(),
                  ) : SizedBox(),
                Divider(),
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
                      // flex: 6,
                      child: Padding(
                        padding: EdgeInsets.all(3),
                        child: _topics == null ? Text("没有标签信息！") : Wrap(
                          spacing: 1,
                          runAlignment: WrapAlignment.center,
                          children: _topics.map((t){
                            return ChoiceChip(
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
                              );
                          }).toList(),
                        ),
                      ),
                    )
                  ],
                ),
                Divider(),
                // 操作
                Row(
                  mainAxisSize:MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 5),child: GestureDetector(
                      child:Badge(
                        alignment:Alignment.topRight ,
                        badgeContent: Text(_movingList[index].movingLike?.toString()??'0'),
                        child: Icon(FontAwesomeIcons.solidThumbsUp), 
                      ),
                      onTap: (){
                        print('朋友圈-->点赞');
                        // 动态详情页面
                        _gotoMovingDetails(index);
                        return;
                      },
                    ),),
                  Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 5),child: GestureDetector(
                      child: Badge(
                        badgeContent: Text(_movingList[index].movingBrowse?.toString()??'0'),
                        child: Icon(FontAwesomeIcons.eye), 
                      ),
                      onTap: (){
                        print('朋友圈-->浏览');
                        // 动态详情页面
                        _gotoMovingDetails(index);
                        return;
                      },
                    ),),

                    Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 5),child: GestureDetector(
                      child: Badge(
                        badgeContent: Text(_movingList[index].movingCommentCount?.toString()??'0'),
                        child: Icon(FontAwesomeIcons.commentDots), 
                      ),
                      onTap: (){
                        print('朋友圈-->评论');
                        // 动态详情页面
                        _gotoMovingDetails(index);
                        return;
                      },
                    ),)


                  ],
                )
                
              ],
            ),
        );
      }, 
      separatorBuilder: (context,index){
        // 元素间的分割区
        // return SizedBox(height: 10,child: Divider(height: ScreenUtil().setHeight(10),));
        return SizedBox(height: ScreenUtil().setHeight(10),);
      }, 
      itemCount: _movingList.length,
      
    );
  }

  ///
  /// 创建Body
  ///
  Widget _createBody(){
    return GFTabs(
      tabBarColor:Colors.white,
      labelColor: Colors.orangeAccent,
      controller: _tabController,
      initialIndex: 0,
      length: 2,
      tabs: _tabs,
      tabBarView: GFTabBarView(
        children: <Widget>[
          
         _crateTabBarView(),
         _crateTabBarView()

         
        ],
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 初始化屏幕大小用于适配
    ScreenUtil.init(context, width:750,height:1334);

    return Material(
        child:/*  DefaultTabController(
        length: _tabs.length, 
        child:  */NestedScrollView(
          headerSliverBuilder: (context, b){
            return <Widget>[
              SliverAppBar(
                floating: true,
                pinned: true,
                leading: BackButton(onPressed: () => Navigator.of(context).pop(),),
                title: ListTile(
                  title: Text('校园朋友圈'),
                  trailing: GestureDetector(
                    child: Icon(FontAwesomeIcons.search),
                    onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage())),
                  ),
                ),
                centerTitle:true,
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(ScreenUtil().setHeight(89)),
                  child: TabBar(
                    indicatorColor:Colors.white,
                    tabs: _tabs,
                    controller: _tabController,
                  ), 
                ),
                /* expandedHeight: 100, */
              )
            ];
          }, 
          body: TabBarView(
            controller: _tabController,
            children: [
              _crateTabBarView(),// new
              _crateTabBarView(),// hot
            ]),
        )
      // ),
    );
  }
}
/* 
 Scaffold(
      appBar: AppBar(
        //leading: Text('图标'),
        title: Text('校园朋友圈'),
        actions: <Widget>[
          GestureDetector(
            child: Icon(Icons.search),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder:(context) => SearchPage())),
          )
        ],
      ),
      body: _createBody(),
  ); */