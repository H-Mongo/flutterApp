import 'package:bju_information_app/api/api.dart';
import 'package:bju_information_app/models/response.dart';
import 'package:bju_information_app/models/vo.dart';
import 'package:bju_information_app/net/bju_net.dart';
import 'package:bju_information_app/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getflutter/getflutter.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

///
/// 用户艾特选择页面
///2020/03/26 14:53
///
class AtChoosePage extends StatefulWidget {
  AtChoosePage({Key key}) : super(key: key);

  @override
  _AtChoosePageState createState() => _AtChoosePageState();
}

class _AtChoosePageState extends State<AtChoosePage> {


  /// 输入框key
  GlobalKey _atSearchTextFieldKey = GlobalKey();

  /// 模糊查询 @ 用户列表
  // [{'avatar':avatar,'nickname':nickname,'phone':phone,'motto',motto}]
  List<AtUserVO> _atList = List();

  /// 搜索文本控制器
 TextEditingController _searchTextController = TextEditingController();
 /// 搜索焦点控制器
 FocusNode  _searchTextFocusNode = FocusNode();
 // 搜索文本是否为空
 bool _isSearchTextEmpty = true;



  @override
  void initState() { 
    super.initState();
    
    // 搜索文本监听器
    _searchTextController.addListener((){
      // 显示清除按钮
      if(_searchTextController.text.trim().length > 0){
        if(!mounted) return;
        setState(() {
          _isSearchTextEmpty = false;
        });
      } else {
        if(!mounted) return;
        setState(() {
          _isSearchTextEmpty = true;
        });
      }
    });

  }

  @override
  void dispose() { 
    super.dispose();

  }

  /// 构建搜索Bar
  Widget _buildSearchBar(){

    // 输入框获取焦点
    // FocusScope.of(context).requestFocus(_searchTextFocusNode);

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: TextField(
            key: _atSearchTextFieldKey,
            controller: _searchTextController,
            focusNode: _searchTextFocusNode,
            autofocus: true,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: "输入@的用户昵称...",
              // prefixIcon: Icon(FontAwesomeIcons.search),
              suffixIcon: _isSearchTextEmpty ? null : IconButton(
                icon: Icon(Icons.close),
                onPressed: (){
                  // 清空为输入的文本
                  WidgetsBinding.instance.addPostFrameCallback((_) => _searchTextController.clear());

                },
              ),
              border: InputBorder.none,
            ),
            // textInputAction: TextInputAction.search,
          )
        ),
        GestureDetector(
          child: Padding(
          padding: EdgeInsets.only(left: 12, right: 5),
          child: Text("搜索", style: TextStyle(
              fontSize: 18,
              wordSpacing: 4,
              fontWeight: FontWeight.w500,
              color: Colors.lightBlue,
            ),), 
          ),
          onTap: () async {
              if(Provider.of<LoginProvider>(context,listen: false).loginUser == null){
                showToast('请先登录！');
                return;
              }
              if(_searchTextController.text == null || _searchTextController.text.trim().length == 0){
                showToast('请输入搜索内容！');
                return;
              }
              final String searchText = _searchTextController.text;
              // 发送请求数据
             ResponseData resData = await BjuHttp.get(API.searchAtUser,params: {"keywords":searchText})
                    .then((onValue) => ResponseData.fromJson(onValue.data))
                    .catchError((onError){
                      print('搜索艾特用户失败！');
                      print(onError);
                      showToast('请求服务器异常！');
                      return;
                    });
            if(resData == null) {
              // 延迟提示
              Future.delayed(Duration(milliseconds : 1500),() => showToast('网络错误！'));
              return;
            }
            print('@用户搜索数据为：' + resData.toString());
            if(resData != null && resData.statusCode == 1){
              showToast(resData.message);
              return;
            }
            print('@用户模糊搜索列表的数据类型为: ' + resData.res.runtimeType.toString());
            if(!mounted) return;
            // 刷新列表
            setState(() {
              _atList = (resData.res as List).map<AtUserVO>((m) => AtUserVO.fromJson(m)).toList();

            });
            print('@用户的包装列表为: ' + _atList.toString());
          }
        ),

      ],
    );
  }

  /// 创建搜索出来得到内容体
  Widget _buildBody(){

    return _atList == null || _atList.length == 0 
      ? Center(
          child: Text('没有符合条件的搜索结果！', style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black38,
            wordSpacing: 2,
          )
        )
      )
      : ListView.separated(
          itemBuilder: (context,index){
            return Padding(
              padding: EdgeInsets.only(top: index == 0 ? ScreenUtil().setHeight(10) : 0, bottom: ScreenUtil().setHeight(2),),
              child: GFListTile(
                      color: Colors.lightBlue[300],
                      avatar:GFAvatar(
                        backgroundImage:NetworkImage(API.baseUri + _atList[index].avatar??'/static/avatars/default_avatar.jpg'),
                        shape: GFAvatarShape.standard
                      ),
                      title: Text(_atList[index].nickname??'无效数据', 
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          wordSpacing: 2,
                          // color: Colors.lightBlue[400],
                          color: Colors.white,
                        ),
                      ),
                      subTitle: Text(_atList[index].motto??'无效数据',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          wordSpacing: 2,
                          color: Colors.white54,
                        ),
                      ),
                      icon: Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: GestureDetector(
                          child: Icon(FontAwesomeIcons.at,color: Colors.white70,),
                          onTap: (){
                            // 选中的参数
                            final Map<String,String> chooseMap = {
                              'nickname': _atList[index].nickname,
                              'phone': _atList[index].phone
                            };
                            print('选中的艾特用户信息: chooseMap='+chooseMap.toString());
                            Navigator.of(context).pop(chooseMap);
                            return;
                          },
                          ),
                      )
                    ),
            );
          }, 
          separatorBuilder: (context,index) => SizedBox(),
            // Divider(indent: 2, endIndent: 2,height: ScreenUtil().setHeight(10), thickness: 1,color: Colors.lightBlue[100],), 
          itemCount: _atList.length,
        );
  }

  @override

  Widget build(BuildContext context) {

    // 初始化屏幕大小用于适配
    ScreenUtil.init(context, width:750,height:1334);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white54,
        leading: BackButton(onPressed:()=>Navigator.of(context).pop()),
        title: _buildSearchBar(),
      ),
      body: _buildBody(),
    );
  }
}