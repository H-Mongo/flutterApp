import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:bju_information_app/api/api.dart';
import 'package:bju_information_app/models/comment.dart';
import 'package:bju_information_app/models/moving.dart';
import 'package:bju_information_app/models/response.dart';
import 'package:bju_information_app/models/user.dart';
import 'package:bju_information_app/net/bju_net.dart';
import 'package:bju_information_app/pages/at_choose_page.dart';
import 'package:bju_information_app/providers/login_provider.dart';
import 'package:bju_information_app/utils/bju_timeline_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getflutter/components/avatar/gf_avatar.dart';
import 'package:getflutter/shape/gf_avatar_shape.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

///
/// 动态详情页面
/// 2020/2/23 21:24
///
///
class MovingDetailsPage extends StatefulWidget {

  // 动态ID
  int _movingId;

  MovingDetailsPage(this._movingId,{Key key}) : super(key: key);

  @override
  _MovingDetailsPageState createState() => _MovingDetailsPageState(this._movingId,);
}

class _MovingDetailsPageState extends State<MovingDetailsPage> with WidgetsBindingObserver{

  /// 动态ID
  int _movingId;

  /// 页面的key
  GlobalKey _movingDetialskey = GlobalKey();

  /// 评论框是否弹出
  bool _isShowCommentSheet = false;
  
  /// 动态详情 
  MovingDetails _movingDetails;

  /// 滚动控制器
  ScrollController _scrollController = ScrollController();

  /// 评论文本控制器
  TextEditingController _commentTextController = TextEditingController();

  /// 键盘的监听

  /// 评论文本焦点
  FocusNode _commentFocusNode = FocusNode();

  /// 评论内容
  String _commentContent = '';

  /// 评论内容为空
  bool _commentContentIsEmpty = true;

  /// @ 用户列表：[{'nickname':大宝,'phone':18700970123}]
  List<Map<String,String>> _atList = [];

  /// 父评论ID
  int _parentCommentId = 0;

  /// 评论信息推送的别名
  String _commentPhone = '';




  _MovingDetailsPageState(this._movingId);

  @override
  void initState() {
    super.initState();

    // 监听自己
    WidgetsBinding.instance.addObserver(this);

    // 初始化
    _commentTextController.addListener(_commentListener);

    // 获取用户动态详情信息
    _getMovingDetailsById();
    
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // 监听键盘是否收起
    WidgetsBinding.instance.addPostFrameCallback((_){
      print('监听页面底部的弹出高度，上下文对象：' + context.toString());
      // 上下文不存在
      if(context == null) return;
      // 键盘弹起的高度
      final double bottom =  MediaQuery.of(context).viewInsets.bottom;
      print('监听页面底部的弹出高度' + bottom.toString());
      if(!(bottom > 0) && _isShowCommentSheet){
        // pop 弹出的评论框输入层
        Navigator.of(context).pop();
        if(!mounted) return;
        // 评论弹出层显示为false
        setState(() {
          _isShowCommentSheet = false;
          print('评论弹出框关闭...' + _isShowCommentSheet.toString());
        });
        print('pop 评论框弹出层');
      }
    });
  }

  @override
  void dispose() { 
    super.dispose();

    _commentTextController.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();
    // 销毁监听
    WidgetsBinding.instance.removeObserver(this);

  }

  



  ///
  /// 评论文本监听器
 void _commentListener(){

    // 评论内容是否为空，用于控制发送按钮
    // if(_commentTextController.text.trim().length > 0){
    //   if(!mounted) return;
    //     setState(() {
    //       _commentContentIsEmpty = false;
    //     });
    // }


  }


  /// 用户实时追加@信息
  void _appendAtInfo(){
    // 添加 @ 的用户
    if(_atList?.isNotEmpty??false){
      // 最新at的用户
      final Map<String, String> atMap = _atList.last;
      if(atMap == null) return;
      // 构造艾特字符串
      final String appendAtString = '@'+atMap.putIfAbsent('nickname', ()=> '艾特无效')+' ';
      _commentTextController.text += appendAtString;
      return;
    }
  }


  ///
  /// 获取动态详情（ID）
  ///
  Future<void> _getMovingDetailsById() async {

    // 请求服务器，获取动态的详情信息
    ResponseData resData = await BjuHttp.get(API.movingDetailsById+_movingId.toString())
      .then((onValue) => ResponseData.fromJson(onValue.data))
      .catchError((onError){
        print('获取动态详情出错了！');
        print(onError);
        showToast('请求服务器异常！');
        return;
      });
    // 请求失败
    if(resData == null) return;
    // 失败
    if(resData.statusCode != 0){
      print('获取详情信息失败！');
      showToast(resData.message);
      return;
    }
    print('获取的动态详情信息为：res= ' + resData.res.toString());
    if(!mounted) return;
    setState(() {
     _movingDetails = MovingDetails.fromJson(resData.res);
     print('获取的动态详情信息为：_movingDetails= ' + _movingDetails.toString());
    });
    return;

  }  

  /// 动态主体信息布局
  Widget _movingContextLayout(){

    // 获取登录的用户信息
    final User user = Provider.of<LoginProvider>(context, listen: false).loginUser;

    return ListView(
          shrinkWrap: true,
          // mainAxisSize: MainAxisSize.max,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 发布时间与地点
            // Text(_movingDetails.movingCreateTime+' '+_movingDetails.movingAuthorName+'发布于：中国-陕西-宝鸡'),
            // 详情显示的头部信息
            // Card(
            //   elevation: 4,
            //   // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),),
            //   // color: Colors.amber,
            //   child: ,
            // ),

            Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  // 昵称
                  Padding(
                    padding: EdgeInsets.fromLTRB(15, 10, 0, 5),
                    child: Text(_movingDetails.movingAuthorName, style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      wordSpacing: 2,
                      // height: 1.5,
                      color: Colors.lightBlue,
                    )),
                  ),
                  // 时间
                  Padding(
                    padding: EdgeInsets.fromLTRB(15, 10, 0, 5),
                    child: Text(BjuTimelineUtil.formatDateStr(_movingDetails.movingCreateTime) + '发布', style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      wordSpacing: 2,
                      height: 1.5,
                      color: Colors.black54,
                    )),
                  ),

                ],
              ),

            // 动态内容
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),),
              margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Padding(
                padding: EdgeInsets.fromLTRB(5, 8, 0, 0),
                child: Text(_movingDetails.movingContent??'动态的内容',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    wordSpacing: 2.5,
                    height: 1.5,
                  ),
                ),
              )
                
            ),
            // 图片信息
            (_movingDetails.movingImages != null && _movingDetails.movingImages.length > 0) 
            ?  Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: GridView.count(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(2), // 内边距
                    crossAxisCount: 3, // 列
                    mainAxisSpacing: 2, // 纵向间距
                    crossAxisSpacing: 2, // 水平间距
                    //childAspectRatio: 16 / 9, // 宽高比，默认1.0
                    children:_movingDetails.movingImages.map((img) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/gif/loading.jpg', 
                        image: API.baseUri + img, 
                        fit: BoxFit.fill,
                      ),
                    ) ).toList(),
                  ),)
            : SizedBox(),

            // 动态类型及标签
            Padding(
              padding: EdgeInsets.fromLTRB(5, 8, 5, 0),
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(_movingDetails.movingType??'错误墙',style: TextStyle(
                        fontSize: 15,
                        color: Colors.lightBlue[600],
                        fontWeight: FontWeight.w500,
                      ),),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: _movingDetails.movingTopics == null ? Text("没有标签信息！") : Wrap(
                          spacing: 1,
                          runAlignment: WrapAlignment.center,
                          children: _movingDetails.movingTopics.map((t){
                            return ChoiceChip(
                                // avatar: Icon(FontAwesomeIcons.heart),
                                selectedColor: Colors.lightBlue[400], // 选中时的颜色
                                label: Text(t,
                                  style: TextStyle(
                                    color: Colors.white,
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
            ),
            Divider(),
            // 操作
            Padding(
              padding: EdgeInsets.fromLTRB(5, 0, 5, 8),
              child: Row(
                  mainAxisSize:MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[

                    // 浏览量
                    GestureDetector(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 5, 8, 5), 
                            child: Icon(FontAwesomeIcons.eye, color: Colors.lightBlue[400],),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 5, 0, 5), 
                            child: Text((_movingDetails.movingBrowse??0).toString()),
                          ),
                          ],
                        ),
                      onTap: (){
                        print('浏览');

                      },
                    ),

                    // 点赞
                    GestureDetector(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 5, 8, 5), 
                            child: Icon(FontAwesomeIcons.solidThumbsUp, 
                              color: _movingDetails.movingLikeUsers?.contains(user?.userId.toString()??0)??false
                                ? Colors.lightBlue[400] : Colors.black38,
                              ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 5, 0, 5), 
                            child: Text(_movingDetails.movingLike?.toString()??'0'),
                          ),
                          ],
                        ),
                      onTap: _movingDetails.movingLikeUsers?.contains(user?.userId.toString()??0)??false ? null : () async {
                        // print('用户的点赞用户列表数据为: ');
                        // print((_movingDetails.movingLikeUsers??[]));
                        // return;
                        print('动态点赞');
                        if( user == null){
                          print('点赞失败，用户未登录');
                          showToast('请先登录！');
                          return;
                        }
                        // 已经点击过点赞按钮
                        if(_movingDetails.movingLikeUsers?.contains(user?.userId.toString())??false){
                          return;
                        }
                        final Map<String,dynamic> paramsMap = {
                          "movingId": _movingDetails.movingId,
                          "content" : _movingDetails.movingContent,
                          "alias" : _movingDetails.movingAuthorPhone,
                          "likeUserId": user.userId,
                          "likeUserNickname" : user.userNickname,
                          "likeUserAvatar" : user.userAvatar
                        };
                        // 请求服务器刷新数据
                        ResponseData resData = await BjuHttp.put(API.updateMovingLikeData, 
                          params: paramsMap
                        ).then((onValue) => ResponseData.fromJson(onValue.data))
                        .catchError((onError){
                          print('用户点赞请求异常！');
                          print(onError);
                          showToast('请求服务器异常');
                          return;
                        });
                        if(resData == null){
                          showToast('网络错误！');
                          return;
                        }
                        if(resData.statusCode == 0){
                          if(!mounted) return;
                          setState(() {
                            _movingDetails.movingLike += 1;
                            // 新的点赞列表
                            final List<String> newUserList = _movingDetails.movingLikeUsers??[];
                            newUserList.add(user.userId.toString());
                            _movingDetails.movingLikeUsers = newUserList;
                          });
                            print('点赞过后，动态的点赞量为：' + _movingDetails.movingLike.toString() + ' 动态的点赞用户列表为：' + _movingDetails.movingLikeUsers.toString());
                        }
                        // 弹出提示信息
                        showToast(resData.message);

                      },
                    ),

                    // 评论
                    GestureDetector(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 5, 8, 5), 
                            child: Icon(FontAwesomeIcons.commentDots, color: (_movingDetails.commentReplyList?.length??0) > 0 ? Colors.lightBlue[400] : Colors.black38,),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 5, 0, 5), 
                            child: Text(_movingDetails.commentReplyList?.length?.toString()??'0'),
                          ),
                          ],
                        ),
                      onTap: (){
                        print('评论');
                         // 用户登录与否
                        if(user == null){
                          showToast('请先登录！');
                          return;
                        }
                        // 获取当前上下文
                        final BuildContext currentContext = _movingDetialskey?.currentContext??context;;
                        // 弹出评论输入框区域
                        _showCommentWindow(currentContext,user);
                        
                      },
                    ),
                  ],
                ),
            ),
              
              Container(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 8, 0, 8),
                      child: Text('全部评论如下', style: TextStyle(
                          fontSize: 16,
                          wordSpacing: 4,
                          fontWeight: FontWeight.w600,
                          color: Colors.lightBlue[300],
                        ),
                      ),
                    ),
                    // 右侧图标
                    Icon(FontAwesomeIcons.ellipsisV, color: Colors.lightBlue[300],)
                  ],
                ),
              ),
              Divider(color: Colors.blueGrey[200]),
        ]
    );

  }

  ///
  /// 创建详情页body部分
  ///
  // Widget _buildBody(){

  //   // 获取登录的用户信息
  //   final User user = Provider.of<LoginProvider>(context, listen: false).loginUser;

  //   return _movingDetails == null ? Center(child: Text('动态详情获取失败！')) : RefreshIndicator(
  //       // controller: _scrollController,
  //       child: ListView(
  //         // mainAxisSize: MainAxisSize.max,
  //         // mainAxisAlignment: MainAxisAlignment.center,
  //         children: <Widget>[
  //           // 发布时间与地点
  //           // Text(_movingDetails.movingCreateTime+' '+_movingDetails.movingAuthorName+'发布于：中国-陕西-宝鸡'),
  //           // 详情显示的头部信息
  //           // Card(
  //           //   elevation: 4,
  //           //   // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),),
  //           //   // color: Colors.amber,
  //           //   child: ,
  //           // ),

  //           Row(
  //               mainAxisSize: MainAxisSize.max,
  //               mainAxisAlignment: MainAxisAlignment.start,
  //               children: <Widget>[
  //                 // 昵称
  //                 Padding(
  //                   padding: EdgeInsets.fromLTRB(15, 10, 0, 5),
  //                   child: Text(_movingDetails.movingAuthorName, style: TextStyle(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.w600,
  //                     wordSpacing: 2,
  //                     // height: 1.5,
  //                     color: Colors.lightBlue,
  //                   )),
  //                 ),
  //                 // 时间
  //                 Padding(
  //                   padding: EdgeInsets.fromLTRB(15, 10, 0, 5),
  //                   child: Text(BjuTimelineUtil.formatDateStr(_movingDetails.movingCreateTime) + '发布', style: TextStyle(
  //                     fontSize: 12,
  //                     fontWeight: FontWeight.w300,
  //                     wordSpacing: 2,
  //                     height: 1.5,
  //                     color: Colors.black54,
  //                   )),
  //                 ),

  //               ],
  //             ),

  //           // 动态内容
  //           Card(
  //             elevation: 0,
  //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),),
  //             margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
  //             child: Padding(
  //               padding: EdgeInsets.fromLTRB(5, 8, 0, 0),
  //               child: Text(_movingDetails.movingContent??'动态的内容',
  //                 style: TextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.w400,
  //                   wordSpacing: 2.5,
  //                   height: 1.5,
  //                 ),
  //               ),
  //             )
                
  //           ),
  //           // 图片信息
  //           (_movingDetails.movingImages != null && _movingDetails.movingImages.length > 0) 
  //           ?  Padding(
  //                 padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
  //                 child: GridView.count(
  //                   shrinkWrap: true,
  //                   padding: EdgeInsets.all(2), // 内边距
  //                   crossAxisCount: 3, // 列
  //                   mainAxisSpacing: 2, // 纵向间距
  //                   crossAxisSpacing: 2, // 水平间距
  //                   //childAspectRatio: 16 / 9, // 宽高比，默认1.0
  //                   children:_movingDetails.movingImages.map((img) => ClipRRect(
  //                     borderRadius: BorderRadius.circular(8),
  //                     child: Image.network(API.baseUri + img,fit: BoxFit.fill,),
  //                   ) ).toList(),
  //                 ),)
  //           : SizedBox(),

  //           // 动态类型及标签
  //           Padding(
  //             padding: EdgeInsets.fromLTRB(5, 8, 5, 0),
  //             child: Row(
  //                 mainAxisSize: MainAxisSize.max,
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 // crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: <Widget>[
  //                   Padding(
  //                     padding: EdgeInsets.only(left: 10),
  //                     child: Text(_movingDetails.movingType??'错误墙',style: TextStyle(
  //                       fontSize: 15,
  //                       color: Colors.lightBlue[600],
  //                       fontWeight: FontWeight.w500,
  //                     ),),
  //                   ),
  //                   Expanded(
  //                     child: Padding(
  //                       padding: EdgeInsets.all(5),
  //                       child: _movingDetails.movingTopics == null ? Text("没有标签信息！") : Wrap(
  //                         spacing: 1,
  //                         runAlignment: WrapAlignment.center,
  //                         children: _movingDetails.movingTopics.map((t){
  //                           return ChoiceChip(
  //                               // avatar: Icon(FontAwesomeIcons.heart),
  //                               selectedColor: Colors.white24, // 选中时的颜色
  //                               label: Text(t,
  //                                 style: TextStyle(
  //                                   color: Colors.orange[100],
  //                                   fontSize: 12,
  //                                   fontWeight: FontWeight.w300
  //                                 ),
  //                               ), 
  //                               selected: true,
  //                             );
  //                         }).toList(),
  //                       ),
  //                     ),
  //                   )
  //                 ],
  //               ),
  //           ),
  //           Divider(),
  //           // 操作
  //           Padding(
  //             padding: EdgeInsets.fromLTRB(5, 0, 5, 8),
  //             child: Row(
  //                 mainAxisSize:MainAxisSize.max,
  //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                 children: <Widget>[

  //                   // 浏览量
  //                   GestureDetector(
  //                     child: Row(
  //                       mainAxisSize: MainAxisSize.min,
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: <Widget>[
  //                         Padding(
  //                           padding: EdgeInsets.fromLTRB(0, 5, 8, 5), 
  //                           child: Icon(FontAwesomeIcons.eye, color: Colors.black38,),
  //                         ),
  //                         Padding(
  //                           padding: EdgeInsets.fromLTRB(0, 5, 0, 5), 
  //                           child: Text(((_movingDetails.movingBrowse??0) + 1).toString()),
  //                         ),
  //                         ],
  //                       ),
  //                     onTap: (){
  //                       print('浏览');

  //                     },
  //                   ),

  //                   // 点赞
  //                   GestureDetector(
  //                     child: Row(
  //                       mainAxisSize: MainAxisSize.min,
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: <Widget>[
  //                         Padding(
  //                           padding: EdgeInsets.fromLTRB(0, 5, 8, 5), 
  //                           child: Icon(FontAwesomeIcons.solidThumbsUp, 
  //                             color: _movingDetails.movingLikeUsers.contains(user?.userId??0) 
  //                               ? Colors.redAccent[400] : Colors.black38,
  //                             ),
  //                         ),
  //                         Padding(
  //                           padding: EdgeInsets.fromLTRB(0, 5, 0, 5), 
  //                           child: Text(_movingDetails.movingLike?.toString()??'0'),
  //                         ),
  //                         ],
  //                       ),
  //                     onTap: _movingDetails.movingLikeUsers.contains(user?.userId??0) ? null : () async {
  //                       print('点赞');
  //                       if( user == null){
  //                         print('点赞失败，用户未登录');
  //                         showToast('请先登录！');
  //                       }
  //                       // 请求服务器刷新数据
  //                       ResponseData resData = await BjuHttp.put(API.updateMovingLikeData, 
  //                         params: {"movingId": _movingDetails.movingId,"likeUserId": user.userId}
  //                       ).then((onValue) => ResponseData.fromJson(onValue.data))
  //                       .catchError((onError){
  //                         print('用户点赞请求异常！');
  //                         print(onError);
  //                         showToast('请求服务器异常');
  //                       });
  //                       if(resData == null){
  //                         return;
  //                       }
  //                       // 弹出提示信息
  //                       showToast(resData.message);

  //                     },
  //                   ),

  //                   // 评论
  //                   GestureDetector(
  //                     child: Row(
  //                       mainAxisSize: MainAxisSize.min,
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: <Widget>[
  //                         Padding(
  //                           padding: EdgeInsets.fromLTRB(0, 5, 8, 5), 
  //                           child: Icon(FontAwesomeIcons.commentDots, color: Colors.black38,),
  //                         ),
  //                         Padding(
  //                           padding: EdgeInsets.fromLTRB(0, 5, 0, 5), 
  //                           child: Text(_movingDetails.commentReplyList.length?.toString()??'0'),
  //                         ),
  //                         ],
  //                       ),
  //                     onTap: (){
  //                       print('评论');
  //                        // 用户登录与否
  //                       if(user == null){
  //                         showToast('请先登录！');
  //                         return;
  //                       }
  //                       // 获取当前上下文
  //                       final BuildContext currentContext = _movingDetialskey?.currentContext??context;;
  //                       // 弹出评论输入框区域
  //                       _showCommentWindow(currentContext,user);
                        
  //                     },
  //                   ),
  //                 ],
  //               ),
  //           ),
              
  //             Container(
  //               child: Row(
  //                 mainAxisSize: MainAxisSize.max,
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 children: <Widget>[
  //                   Padding(
  //                     padding: EdgeInsets.fromLTRB(10, 8, 0, 8),
  //                     child: Text('全部评论如下', style: TextStyle(
  //                         fontSize: 16,
  //                         wordSpacing: 4,
  //                         fontWeight: FontWeight.w600,
  //                         color: Colors.lightBlue[300],
  //                       ),
  //                     ),
  //                   ),
  //                   // 右侧图标
  //                   Icon(FontAwesomeIcons.ellipsisV, color: Colors.lightBlue[300],)
  //                 ],
  //               ),
  //             ),
  //             Divider(color: Colors.blueGrey[200]),
  //             ListView.separated(
  //               shrinkWrap: true,
  //               itemBuilder: (context,index){
  //                   // 字体样式
  //                   final TextStyle nicknameStyle = TextStyle(
  //                     color: Colors.white54,
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.w600
  //                   );
  //                   final TextStyle timeStyle = TextStyle(
  //                     color: Colors.white54,
  //                     fontSize: 12,
  //                     fontWeight: FontWeight.w100
  //                   );   
  //                   return ListTile( // 评论
  //                     leading: CircleAvatar(
  //                       child: Image.network(API.baseUri + _movingDetails.commentReplyList[index].commentAuthorAvatar),
  //                       //radius: 10,
  //                     ),
  //                     title: Text(_movingDetails.commentReplyList[index].commentAuthorName, style: nicknameStyle,),
  //                     subtitle: _movingDetails.commentReplyList[index].parentCommentId == null
  //                      ? Wrap(
  //                         spacing: 1.0,
  //                         children: <Widget>[
  //                           Text(_movingDetails.commentReplyList[index].commentContent),
  //                           Text(_movingDetails.commentReplyList[index].commentCreateTime, style: timeStyle,)
  //                         ],
  //                       )
  //                      : ListTile( // 父评论
  //                       leading: CircleAvatar(
  //                         child: Image.network(_movingDetails.commentReplyList[index].parentCommentAuthorAvatar,
  //                         //radius: 10,
  //                         ),
  //                       ),
  //                       title: Text(_movingDetails.commentReplyList[index].parentCommentAuthorName, style: nicknameStyle,),
  //                       subtitle: Wrap(
  //                         spacing: 1.0,
  //                         children: <Widget>[
  //                           Text(_movingDetails.commentReplyList[index].parentCommentContent),
  //                           Text(_movingDetails.commentReplyList[index].parentCommentCreateTime, style: timeStyle,)
  //                         ],
  //                       ),
  //                       trailing: Column(
  //                         children: <Widget>[
  //                            GestureDetector(
  //                              child: Icon(FontAwesomeIcons.heart,),
  //                              onTap: (){
  //                                // 修改点赞量
  //                              },
  //                            ),
  //                           Text(_movingDetails.commentReplyList[index].commentLike.toString())
  //                         ],
  //                       ),
  //                     ),
  //                     trailing: Column(
  //                         children: <Widget>[
  //                            GestureDetector(
  //                              child: Icon(FontAwesomeIcons.heart,),
  //                              onTap: (){
  //                                // 修改点赞量
  //                              },
  //                            ),
  //                           Text(_movingDetails.commentReplyList[index].commentLike.toString())
  //                         ],
  //                       ),
  //                     onTap: (){
  //                       // 用户登录与否
  //                       if(user == null){
  //                         showToast('请先登录！');
  //                         return;
  //                       }
  //                       // 父评论ID
  //                       _parentCommentId = _movingDetails.commentReplyList[index].commentId;
  //                       print('所点击的评论ID：$_parentCommentId');
  //                       // 推送提醒的用户别名（手机号码）
  //                       _commentPhone = _movingDetails.commentReplyList[index].commentAuthorPhone;
  //                       print('所要推送提醒的用户号码：$_commentPhone');
  //                       // 获取当前上下文
  //                       final BuildContext currentContext = _movingDetialskey?.currentContext??context;;
  //                       // 弹出评论输入框区域
  //                       _showCommentWindow(currentContext,user);
  //                     },
  //                   );
  //                 }, 
  //                 separatorBuilder: (context,index){
  //                   return Divider(height: ScreenUtil().setHeight(10),);
  //                 }, 
  //                 itemCount: _movingDetails.commentReplyList.length??0,
  //               )

  //         ],
  //       ), 
  //       onRefresh: _getMovingDetailsById,
  //     );
  // }


  /// 
  /// 评论区弹窗
  /// [currentContext]  当前上下文
  /// [user]  登录用户
  _showCommentWindow(BuildContext currentContext ,User user){

    // 弹出框的key
    // GlobalKey _commentSheetKey = GlobalKey();

    // 评论弹出层为true
    if(mounted){
      setState(() {
        _isShowCommentSheet = true;
        print('评论弹出框打开...' + _isShowCommentSheet.toString());
      });
    } 

    // 弹出层
     showModalBottomSheet(
       backgroundColor: Colors.transparent, // 透明
       context: context, 
       builder: (context){
        
        // 禁用发送按钮
        // bool disableSendBtn = true;

        // 弹出键盘
        // FocusScope.of(context).requestFocus(_commentFocusNode);

        // 获得键盘的弹出高度
        final double bottom = MediaQuery.of(context).viewInsets.bottom;
        print(context);
        print('键盘高度：' + bottom.toString()); // 287.3333

        print('弹出层高度：' + MediaQuery.of(context).size.height.toString()); // 总720.00，弹出层是360

        // 容器的宽度
        final double width = MediaQuery.of(context).size.width;
        // 容器的高度
        final double height = ScreenUtil().setHeight(650);

        return Container(
          // key: _commentSheetKey,
          width: width,
          height: height,
          margin: EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              // 输入框区域，@按钮，发送按钮
              Positioned(
                top: 8,
                // left: ,
                // width: width,
                // height: 50,
                child: Container(
                  width: width,
                  height: 65,
                  color: Colors.white,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      // 文本框
                      Expanded(
                          child: Padding(
                          padding: EdgeInsets.fromLTRB(15, 5, 15, 0),
                          child: TextField(
                              controller: _commentTextController,
                              focusNode: _commentFocusNode,
                              autofocus: true,
                              maxLines: null,
                              expands: true,
                              keyboardType: TextInputType.text,
                              // scrollPadding: EdgeInsets.all(0),
                              onChanged: (value){
                                print('输入了文本信息：');
                                print(value);
                                if(!mounted) return;
                                if(value.trim().length > 0){
                                  // 激活发送按钮
                                  setState((){
                                    print('文本不为空，');
                                    _commentContentIsEmpty = false;
                                  });
                                  print('发送按钮的状态：' + _commentContentIsEmpty.toString());
                                } else {
                                    // 关闭发送按钮
                                    setState((){
                                      print('文本为空，');
                                    _commentContentIsEmpty = true;
                                  });
                                  print('发送按钮的状态：' + _commentContentIsEmpty.toString());
                                }
                              },
                              decoration: InputDecoration(
                                hintText: '说点什么吧...',
                                border: InputBorder.none,
                              ),
                            ),
                        ),
                      ),
                      // @ 按钮
                      Padding(
                        padding: EdgeInsets.only( right: 10,),
                        child: GestureDetector(
                          child: Icon(FontAwesomeIcons.at, size: 32, color: Colors.blue[400],),
                          onTap: () async {

                            if(!mounted) {
                              showToast('页面加载未完成！');
                              return;
                            }
                            print('点击了评论艾特按钮...');
                            // 暂时弹出评论输入框
                            Navigator.of(context).pop();
                            // setState(() {
                            //   // 评论弹出层为false，避免页面跳转引起的问题（路由传递使用的是同一个上下文对象）
                            //   _isShowCommentSheet = false;
                            // });
                            print('弹出框，点击@按钮之后，_isShowCommentSheet= ' + _isShowCommentSheet.toString());
                            // 跳转 @ 选项页面
                            final Map<String,String> map = await Navigator.of(context).push<Map<String,String>>(MaterialPageRoute(builder: (context) => AtChoosePage()));
                            print('弹出框点击@按钮，选择的用户：'+map.toString());
                            print('弹出框点击@按钮，返回详情页之后，_isShowCommentSheet= ' + _isShowCommentSheet.toString());
                            if(!mounted) return;
                            setState(() {
                              if(!(map?.isEmpty??true)){
                                _atList.add(map);
                              }
                            });
                            print('弹出框点击@按钮，艾特列表数据：'+_atList.toString());
                            // 追加数据
                            _appendAtInfo();
                            // 弹出区域
                            _showCommentWindow(currentContext,user);

                          },
                        ),
                      ),
                      // 发送按钮
                      Padding(
                        padding: EdgeInsets.only( right: 15,),
                        child: GestureDetector(
                          child: Icon(FontAwesomeIcons.paperPlane, size: 32,color: Colors.red[400]),
                          onTap: () async {
                            print('点击发送按钮，提交评论信息，长度：length=' + _commentTextController.text.trim().length.toString());
                            if(!(_commentTextController.text.trim().length > 0)){
                              showToast('请输入评论内容！');
                              return;
                            }
                            
                          print('点击了评论发送按钮...');
                          final String commentContent = _commentTextController.text;
                          print('用户评论内容：$commentContent');
                          // 构建评论数据Map
                          final Map<String,dynamic> commentMap = {
                              "movingId": _movingDetails.movingId,
                              "commentContent": _commentTextController.text,
                              "commentUid": user.userId,
                              "commentAuthor": user.userNickname,
                              "commentAuthorAvatar": user.userAvatar, 
                              "replyMovingUid": _movingDetails.movingAuthorId,
                              "replyMovingUname": _movingDetails.movingAuthorName,
                              "commentParent": _parentCommentId == 0 ? null : _parentCommentId,
                          };
                          print('构建评论数据Map: commentMap='+commentMap.toString()); 
                          // 推送的Map（@类型与评论类型）
                          final Map<String,dynamic> jpushAliasMap = {
                            "atAliasList": _atList.map((m) => m['phone']).toList(),
                            "commentAlias":  _commentPhone == '' ? _movingDetails.movingAuthorPhone : _commentPhone
                          };
                          print('推送的Map: jpushAliasMap='+jpushAliasMap.toString()); 
                          // 提交数据
                          final Map<String,dynamic> data = Map<String,dynamic>();
                          data.addAll(jpushAliasMap);
                          data.addAll(commentMap);
                          print('提交数据为：data='+data.toString()); 
                          // 设置请求的配置
                          // final Options options = Options(contentType: Headers.jsonContentType,);
                          // print('Dio的POST请求信息：');
                          // print('contentType: ' + BjuHttp.dio.options.contentType);
                          // print('header: ' + BjuHttp.dio.options.headers.toString());
                          // 获取登录时的token信息
                          final String token = BjuHttp.dio.options.headers.putIfAbsent('Authorization', () => 'Bearer ');
                          // 请求服务器
                          final Dio dio = Dio();

                        //  Response res =  await dio.post(API.addComment,  data: data,);
                        //  print('重新设置的Dio结果为：');
                        //  print(res.toString());
                        //  print(res.data.toString());
                          // 发送网络请求
                          ResponseData resData = await dio.post(
                              API.addComment, 
                              data: data,
                              options: Options(
                                headers: {
                                    "Authorization" : token,
                                },
                              ),
                            ).then((onValue) => ResponseData.fromJson(onValue.data))
                                .catchError((onError){
                                  print('添加评论出错了！');
                                  print(onError);
                                  showToast('请求服务器异常！');
                                });
                          if(resData !=null && resData.statusCode == 1){
                            print('评论失败');
                             // 关闭弹出框
                            Navigator.pop(context);
                            showToast(resData.message);

                            return;
                          }
                          // 关闭键盘
                          // FocusScope.of(context).unfocus();
                          // 关闭弹出框
                          Navigator.pop(context);
                          // 重新加载数据
                          _getMovingDetailsById();
                          },
                        ),
                      ),

                    ],
                  ),
                ),

              ),
              // Positioned(
              //   top: 60,
              //   child: Container(
              //     color: Colors.transparent,
              //     width: width,
              //     height: 600,
              //   ),

              // ),

            ],
          ),

          
        );
    }).then((onValue){
      print('评论框关闭回调: ');
      print(onValue.toString());
      setState(() {
        // 评论弹出层为false，避免页面跳转引起的问题（路由传递使用的是同一个上下文对象）
        _isShowCommentSheet = false;
        // 清空@的用户列表信息
        _atList = [];
        // 清空输入框中的内容
        _commentTextController.text = '';
      });
    });
  }


  ///
  /// 创建底部评论区 
  Widget _buildBottomCommentArea(){

      // 获取登录用户信息
      final User user = Provider.of<LoginProvider>(context,listen: false).loginUser;

      return Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 评论区
            Expanded(
              flex: 6,
              child: GestureDetector(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 5, 0, 5),
                  child: Text('留下你精彩的评论...', style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    wordSpacing: 2,
                    color: Colors.lightBlue,
                  ),),
                ),
                onTap: (){

                  // 用户登录与否
                 /*  if(user == null){
                      showToast('请先登录！');
                      return;
                  } */
                  // 获取当前上下文
                  final BuildContext currentContext = _movingDetialskey?.currentContext??context;;
                  // 弹出区域
                  _showCommentWindow(currentContext,user);
                },
              ),
            ),
            // @按钮
            Expanded(
              flex: 1,
              child: GestureDetector(
                child: Icon(FontAwesomeIcons.at),
                onTap: () async {
                  // 用户登录与否
                  if(user == null){
                      showToast('底部评论区@按钮，请先登录！');
                      return;
                  }
                    // 跳转 @ 选项页面
                  final Map<String,String> map = await Navigator.of(context).push<Map<String,String>>(MaterialPageRoute(builder: (context) => AtChoosePage()));
                  print('底部评论区@按钮，选择的用户：'+map.toString());
                  // 选择为空
                  if(map == null) return;
                  if(!mounted) return;
                  setState(() {
                    // 添加@用户
                    _atList.add(map);
                    print('底部评论区@按钮，艾特列表数据：'+_atList.toString());
                  });
                  // 追加@的用户信息
                  _appendAtInfo();
                  // 获取当前上下文
                  final BuildContext currentContext = _movingDetialskey?.currentContext??context;
                  // 弹出评论输入框区域
                  _showCommentWindow(currentContext,user);
                },
              )
            ),
          ],
        ),
      );
  }


  /// 评论区布局
  List<Widget> _commentLayout(List<CommentVO> commentList){

    // 获取登录的用户
    final User user = Provider.of<LoginProvider>(context).loginUser;

    // 定义字体样式
    // 昵称
    final TextStyle nicknameTextStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: Colors.black45,
    );
    // 评论内容
    final TextStyle commentTextStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Colors.grey[850],
    );
    // 赞数量
    final TextStyle likeTextStyle = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: Colors.grey[400],
    );
    // 时间
    final TextStyle timeTextStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: Colors.black38,
    );


    return commentList.map<Widget>(
      (m){
        print('评论顺序为：' + m.toString());
        return GestureDetector(
        child: Card(
                      elevation: 1,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // 评论左侧（评论头像）
                          Padding(
                            padding: EdgeInsets.fromLTRB(8, 2, 8, 0),
                            child: GFAvatar(
                              maxRadius: 15,
                              backgroundImage:NetworkImage(API.baseUri + m.commentAuthorAvatar),
                              shape: GFAvatarShape.circle,
                            ),
                          ),
                          // 评论右侧
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                // 评论人昵称，评论内容，赞
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                            // 评论人昵称
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(5, 2, 0, 5),
                                              child: Text(m.commentAuthorName, style: nicknameTextStyle,),
                                            ),
                                            // 评论内容
                                            /* Expanded(
                                              child:  */Padding(
                                                padding: EdgeInsets.fromLTRB(5, 0, 3, 8),
                                                child: Wrap(
                                                  spacing: 2,
                                                  children: <Widget>[
                                                      // 内容
                                                      Text(m.commentContent, style: commentTextStyle,),
                                                      // 时间
                                                      Padding(
                                                        padding: EdgeInsets.only(top: 2),
                                                        child: Text(BjuTimelineUtil.formatDateStr(m.commentCreateTime), style: timeTextStyle,)
                                                      )
                                                  ],
                                                ),
                                              ),
                                          // )
                                        ],
                                      ),
                                    ),
                                    // 评论点赞量
                                    GestureDetector(
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(8, 2, 8, 0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(2, 2, 2, 5),
                                              child: Icon(FontAwesomeIcons.thumbsUp, color: (m?.commentLikeUsers?.contains(user?.userId.toString()??'0'))??false ? Colors.lightBlue[400] : Colors.grey[400],),
                                            ),
                                            Text((m?.commentLike??0)?.toString()??'0', style: likeTextStyle,),
                                          ],
                                        ),
                                      ),
                                      onTap: () async {
                                                print('点击点赞评论，评论点赞用户列表：' + (m?.commentLikeUsers??[])?.toString());
                                                // print('点击点赞评论，评论点赞用户列表：' + m?.commentLikeUsers?.toString());
                                                // 用户登录与否
                                                if(user == null){
                                                    showToast('请先登录！');
                                                    return;
                                                }
                                                // 已赞返回
                                                if(m?.commentLikeUsers?.contains(user.userId.toString())??false){
                                                  return;
                                                }
                                                
                                                print('点赞的用户ID为: ' + user.userId.toString());
                                                final Map<String,dynamic> paramsMap = {
                                                  "movingId" : _movingDetails.movingId,
                                                  "alias" : m.commentAuthorPhone,
                                                  "content" : m.commentContent,
                                                  "commentId" : m.commentId,
                                                  "likeUserId" : user.userId,
                                                  "likeUserNickname" : user.userNickname,
                                                  "likeUserAvatar" : user.userAvatar
                                                };
                                                // 修改点赞量
                                                ResponseData resData = await BjuHttp.put(API.updateCommentLikeData, params: paramsMap)
                                                  .then((onValue) => ResponseData.fromJson(onValue.data))
                                                  .catchError((onError){
                                                    print('更新评论点赞量及点赞用户列表异常失败！');
                                                    print(onError);
                                                    showToast('请求服务器失败！');
                                                  });
                                                  print('点赞返回结果：' + resData.toString());
                                                if(resData == null) return;
                                                // 失败
                                                if(resData.statusCode == 0){
                                                  // 刷新数据
                                                  if(!mounted) return;
                                                  setState(() {
                                                    // 刷新点赞列表
                                                    final List<String> likeUsers = m.commentLikeUsers??[];
                                                    likeUsers.add(user.userId.toString());
                                                    m.commentLikeUsers = likeUsers;
                                                    m.commentLike += 1;
                                                    print('点赞过后，评论点赞量为：' + m.commentLike.toString() + '评论点赞用户列表为：' + (m.commentLikeUsers??[]).toString());
                                                  });
                                                  return;
                                                }
                                                showToast(resData.message);
                                                return;

                                              } 
                                    )
                                  ],
                                ),
                                // 父评论信息
                                m.parentCommentAuthorId == null 
                                ? SizedBox()
                                : Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          // 父评论左侧（评论头像）
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(8, 2, 8, 0),
                                            child: GFAvatar(
                                              maxRadius: 10,
                                              backgroundImage:NetworkImage(API.baseUri + m.parentCommentAuthorAvatar),
                                              shape: GFAvatarShape.circle,
                                            ),
                                          ),
                                          // 父评论右侧
                                          Expanded(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                // 父评论人昵称，评论内容，赞
                                                Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    // 父评论人昵称，评论内容
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          // 父评论人昵称
                                                          Padding(
                                                            padding: EdgeInsets.fromLTRB(5, 2, 0, 5),
                                                            child: Text(m.parentCommentAuthorName, style: nicknameTextStyle,),
                                                          ),
                                                          // 父评论内容
                                                          /* Expanded(
                                                            child:  */Padding(
                                                              padding: EdgeInsets.fromLTRB(5, 0, 3, 8),
                                                              child: Wrap(
                                                                spacing: 2,
                                                                children: <Widget>[
                                                                  // 内容
                                                                  Text(m.parentCommentContent, style: commentTextStyle,),
                                                                  // 时间
                                                                  Padding(
                                                                    padding: EdgeInsets.only(top: 2),
                                                                    child: Text(BjuTimelineUtil.formatDateStr(m.parentCommentCreateTime), style: timeTextStyle,)
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          // ),
                                                        ],
                                                      ),
                                                    ),
                                                  // 父评论点赞量
                                                  Padding(
                                                    padding: EdgeInsets.fromLTRB(8, 2, 8, 0),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.max,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: <Widget>[
                                                        Padding(
                                                          padding: EdgeInsets.fromLTRB(2, 2, 2, 5),
                                                          child: GestureDetector(
                                                            child: Icon(FontAwesomeIcons.thumbsUp, color: Colors.grey[400],),
                                                            onTap: (){
                                                              // 修改点赞量
                                                            },
                                                          ),
                                                        ),
                                                        Text((m?.parentCommentLike??0)?.toString()??'0', style: likeTextStyle,),
                                                      ],
                                                    ),
                                                  )
                                              ],
                                            ),
                                              ]
                                          ),
                                          )          
                                        ],
                                      )
                                    ),
                                  ],
                                ),





                              ],
                            )
                          )
                          
                        ],
                      ),
                    ), 
        onTap: (){
          
          // 用户登录与否
          if(user == null){
              showToast('请先登录！');
              return;
          }
          // 父评论ID
          _parentCommentId = m.commentId;
          print('所点击的评论ID：$_parentCommentId');
          // 推送提醒的用户别名（手机号码）
          _commentPhone = m.commentAuthorPhone;
          print('所要推送提醒的用户号码：$_commentPhone');
          // 获取当前上下文
          final BuildContext currentContext = _movingDetialskey?.currentContext??context;;
          // 弹出评论输入框区域
          _showCommentWindow(currentContext,user);
          return;
        });
      }).toList();
  }


  @override
  Widget build(BuildContext context) {
    // 初始化屏幕大小用于适配
    ScreenUtil.init(context, width:750,height:1334);

    return Scaffold(
      key: _movingDetialskey,
      appBar: AppBar(
        leading: BackButton(onPressed:()=>Navigator.of(context).pop()),
        title: Text('动态详情'),
        backgroundColor: Colors.white54,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: FlatButton(
              onPressed: () {
                    showToastWidget(
                      CircularProgressIndicator(backgroundColor: Colors.black38),
                      context: context,
                      duration: Duration(milliseconds: 1500),
                    );

                _getMovingDetailsById();
              } , 
              child: Icon(Icons.refresh, size: 32, color: Colors.lightBlue,)
            ),
          )
        ],
      ),
      body: _movingDetails == null 
      ? Center(child: Text('暂无动态详信息'))
      : CustomScrollView(
            scrollDirection: Axis.vertical,
            slivers: <Widget>[

              // 动态主体布局
              SliverToBoxAdapter(
                child: _movingContextLayout(),
              ),

              // 评论列表布局
              _movingDetails.commentReplyList == null || _movingDetails.commentReplyList.length == 0  
              ? SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text('还没有评论，快来评论吧...', style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      wordSpacing: 2,
                      color: Colors.black26,
                    ),),
                  )
                ),
              )
              : SliverPadding(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _commentLayout(_movingDetails.commentReplyList),
                  )/* ListView.separated(
                  // shrinkWrap: true,
                  itemBuilder: (context,index){
                    
                    // 每一条评论的布局
                    return ;
                  }, 
                  separatorBuilder: (context,index) => Divider(color: Colors.blueGrey[50]), 
                  itemCount: _movingDetails.commentReplyList.length,
                ) */,
                ),
              ),

            // 到达底部
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('已经到底部了~', style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      wordSpacing: 2,
                      color: Colors.black26,
                    )
                  ),
                ),
              ),
            ),

            ],
          ), 
      bottomNavigationBar: _buildBottomCommentArea(),
    );
  }
}

