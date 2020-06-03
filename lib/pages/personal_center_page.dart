import 'package:bju_information_app/api/api.dart';
import 'package:bju_information_app/models/response.dart';
import 'package:bju_information_app/models/user.dart';
import 'package:bju_information_app/net/bju_net.dart';
import 'package:bju_information_app/pages/back_management/management.dart';
import 'package:bju_information_app/pages/details/person_info_details.dart';
import 'package:bju_information_app/pages/login_page.dart';
import 'package:bju_information_app/pages/mine/all_moving_page.dart';
import 'package:bju_information_app/pages/mine/draft_moving_page.dart';
import 'package:bju_information_app/pages/mine/safty_setting_page.dart';
import 'package:bju_information_app/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

///
/// 我的
///
class PersonalCenterPage extends StatefulWidget {
  PersonalCenterPage({Key key}) : super(key: key);

  @override
  _PersonalCenterPageState createState() => _PersonalCenterPageState();
}

class _PersonalCenterPageState extends State<PersonalCenterPage> {

  /// 信息页数量统计 countMap={movingCount=37, likeCount=822, atCount=4}
  // Map<String,dynamic> _countsMap = Map<String,dynamic>();





  @override
  void initState() { 
    super.initState();
    
    // _getAllCounts();


  }


  /// 刷新获取用户计数项
  Future<void> _getAllCounts() async {
    // 获取已经登录的用户
    // User user = Provider.of<LoginProvider>(context,listen: false).loginUser;
    // final User user = loginProvider?.loginUser??null;
    final LoginProvider loginProvider = Provider.of<LoginProvider>(context, listen: false);
    print('刷新用户的计数项获得：loginProvider= '+ loginProvider.toString());
    print('获取的用户信息：'+loginProvider?.loginUser?.toString());
    // 获取计数项
    ResponseData resData = await BjuHttp.get(API.allCounts,params: {"userId":(loginProvider?.loginUser?.userId)??0})
      .then((onValue){
        print("***请求数据：");
        print(onValue);
        return ResponseData.fromJson(onValue.data);
      }).catchError((onError){
        print('获取用户计数项异常失败！');
        showToast('请求服务器异常！');
        return;
      });
      // 获取失败
      if(resData != null && resData.statusCode == 1){
        showToast(resData.message);
        return;
      }
      // 获取成功
      if(resData != null && resData.statusCode == 0){
        print('获得刷新用户计数项信息：counts= ' + resData.res.toString());
        // 刷新provider数据
        loginProvider.refreshAllCounts(resData.res);
        print('刷新用户计数项之后：counts= ' + loginProvider?.allCounts?.toString());
        showToast('刷新成功！');
        return;
      }
    //   if(!mounted) return;
    //  setState(() {
    //     _countsMap = resData.res;
    //  });
  }


  /// 退出登陆弹框
  YYDialog _dialog2Logout(BuildContext context, LoginProvider loginProvider) {

    return YYDialog().build(context)
      ..width = 220
      ..borderRadius = 4.0
      ..text(
        padding: EdgeInsets.all(25.0),
        alignment: Alignment.center,
        text: "确定要退出登录吗?",
        color: Colors.black,
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
      )
      ..divider()
      ..doubleButton(
        padding: EdgeInsets.only(top: 10.0),
        gravity: Gravity.center,
        withDivider: true,
        text1: "取消",
        color1: Colors.redAccent,
        fontSize1: 14.0,
        fontWeight1: FontWeight.bold,
        onTap1: () {
          print("取消");
        },
        text2: "确定",
        color2: Colors.redAccent,
        fontSize2: 14.0,
        fontWeight2: FontWeight.bold,
        onTap2: () async {
          print("确定");
          // 退出登录的逻辑
          ResponseData resData = await BjuHttp.post(API.logout)
              .then((onValue) => ResponseData.fromJson(onValue.data))
              .catchError((onError){
                print('退出登录异常了！');
                print(onError);
                showToast('请求服务器异常！');
              });
          if(resData == null){
            showToast('请求失败！');
            return;
          }
          if(resData.statusCode == 1){
            // 提示
            showToast(resData.message);
            return;
          }
          // APP端移除登录信息
          loginProvider.logout();
          print('退出登录后：loginProvider= ' + loginProvider.toString());
          return;
        },
      )
      ..show();
}



  ///
  /// 创建AppBar底部
  ///
  PreferredSize _createAppBarBottom(){

    // 计数项文本样式
    final TextStyle text = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.black54
    );
    // 计数项数字样式
    final TextStyle num = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: Colors.black45,
    ); 

    return PreferredSize(
      preferredSize: Size.fromHeight(20),
      child: Consumer<LoginProvider>(
          builder: (context,loginProvider,_) => Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('动态', style: text,),
                    Text(loginProvider.allCounts?.putIfAbsent('movingCount', ()=> null)?.toString()??'0', style: num,),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('获赞', style: text,),
                    Text(loginProvider.allCounts?.putIfAbsent('likeCount', ()=> null)?.toString()??'0', style: num,),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('@我', style: text,),
                    Text(loginProvider.allCounts?.putIfAbsent('atCount', ()=> null)?.toString()??'0', style: num,),
                  ],
                ),

              ],
            ), 
          ),
    );
  }

  ///
  ///  创建Body
  ///
  Widget _createBody(LoginProvider loginProvider){
    
    return Padding(
        padding: EdgeInsets.only(top:10),
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(FontAwesomeIcons.photoVideo),
              title: Text('所有动态'),
              trailing: Icon(FontAwesomeIcons.chevronRight),
              onTap:(){
                print('所有动态');
                // showToast('开发中...');
                Navigator.push(context, MaterialPageRoute(builder: (context) => AllMovingPage()));
              }
            ),
            Divider(height:5),
            ListTile(
              leading: Icon(FontAwesomeIcons.save),
              title: Text('草稿箱'),
              trailing: Icon(FontAwesomeIcons.chevronRight),
              onTap:(){
                print('草稿箱');
                // showToast('开发中...');
                Navigator.push(context, MaterialPageRoute(builder: (context) => DraftMovingPage()));
              }
            ),
            Divider(height:5),
            ListTile(
              leading: Icon(FontAwesomeIcons.desktop),
              title: Text('后台管理'),
              trailing: Icon(FontAwesomeIcons.chevronRight),
              onTap:(){
                print('后台管理');
                // 获取登录的用户
                final User user = Provider.of<LoginProvider>(context, listen: false).loginUser;
                // 非管理员身份
                if(user.roleId != 2){
                  showToast('非管理员，无法操作！');
                  return;
                }
                Navigator.push(context, MaterialPageRoute(builder: (context) => BackManagement()));
              }
            ),
            Divider(height:5),
            ListTile(
              leading: Icon(FontAwesomeIcons.infoCircle),
              title: Text('应用信息'),
              trailing: Icon(FontAwesomeIcons.chevronRight),
              onTap:(){
                print('关于我们');
                showLicensePage(
                  context: context, 
                  applicationLegalese: '打造属于咱们宝大自己人的校园专属社交APP，尽量满足大家的需求！有关该应用的功能信息方面，有待后续完善，希望大家可以持续关注版本更新，并提出您宝贵的意见与建议！',
                  applicationName: '宝大校园信息服务平台', 
                  applicationVersion: '作者：hzuwei\n版本信息：v1.0\n发布时间：2020-05-27',
                  applicationIcon: Image.asset('assets/icon/bju_app.png',
                    // fit: BoxFit.fill,
                    scale: 16 / 9,
                    width: 50,
                    height: 50,
                  )
                );
              }
            ),
            Divider(height:5),
            ListTile(
              leading: Icon(FontAwesomeIcons.wrench),
              title: Text('安全设置'),
              trailing: Icon(FontAwesomeIcons.chevronRight),
              onTap:(){
                print('安全设置');
                Navigator.push(context, MaterialPageRoute(builder: (context) => SaftySettingPage()));
              }
            ),
            Divider(height:5),
            ListTile(
              leading: Icon(FontAwesomeIcons.powerOff),
              title: Text('退出登录'),
              trailing: Icon(FontAwesomeIcons.chevronRight),
              onTap:(){
                print('退出登录');
                // 弹窗
                _dialog2Logout(context,loginProvider);

              } 
            ),
          ],
        ),
      );

  }


  @override
  Widget build(BuildContext context) {
    
    return Consumer<LoginProvider>(
        builder: (context, loginProvider, child){
         bool isLogin = loginProvider.isLogin; // Test use
         print('登录状态：isLogin=' + isLogin.toString());
        //  bool b = false;
        return  !isLogin ?
          GestureDetector(
            child:  Container(
              decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/background_imgs/bg_personal.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                  child: Text('您还未登录,点击登录！', style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white54,
                    wordSpacing: 2,
                  )),
                ),
              ) ,
              onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()))
            ) : RefreshIndicator(
                child: Scaffold(
                        appBar: PreferredSize(
                          preferredSize: Size.fromHeight(150),
                          child: SafeArea(
                            child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              // 个人信息
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  // 头像
                                  Padding(
                                    padding: EdgeInsets.all(10),
                                    child: ClipOval(
                                       child: FadeInImage.assetNetwork(
                                         placeholder: 'assets/gif/loading.jpg', 
                                         image: API.baseUri+loginProvider.loginUser?.userAvatar??API.defaultAvatarURL, 
                                         fit: BoxFit.fill,
                                         width: 80,
                                         height: 80,
                                       )
                                    ),
                                  ),
                                  // 签名等
                                  Expanded(
                                    child: Row(
                                      mainAxisSize:MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(child: Padding(
                                          padding: EdgeInsets.only(left:5),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(loginProvider.loginUser?.userNickname??'大宝@BJU',style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.lightBlue
                                                ),
                                              ),
                                              SizedBox(height:15),
                                              Text(loginProvider.loginUser?.userMotto??'唯有美食能让我为你心动~~~',),
                                            ],
                                          ),
                                        )
                                      ),
                                        Padding(
                                          padding: EdgeInsets.only(right:20),
                                          child: GestureDetector(
                                          child: Icon(FontAwesomeIcons.userEdit, color: Colors.blue[300]),
                                          onTap: (){
                                            print('用户编辑');
                                            // 传入用户的ID编号
                                            final int userId = loginProvider.loginUser.userId??1;
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => PersonInfoDetailsPage(userId)));
                                            
                                          },
                                        ),
                                        ),
                                        
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // 计数项
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue[200],
                                  borderRadius: BorderRadius.circular(10),
                                  shape: BoxShape.rectangle,
                                ),
                                child:_createAppBarBottom(),
                              ),
                              
                            ],
                          )
                          )
                        ),
                        body: _createBody(loginProvider),
                      ), 
                onRefresh: _getAllCounts,
            );
        },
      );
  }
}


/* 

AppBar(
                title: ListTile(
                  leading: ClipOval(
                    child: Image.asset('assets/avatar/default_avatar.jpg',fit: BoxFit.fill,)
                  ),
                  title: Stack(
                    alignment: AlignmentDirectional.centerStart,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('大宝'),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(FontAwesomeIcons.houseDamage),
                              Text('个人主页')
                            ],
                          ),
                          onTap:(){
                            print('前往个人主页');
                          }
                        ),
                      )
                    ],
                  ),
                  subtitle: Text("唯有美食能让我为你心动~~~"),
                ),
                bottom: _createAppBarBottom(),
              ), 


      */

























/// 旧版个人中心页面
/// 
/* 
 CustomScrollView(
      scrollDirection:  Axis.vertical, //主轴为水平轴 
      slivers:<Widget>[
        SliverAppBar(
          pinned: true, // 固定AppBar，不滑出屏幕
          floating: true,
          snap: true,
          expandedHeight: 250.0,
          flexibleSpace: FlexibleSpaceBar(
              title: const Text('座右铭：用户签名',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white54
                ),
              ),
              background: Image.asset(
                "assets/background_imgs/bg_personal.jpg", fit: BoxFit.cover,
                ),
            ),
          backgroundColor:Theme.of(context).primaryColor,
          /* leading: ClipRRect( // 圆角头像
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/avatar/default_avatar.jpg',
              width: 120,
              height: 120
            )
          ), */
          //title: Text('宝鸡大学信息服务平台'),
          actions: <Widget>[
            FlatButton(onPressed: (){}, child: Icon(Icons.edit))
          ],
        ),
        SliverFixedExtentList(
          itemExtent: 50,
          delegate: SliverChildBuilderDelegate((context,index){
            // get item name
            String item = this._items[index];

              return new Container(
                alignment: Alignment.centerLeft,
                color:Colors.lightBlue,
                margin: EdgeInsets.fromLTRB(2, 2, 2, 0),
                child: new InkWell(
                  onTap: () {
                    print("the is the item of $item");
                  },
                  child: new Column(
                    children: <Widget>[
                      new Padding(
                        padding:
                            const EdgeInsets.all(10),
                        child: new Row(
                          children: <Widget>[
                            new Expanded(
                              child: new Text(
                              item,
                              style: TextStyle(
                               // backgroundColor:Colors.blueAccent,
                                color: Colors.lightGreenAccent,
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              ),
                            )),
                            Icon(Icons.arrow_forward)
                          ],
                        ),
                      ),
                      new Divider(
                        height: 1.0,
                      )
                    ],
                  ),
                ));
          },
          childCount: this._items.length
          )  
          ),
        /* SliverSafeArea(sliver: SliverPadding(
            padding: const EdgeInsets.all(10.0),
            sliver: new SliverGrid( //Grid
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, //Grid按两列显示
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 4.0,
              ),
              delegate: new SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  //创建子widget      
                  return new Container(
                    alignment: Alignment.center,
                    color: Colors.cyan[100 * (index % 9)],
                    child: new Text('grid item $index'),
                  );
                },
                childCount: 40,
              ),
            ),
          ),
          ), */
        
      ]
    ); 
    
    */