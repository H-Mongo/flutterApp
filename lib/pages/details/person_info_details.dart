 import 'dart:convert';
import 'dart:io';

import 'package:bju_information_app/api/api.dart';
import 'package:bju_information_app/models/response.dart';
import 'package:bju_information_app/models/user.dart';
import 'package:bju_information_app/net/bju_net.dart';
import 'package:bju_information_app/providers/login_provider.dart';
import 'package:city_pickers/city_pickers.dart';
import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' as SU;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getflutter/components/avatar/gf_avatar.dart';
import 'package:getflutter/shape/gf_avatar_shape.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

/// 
/// 用户信息详情页面
/// 
class PersonInfoDetailsPage extends StatefulWidget {

   /// 用户ID
   int userId;
    
   PersonInfoDetailsPage(this.userId, {Key key}) : super(key: key);
 
   @override
   _PersonInfoDetailsPageState createState() => _PersonInfoDetailsPageState();
 }
 
 class _PersonInfoDetailsPageState extends State<PersonInfoDetailsPage> {

  /// 用户信息载体
  User _user = null;
  /// 表单key
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// 表单编辑过的状态
  bool _edit = false;
  /// 文本域能否被编辑
  bool _enableEdit = false;

  /// 昵称控制器
  TextEditingController _nicknameController = TextEditingController();
  /// 签名控制器
  TextEditingController _mottoController = TextEditingController();
  /// 兴趣爱好控制器
  TextEditingController _hobbyController = TextEditingController();

  /// 昵称焦点
  FocusNode _nicknameFocusNode = FocusNode();
  /// 签名焦点
  FocusNode _mottoFocusNode = FocusNode();
  /// 兴趣爱好焦点
  FocusNode _hobbyFocusNode = FocusNode();

  /// 昵称
  String _nickname = '';
  /// 签名
  String _motto = '';
  /// 兴趣爱好
  String _hobby = '';
  /// 用户生日
  String _userBirthday = '';
  /// 用户住址
  String _userAddress = '';
  /// 用户院系专业信息
  String _yxzy = '';

  /// 院系及专业信息选择列表
  String _facultyAndSpecialty = '["-1"]';

  /// 昵称是否存在
  bool _isExistNickname = false;



  @override
  void initState() {
    super.initState();
    /// 获取院系及专业信息
    _getFacultyAndSpecialty();
    // 获取登录的用户信息
    final User user = Provider.of<LoginProvider>(context, listen: false).loginUser;
    _initData(user?.userNickname??'', user?.userMotto??'', user?.userHobby??'', 
    user?.userAddress??'', user?.userBorth??'', (user?.facultyName??'') + '-' + (user?.specialtyName??''));
    // 为焦点添加监听事件
    // _nicknameFocusNode.addListener((){
    //   if(!_nicknameFocusNode.hasFocus){
    //       ResponseData resData = BjuHttp.post(API.existNickname,params: {"nickname": _nicknameController.text})
    //           .then((onValue) => ResponseData.fromJson(onValue.data))
    //           .catchError((onError){
    //             print('修改昵称，验证昵称唯一，请求异常！');
    //             print(onError);
    //             showToast('请求服务器异常！');
    //             // Scaffold.of(context).showSnackBar(_buildSnack('请求异常！'));
    //             return;
    //           }) as ResponseData;
    //       if(resData == null){
    //         showToast('请求失败！');
    //         return;
    //       }
    //           // 失败
    //       if(resData != null && resData.statusCode == 1){
    //       }
     
    //  }
                                            
                                              
    // });

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
  }

@override
  void dispose() {
    super.dispose();
    // controller
    _nicknameController.dispose();
    _mottoController.dispose();
    _hobbyController.dispose();
    // focusnode
    _nicknameFocusNode.unfocus();
    _mottoFocusNode.unfocus();
    _hobbyFocusNode.unfocus();

  }


  /// 验证昵称是否合法
 void _checkNickname(String nickname) async {
   // 获取登录的用户信息
   final User user = Provider.of<LoginProvider>(context).loginUser;
   // 是否和当前登录的用户的昵称一致，一致则不用发送请求
      if(((user?.userNickname??'') ==  _nicknameController.text)){
        return;
      }
        ResponseData resData = await BjuHttp.post(API.existNickname,params: {"nickname": _nicknameController.text})
            .then((onValue) => ResponseData.fromJson(onValue.data))
            .catchError((onError){
                print('修改昵称，验证昵称唯一，请求异常！');
                print(onError);
                showToast('请求服务器异常！');
                // Scaffold.of(context).showSnackBar(_buildSnack('请求异常！'));
                return;
            });
        if(resData == null){
            showToast('请求失败！');
            return;
        }
        // 昵称已存在
        if(resData != null && resData.statusCode == 1){
          if(!mounted) return;
          setState(() {
            _isExistNickname = true;
          });
          return;
        }
     return;
 }


  /// 
  /// 初始化数据页面中的数据项
  /// 
  /// [nickname]  昵称；
  /// [motto] 签名；
  /// [hobby] 爱好；
  /// [address] 地址；
  /// [birth] 生日；
  /// [yxzy]  院系专业
  /// 
  void _initData(String nickname, String motto, String hobby, String address, String birth, String yxzy){
    // 初始化数据
    _nicknameController.text = nickname;
    _mottoController.text = motto;
    _hobbyController.text = hobby;
    _userAddress = address;
    _userBirthday = birth;
    _yxzy = yxzy;
  }

  /// 编辑资料时焦点的建议位置
  Future<void> _fieldSelectionPosition(){

    _nicknameController.selection = TextSelection.fromPosition(TextPosition(offset: _nicknameController.text.length));
    _mottoController.selection = TextSelection.fromPosition(TextPosition(offset: _mottoController.text.length));
    _hobbyController.selection = TextSelection.fromPosition(TextPosition(offset: _hobbyController.text.length));

  }

  ///
  /// 依照ID获取用户信息
  ///
  Future<void> _getUserInfo(int userId) async {

    final ResponseData resData = await BjuHttp.get(API.getUserInfoById+userId.toString())
      .then((onValue) => ResponseData.fromJson(onValue.data))
      .catchError((onError){
        print('获取用户信息异常！');
        print(onError);
        showToast('网络请求异常！');
      });

      if(resData.statusCode == 1){
        showToast(resData.message);
        return;
      }
      if(!mounted) return;
      setState(() {
        _user = User.fromJson(resData.res);
      });
      
  }


  /// 获取院系及专业信息
  Future _getFacultyAndSpecialty() async {
    // if(_facultyAndSpecialty != '["-1"]') return;
    /// 获取院系信息
    ResponseData resData = await BjuHttp.get(API.allFacultyAndSpecialty)
        .then((onValue) => ResponseData.fromJson(onValue.data))
        .catchError((onError) {
              print('出错了！');
              showToast('请求异常！');
              print(onError);
        });
        if(resData != null && resData.statusCode == 1){
          showToast(resData.message);
          return;
        }
          // 获取院系专业信息列表
          // List<Map<String,List<String>>> list = resData.res??_facultyAndSpecialty;
          if(!mounted) return;
          setState(() {
            // Json化
            _facultyAndSpecialty = jsonEncode(resData.res??'-1');
            print('院系及专业信息：'+_facultyAndSpecialty);
          });

  }


  /// 关闭焦点事件
  void _closeFocusNode(){
    // 关闭所有焦点
    _nicknameFocusNode.unfocus();
    _mottoFocusNode.unfocus();
    _hobbyFocusNode.unfocus();
  }

  /// 院系专业
  Widget _yxzyArea(){

    // 院系专业字符串
    // final String yxzyStr = facultyName.isEmpty && specialtyName.isEmpty ? '出错了！' : facultyName+'-'+specialtyName;
    return ListTile(
      title: Text('院系及专业'),
      subtitle: Text(_yxzy),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: !_enableEdit ? null : () async{
        // 关闭所有焦点
        _closeFocusNode();

        Picker(
          adapter: PickerDataAdapter<String>(pickerdata: JsonDecoder().convert(_facultyAndSpecialty)),
          changeToFirst: true,
          hideHeader: false,
          selectedTextStyle: TextStyle(color: Colors.blue),
          confirmText: '确定',
          cancelText: '取消',
          onConfirm: (Picker picker, List value) {
            // print("picker:");
            // print(picker);
            // print(value.toString());
            // print("++++++选中的院系：");
            // print(picker.getSelectedValues());
            
            /// 拼接字符串
            final String yxzy= picker.getSelectedValues()?.join('-');
            print('选择的院系专业信息为: '+yxzy);
            print(yxzy);
            if(!mounted) return;
            setState(() {
              if(!(yxzy == '-1')){
                _yxzy = yxzy;
              }
            });
          }
        ).showModal(this.context);
      },
    );

  }

  /// 住址
  Widget _cityArea(){
    return ListTile(
      title: Text('住址'),
      subtitle: Text(_userAddress),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: !_enableEdit ? null : () async {
        _closeFocusNode();
            // 显示城市选择器
            final String result = await CityPickers.showCityPicker(
                                              context: context,
                                              showType: ShowType.pc,
                                              locationCode: '610000',
                                              height: 200,
                                              /* cancelWidget: RaisedButton(
                                                child: Text('取消'),
                                                onPressed: (){
                                                  
                                                }
                                              ),
                                              confirmWidget: RaisedButton(
                                                child: Text('确定'),
                                                onPressed: (){}
                                              ), */
                                            ).then((data){
                                              if(data == null) return null;
                                              print('****城市信息：'+data.toString());
                                              print('-----'+data.provinceName + data.cityName);
                                              return data.provinceName + data.cityName;
                                            }).catchError((error){
                                              print('出错了'+error.toString());
                                            });
            if(!mounted) return null;
            setState(() {
              //print(result == null);
              _userAddress = result != null ? result.toString() : _userAddress;
            });
            print('新的住址: ' + _userAddress);

          },
    );

  }
  
  /// 生日
  Widget _birthArea(){

    return ListTile(
      title: Text('生日'),
      subtitle: Text(_userBirthday),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: !_enableEdit ? null : () async{

        // 显示日期选择器
        final DateTime dateTime = await DatePicker.showDatePicker(context,
                                                showTitleActions: true,
                                                locale: LocaleType.zh,
                                                minTime: DateTime(1990, 01, 01),
                                                maxTime: DateTime(2050, 12, 31),
                                                currentTime:DateTime.now(),
                                              );
        if(!mounted) return null;
        setState(() {
           
         final String birthday = DateUtil.formatDate(dateTime, format:'yyyy-MM-dd');
          _userBirthday =  birthday != null ?  birthday : _userBirthday;
        });
         // 关闭所有焦点
       _closeFocusNode();
       print('新的出生日期: ' + _userBirthday);

      },
    );

  }

  /// 显示提示信息的snack
  Widget _buildSnack(String message){
    return SnackBar(
      content: Text(message),
      backgroundColor: Colors.lightBlue,
      behavior: SnackBarBehavior.floating,
      shape:RoundedRectangleBorder(),
      );
  }

   @override
   Widget build(BuildContext context) {
     // 适配设置
     SU.ScreenUtil.init(context, width:750,height:1334);

         /// 用户头像
         /// 用户昵称
         /// 电话号码
         /// 用户生日
         /// 用户住址
         /// 个性签名
         /// 兴趣爱好
         /// 院系及专业
         /// 
          return Consumer<LoginProvider>(builder: (context,loginProvider,child){
            if(!loginProvider.isLogin){
              showToast('用户未登录！');
            }
            // 获取登录的用户
            final User user = loginProvider.loginUser;
            return !loginProvider.isLogin || user == null ? Center(child: Text('校园信息服务平台出错了！')): Scaffold(
                    appBar: AppBar(
                      backgroundColor: Colors.white,
                      leading: BackButton(onPressed:()=>Navigator.of(context).pop()),
                      title: Text(user?.userNickname??'宝鸡大学'+'的主页'),
                      actions: <Widget>[
                        !_enableEdit ? 
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: RaisedButton(
                              color: Colors.blue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: Text('编辑',
                              style: TextStyle(
                                fontSize: 18,
                                letterSpacing: 10,
                                color: Colors.white,
                              ),
                              ),
                            //  color: Colors.lightBlue,
                              onPressed: (){
                                // _fieldSelectionPosition();
                                if(!mounted) return;
                                setState(() {
                                  _enableEdit = true;
                                });
                              },
                          ) ,
                        )
                        :
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: RaisedButton(
                              color: Colors.blue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: Text('保存',
                              style: TextStyle(
                                fontSize: 18,
                                letterSpacing: 10,
                                color: Colors.white,
                              ),
                              ),
                            //  color: Colors.lightBlue,
                              onPressed: () async {

                                // 刷新按钮
                                if(!mounted) {
                                  showToast('稍后点击！');
                                  return;
                                }
                                setState(() {
                                  _enableEdit = false;
                                });

                                // 表保存表单中数据
                                _formKey.currentState.save();

                                // 发送请求修改数据
                                // 提交数据显示的数据一致则不提交
                                final Map<String,dynamic> data = {
                                  "userId": user.userId,
                                  "nickname": _nickname != null && _nickname != '' && _nickname != user.userNickname
                                              ? _nickname : null,
                                  "motto": _motto != null && _motto != '' && _motto != user.userMotto 
                                          ? _motto : null,
                                  "hobby": _hobby != null && _hobby != '' && _hobby != user.userHobby
                                          ? _hobby : null,
                                  "birthday":  _userBirthday != null && _userBirthday != ''&& _userBirthday != user.userBorth 
                                              ? _userBirthday : null,
                                  "address": _userAddress != null && _userAddress != '' && _userAddress != user.userAddress
                                            ? _userAddress : null,
                                  "yxzy": _yxzy != null && _yxzy != ''
                                          ? _yxzy : (user.facultyName + '-' + user.specialtyName),
                                };
                                print('修改的待提交的数据: ' + data.toString());
                              /// 向服务器传送数据完成修改
                              final ResponseData  resData = await BjuHttp.put(API.updateUserInfo, params: data)
                                    .then((onValue) => ResponseData.fromJson(onValue.data))
                                    .catchError((onError){
                                      showToast('请求服务器异常！');
                                      print(onError);
                                      return;
                                    });
                              // 网络请求失败
                              if(resData == null){
                                // 提示
                                // Scaffold.of(context).showSnackBar(_buildSnack('网络请求失败！'));
                                // 显示原数据
                                if(!mounted) return;
                                setState(() {
                                  _initData(user.userNickname, user.userMotto, user.userHobby, 
                                  user.userAddress, user.userBorth, user.facultyName + user.specialtyName);
                                });
                                return;
                              }
                              // 失败
                              if(resData != null && resData.statusCode == 1){
                                // 提示
                                showToast(resData.message);
                                 // 显示原数据
                                if(!mounted) return;
                                setState(() {
                                  _initData(user.userNickname, user.userMotto, user.userHobby, 
                                  user.userAddress, user.userBorth, user.facultyName + user.specialtyName);
                                });
                                return;
                              }
                              // 获取刷新的用户数据失败
                              if(resData.res == null){
                                // 弹出提示
                                showToast(resData.message);
                                _initData(user.userNickname, user.userMotto, user.userHobby, 
                                user.userAddress, user.userBorth, user.facultyName + user.specialtyName);
                                return;
                              }
                              // 更新后的用户
                              final User updateUser = User.fromJson(resData.res);
                              print('更新前的用户信息：'+user.toString());
                              // 修改成功，刷新登录的用户信息
                              loginProvider.updateUserInfo(updateUser);
                              print('更新后的用户信息：'+updateUser.toString());
                              
                            },
                          ) ,
                        )
                      ],
                    ),
                    body: SingleChildScrollView(
                      padding: EdgeInsets.all(10),
                      child: GestureDetector(
                          child:Container(
                          alignment: Alignment.topCenter, // 类似于Center的效果
                          child: Column(
                            children: [
            
                              // 头像及电话号码区域，头像可换，电话不可以
                              ListTile(
                                leading: GFAvatar(
                                  backgroundImage: NetworkImage(API.baseUri+user?.userAvatar??'/images/avatars/bju_app.png'),
                                  shape: GFAvatarShape.square,
                                ),
                                title:Text('手机号码'),
                                subtitle: Text(user?.userMobile??'12345678900'),
                                trailing: FlatButton.icon(
                                  icon: Icon(FontAwesomeIcons.camera, color: Colors.lightBlue), 
                                  label: Text('换头像',style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    wordSpacing: 2,
                                    color: Colors.lightBlue,
                                  ),), 
                                  onPressed: () async {
                                    print('换头像...');
                                    // 图片选择器 （目前仅支持图库选择）
                                    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
                                    print('换头像，选择的头像：file= ' + file?.toString());
                                    // showDialog(context: null)
                                    print('换头像，选择的头像路径：path= ' + file?.path);
                                    if(file == null) return;
                                    // 获取登录时的token信息
                                    final String token = BjuHttp.dio.options.headers.putIfAbsent('Authorization', () => 'Bearer ');
                                    // 创建请求服务器的Dio对象
                                    final Dio dio = Dio();
                                    // 构建请求数据
                                    final FormData data =  FormData.fromMap({
                                      "userId" : user.userId,
                                      "file" : MultipartFile.fromFileSync(file.path)
                                    });
                                    final ResponseData resData = await dio.post(API.modifyAvatar, 
                                      data: data,
                                      options: Options(
                                        headers: {
                                            "Authorization" : token,
                                        },
                                      ),
                                    ).then((onValue) => ResponseData.fromJson(onValue.data))
                                    .catchError((onError){
                                      print('用户头像修改，请求服务器异常！');
                                      print(onError);
                                      showToast('服务器请求异常！');
                                      return;
                                    });
                                    print('用户头像修改，返回结果：resData= ' + resData.toString());
                                    if(resData == null){
                                      Future.delayed(Duration(milliseconds: 1500),() => showToast('请求失败！'));
                                      return;
                                    }
                                    showToast(resData.message);
                                    if(!mounted) return;
                                    setState(() {
                                      // 成功才刷新头像
                                      if(resData.statusCode == 0){
                                        loginProvider.refreshUserAvatar(resData.res);
                                      }
                                    });


                                    return;
                                  },
                                ),
                              ),
                              SizedBox(height:30),
                              // 可修改的表单域
                              Form(
                                key: _formKey,
                                onWillPop: (){ // 禁止弹出
                                
                                  return _edit ?  Future<bool>.value(false) : Future<bool>.value(true);
                                },
                                autovalidate: true, // 自动验证
                                // onChanged: _edit ? null : 
                                //   (){setState(() {
                                //     _edit = true; // 标记表中的字段修改过 
                                //   });}, // 任意子FormField变化都会调用
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // 昵称
                                    ListTile(
                                      title: Text('昵称',
                                        /* style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.lightBlue,
                                          fontWeight: FontWeight.w100,
                                          letterSpacing: 4,
                                          
                                        ), */
                                      ),
                                      subtitle: TextFormField(
                                            // initialValue: user?.userNickname??'系统出错了！',
                                            controller:_nicknameController,  
                                            readOnly: !_enableEdit, // 只读
                                            autofocus: true, //自动获取焦点
                                            focusNode: _nicknameFocusNode,// 焦点
                                            maxLength: 25,
                                            keyboardType: TextInputType.text,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              //focusedBorder: UnderlineInputBorder(),
                                            ), // 输入框样式
                                            onFieldSubmitted: (value) {
                                              _nicknameFocusNode.unfocus();
                                            },// 输入完成时回调
                                            validator: (value) {
                                              if(value.trim().length == 0){
                                                return '昵称不能为空';
                                              }
                                              // 验证
                                              _checkNickname(value);
                                              return _isExistNickname ? '昵称已存在，请重新输入！' : '';
                                            },// 验证器 
                                            onSaved:(value){
                                              if(!mounted) return;
                                              setState(() {
                                                _nickname = value;
                                              });
                                              print('用户昵称修改为：'+_nickname);
                                            }, //
                                          ),
                                    ),
                                    SizedBox(height:20),
                                    // 签名
                                    ListTile(
                                      title: Text('个性签名',
                                        /* style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.lightBlue,
                                            fontWeight: FontWeight.w100,
                                            letterSpacing: 4,
                                            
                                          ) */
                                      ),
                                      subtitle: TextFormField(
                                      // initialValue: user?.userMotto??'系统出错了',
                                      controller:_mottoController, // 
                                      readOnly: !_enableEdit, // 只读
                                      autofocus: false, //自动获取焦点
                                      focusNode: _mottoFocusNode,// 焦点
                                  maxLength: 25,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ), // 输入框样式
                                  onFieldSubmitted: (motto){
                                    _mottoFocusNode.unfocus();
                                  },// 输入完成时回调
                                  // validator: null,// 验证器 
                                  onSaved:(motto){
                                    if(!mounted) return;
                                    setState(() {
                                      _motto = motto;
                                    });
                                    print('新签名为：'+_motto);
                                  }, //
                                ),
                                  // trailing:,
                                ),
                                SizedBox(height:20),
                                // 兴趣爱好
                                ListTile(
                                  title: Text('兴趣爱好',
                                  /*  style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.lightBlue,
                                        fontWeight: FontWeight.w100,
                                        letterSpacing: 4,
                                        
                                      ) */
                                  ),
                                  subtitle:TextFormField(
                                      // initialValue: user?.userHobby??'系统出错了！',
                                      controller:_hobbyController, // 
                                      readOnly: !_enableEdit, // 只读
                                      autofocus: false, //自动获取焦点
                                      focusNode: _hobbyFocusNode,// 焦点
                                      maxLength: 25,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        helperText: '请用逗号（英文）分割',
                                        helperStyle: TextStyle(
                                          color: Colors.lightBlue,
                                          fontWeight: FontWeight.w100,
                                          fontSize: 12,
                                        ),
                                        border: InputBorder.none,
                                      ), // 输入框样式
                                    // onFieldSubmitted:null,// 输入完成时回调
                                      validator: (hobby){
                                        
                                      },// 验证器 
                                      onSaved:(value){
                                        if(!mounted) return;
                                        setState(() {
                                          _hobby = value;
                                        });
                                        print('新的兴趣爱好为: '+_hobby);
                                      }, //
                                    ), //
                                ),
                                SizedBox(height:20),
                                // 生日
                                _birthArea(),
                                SizedBox(height:20),
                                // 地址
                                _cityArea(),
                                SizedBox(height:20),
                                // 院系专业
                                _yxzyArea(),
                              ]
                            ),
                        ),
                      ]
                      )
                    ),
                    onTap:(){
                      // 点击空白区域取消焦点
                      _closeFocusNode();
                    }
                ),
              ),
            );
          },
        ); 
   }
 }







 //// 测试使用的Data
 ///
 ///
 
 const PrikerDataWithBiz = '''
[
    {
      "计算机学院":[
        "软件工程",
        "物联网",
        "计算机科学与技术"
      ]
    },
    {
      "电子电气学院":[
        "电子工程",
        "电气及自动化",
        "电子技术",
        "模拟电子技术"
      ]
    },
    {
      "机械工程学院":[
        "机械原理与制造",
        "工业制造",
        "工程机械",
        "工业设计",
        "机械工艺"
      ]
    },
    {
      "新闻与传播学院":[
        "汉语言",
        "广告学",
        "新闻学",
        "播音主持",
        "古汉语"
      ]
    },
    {
      "教育学院":[
        "学前教育",
        "教育学",
        "教育技术",
        "心理学"
      ]
    },
    {
      "数学与信息学院":[
        "统计学",
        "应用数学",
        "信息技术"
      ]
    },
    {
      "地理环境学院":[
        "水土工程",
        "给排水工程",
        "自然地理",
        "环境学",
        "地球学"
      ]
    }
]
 ''';




//  const PickerData = '''
// [
//     {
//         "a": [
//             {
//                 "a1": [
//                     1,
//                     2,
//                     3,
//                     4
//                 ]
//             },
//             {
//                 "a2": [
//                     5,
//                     6,
//                     7,
//                     8,
//                     555,
//                     666,
//                     999
//                 ]
//             },
//             {
//                 "a3": [
//                     9,
//                     10,
//                     11,
//                     12
//                 ]
//             }
//         ]
//     },
//     {
//         "b": [
//             {
//                 "b1": [
//                     11,
//                     22,
//                     33,
//                     44
//                 ]
//             },
//             {
//                 "b2": [
//                     55,
//                     66,
//                     77,
//                     88,
//                     99,
//                     1010,
//                     1111,
//                     1212,
//                     1313,
//                     1414,
//                     1515,
//                     1616
//                 ]
//             },
//             {
//                 "b3": [
//                     1010,
//                     1111,
//                     1212,
//                     1313,
//                     1414,
//                     1515,
//                     1616
//                 ]
//             }
//         ]
//     },
//     {
//         "c": [
//             {
//                 "c1": [
//                     "a",
//                     "b",
//                     "c"
//                 ]
//             },
//             {
//                 "c2": [
//                     "aa",
//                     "bb",
//                     "cc"
//                 ]
//             },
//             {
//                 "c3": [
//                     "aaa",
//                     "bbb",
//                     "ccc"
//                 ]
//             },
//             {
//                 "c4": [
//                     "a1",
//                     "b1",
//                     "c1",
//                     "d1"
//                 ]
//             }
//         ]
//     }
// ]
//     ''';
