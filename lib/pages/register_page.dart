import 'dart:convert';
import 'dart:io';

import 'package:bju_information_app/api/api.dart';
import 'package:bju_information_app/models/response.dart';
import 'package:bju_information_app/net/bju_net.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oktoast/oktoast.dart';

///
/// 注册页面
/// 2020/2/24 23:30
///
class RegisterPage extends StatefulWidget {
  RegisterPage({Key key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {


  /// 表单的GlobalKey
  GlobalKey<FormState> _formKey= GlobalKey<FormState>();
  /// 昵称
  TextEditingController _nickNameTextController =TextEditingController();
  // 手机号码
  TextEditingController _mobileTextController =TextEditingController();
  /// 密码
  TextEditingController _passwordTextController =TextEditingController();
  /// 验证码
  TextEditingController _validateNumTextController =TextEditingController();

  /// 昵称焦点
  FocusNode _nicknameFocusNode = FocusNode();
  /// 手机号码焦点
  FocusNode _mobileFocusNode = FocusNode();
  /// 密码焦点
  FocusNode _passwordFocusNode = FocusNode();
  /// 验证码焦点
  FocusNode _validateNumFocusNode = FocusNode();



  String _userNickname = '';
  String _userMobile = '';
  String _userPassword = '';
  String _validateNum = '';
  /// 是否显示密码
  bool _isShowPassword = false;
  bool _showNickNameClear = false;
  /// 禁用发送验证码
  bool _disableSendVerifyCode = false;

  /// 用户昵称通过验证
  bool _passNickname = false;
  /// 手机号码通过验证
  bool _passMobile = false;



  @override
  void initState() { 
    super.initState();
    
    // 为昵称加监听
    _nickNameTextController.addListener((){
      setState(() {
        _showNickNameClear = _nickNameTextController.text.length > 0 ? true : false;
      });
    });

    // 昵称焦点监听
    _nicknameFocusNode.addListener(() async {
      if(_nicknameFocusNode.hasFocus){
        print("****昵称获得焦点****");
        _mobileFocusNode.unfocus();
        _passwordFocusNode.unfocus();
        _validateNumFocusNode.unfocus();
      } else {
        if(_nickNameTextController.text.trim().length == 0){
          return;
        }
        // if(!_passNickname){
          print('注册的昵称为: ' + _nickNameTextController.text);
           final ResponseData nickData = await BjuHttp.post(API.existNickname,params: {'nickname':_nickNameTextController.text})
              .then((onValue) => ResponseData.fromJson(onValue.data))
              .catchError((onError){
                print('昵称检测异常！');
                print(onError);
                showToast('请求服务器异常！');
                return;
              });
            if(nickData == null){
              // if(!mounted) return;
              setState(() {
                _passNickname = false;
              });
              return;
            }
            if(nickData.statusCode == 0){
              if(!mounted) return;
              setState(() {
                _passNickname = true;
              });
              print('昵称合法！');
              return;
            } 
            if(!mounted) return;
              setState(() {
                _passNickname = false;
            });
            print('昵称已注册！');
            showToast('昵称已注册！');
              
        // }
      }
    });

    // 手机号码
    _mobileFocusNode.addListener(() async {
      if(_mobileFocusNode.hasFocus){
        print("****手机号码获得焦点****");
        _nicknameFocusNode.unfocus();
        _passwordFocusNode.unfocus();
        _validateNumFocusNode.unfocus();
      } else {
        if(_mobileTextController.text.trim().length == 0){
          return;
        }
        // if(!_passMobile){
          print('注册的手机号码为: ' + _mobileTextController.text);
          final ResponseData mobileData = await BjuHttp.post(API.existMobile,params: {"mobile": _mobileTextController.text})
            .then((onValue) => ResponseData.fromJson(onValue.data))
            .catchError((onError){
              print('手机号码检测异常');
              print(onError);
              showToast('请求服务器异常！');
              return;
            });
            print('手机号验证，结果：');
            print(mobileData);
          if(mobileData == null){
            if(!mounted) return;
              setState(() {
                _passMobile = false;
              });
            return;
          }
          if(mobileData.statusCode == 0){
            if(!mounted) return;
            setState(() {
              _passMobile = true;
            });
            print('手机号码有效！');
            return;
          }
          setState(() {
            _passMobile = false;
          });
           print('手机号码已注册！');
           showToast('手机号码已注册！');
           

        // }
      }
    });

    // 密码
    _passwordFocusNode.addListener((){
      if(_passwordFocusNode.hasFocus){
        print("****密码框获得焦点****");
        _mobileFocusNode.unfocus();
        _nicknameFocusNode.unfocus();
        _validateNumFocusNode.unfocus();
      }
    });

    // 验证码
    _validateNumFocusNode.addListener((){
      if(_validateNumFocusNode.hasFocus){
        print("****验证码获得焦点****");
        _mobileFocusNode.unfocus();
        _passwordFocusNode.unfocus();
        _nicknameFocusNode.unfocus();
      }
    });



  }


  @override
  void dispose() { 
    super.dispose();
    
    _nickNameTextController.dispose();
    _mobileTextController.dispose();
    _passwordTextController.dispose();
    _validateNumTextController.dispose();

    _nicknameFocusNode.dispose();
    _mobileFocusNode.dispose();
    _passwordFocusNode.dispose();
    _validateNumFocusNode.dispose();


  }


  ///
  /// 验证用户昵称
  ///
  String _validateNickName(String nickName){
    if(nickName.isEmpty){
      return '昵称不能为空！';
    } else if(nickName.length > 25){
      return '最多25个字符！';
    }

    return null;

  }

  ///
  /// 验证手机格式
  ///
  String _validateMobile(String mobile){
     RegExp exp = RegExp(r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$');
     if(mobile.isEmpty){
       return '手机号码不能为空！';
     } else if (!exp.hasMatch(mobile)){
       return '手机号码格式不正确！';
     }
     return null;

  }

  ///
  /// 验证密码
  ///
  String _validatePassword(String password){
    RegExp exp = RegExp(r'^\d{6,12}$');
    if(password.isEmpty){
      return '密码不能为空！';
    } else if(!exp.hasMatch(password)){
      return '密码只能是6-12位数字';
    } 
    return null;
  }

  ///
  /// 验证手机验证码格式
  ///
  String _validateVNum(String vNum){

    if(vNum.isEmpty){
      return '验证码不能为空！';
    } else if(vNum.length != 6){
      return '验证码为6位数字！';
    }
    return null;

  }

  /// 创建验证码区域
  Widget _createValidateField(){



      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:[

          // 
          // 验证码输入框
            Expanded(
              flex: 5,
              child: TextFormField(
                controller:_validateNumTextController, // 
                autovalidate: true,
                //autofocus: true, //自动获取焦点
                focusNode: _validateNumFocusNode,// 焦点
                maxLength: 6,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                // labelText: '验证码',
                  hintText: '输入手机验证码',
                  contentPadding: EdgeInsets.only(left: 15),
                  
                ), // 输入框样式
              // onFieldSubmitted:null,// 输入完成时回调
                validator: _validateVNum,// 验证器 
                onSaved:(validateNum){
                  _validateNum = validateNum;
                }, //
              ),
            ),
            
            SizedBox(width:ScreenUtil().setWidth(20)),
            // 获取验证码按钮
           Expanded(
             flex: 4,
             child: RaisedButton(
              child: Text(_disableSendVerifyCode ? "验证码已发送..." : "获取手机验证码"),
              textColor:Colors.white,
              color: Colors.lightBlue,
              shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
              onPressed: _disableSendVerifyCode ? null : () async {
                if(!_passMobile){
                  showToast('手机号码未通过验证！');
                  return;
                }
                setState(() {
                  this._disableSendVerifyCode = true;
                });
                ResponseData resData = await BjuHttp.post(API.sms + _mobileTextController.text)
                  .then((onValue) => ResponseData.fromJson(onValue.data))
                  .catchError((onError){
                    print('获取验证码异常！');
                    print(onError);
                    showToast('请求服务器异常！');
                    return;
                  });
                if(resData == null) return;
                if(resData.statusCode == 1){
                  showToast(resData.message);
                  if(!mounted) return;
                  setState(() {
                    _disableSendVerifyCode = false;
                  });
                  return;
                }
                if(resData.statusCode == 0){
                  showToast(resData.message);
                  return;
                }



              },
           ),
          )
        ]
      );
  }



  ///
  /// 创建注册表单
  ///
  Widget _createRegisterForm(){

    return Container(
      margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
      padding: EdgeInsets.all(5),
      child: Form(
        key: _formKey,
        // autovalidate: false, // 自动验证
        /* onWillPop:(){ // 阻止关闭未提交的表单

        },
        onChanged:(){

        }, */
        child: Column(
          mainAxisSize:MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 昵称
            TextFormField(
              controller:_nickNameTextController, // 
              autovalidate: true,
              autofocus: false, //自动获取焦点
              focusNode: _nicknameFocusNode,// 焦点
              maxLength: 25,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: '昵称',
                hintText: '请输入昵称',
                prefixIcon: Icon(FontAwesomeIcons.user),
                // 是否显示清除按钮
                suffixIcon:_showNickNameClear ? IconButton(
                  icon:Icon(Icons.clear),
                  onPressed: (){
                    _nickNameTextController.clear();
                  },
                ) : null,
              ), // 输入框样式
             // onFieldSubmitted:null,// 输入完成时回调
              validator: _validateNickName,// 验证器 
              onSaved:(nickName){
                _userNickname = nickName;
              }, //
            ),
            // 手机号码
            TextFormField(
              controller:_mobileTextController, //
              autovalidate: true, 
              //autofocus: true, //自动获取焦点
              focusNode: _mobileFocusNode,// 焦点
              maxLength: 11,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '手机号码',
                hintText: '请输入手机号码',
                prefixIcon: Icon(FontAwesomeIcons.mobile),
                /* suffix:IconButton(
                  icon:Icon(Icons.clear),
                  onPressed: (){
                    
                  },
                ), */
              ), // 输入框样式
             // onFieldSubmitted:null,// 输入完成时回调
              validator: _validateMobile,// 验证器 
              onSaved:(mobile){
                _userMobile = mobile;
              }, //
            ),
            // 密码
            TextFormField(
              controller:_passwordTextController, // 
              autovalidate: true,
              //autofocus: true, //自动获取焦点
              focusNode: _passwordFocusNode,// 焦点
              maxLength: 12,
              keyboardType: TextInputType.number,
              obscureText: !_isShowPassword, // 遮住密码
              decoration: InputDecoration(
                labelText: '设置密码',
                hintText: '请输入密码',
                prefixIcon: Icon(FontAwesomeIcons.key),
                suffix:IconButton(
                  icon:Icon(_isShowPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: (){
                    setState(() {
                      _isShowPassword = !_isShowPassword;
                    });
                  },
                ),
              ), // 输入框样式
             // onFieldSubmitted:null,// 输入完成时回调
              validator: _validatePassword,// 验证器 
              onSaved:(userPassword){
                _userPassword = userPassword;
              }, //
            ),
            // 确认密码
           /*  TextFormField(
              controller:null, // 
              focusNode: null,// 焦点
              maxLength: 25,
              keyboardType: TextInputType.text,
             // onFieldSubmitted:null,// 输入完成时回调
              validator: null,// 验证器 
              onSaved:null, //
            ), */
            _createValidateField(),
          ],
        )
      ),
    );
  }

  ///
  /// 注册按钮
  ///
  Widget _registerButton(){
    return Container(
      margin: EdgeInsets.only(left: 20,right: 20),
      height: ScreenUtil().setHeight(65),
      child: new RaisedButton(
        color: Colors.blue[300],
        child: Text(
          "立即注册",
          style: Theme.of(context).primaryTextTheme.headline,
        ),
        // 设置按钮圆角
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        onPressed: () async {
          //点击注册按钮，解除焦点，回收键盘
           _nicknameFocusNode.unfocus();
          _mobileFocusNode.unfocus();
          _passwordFocusNode.unfocus();
          _validateNumFocusNode.unfocus();   
          if (_formKey.currentState.validate()) {
            //只有输入通过验证，才会执行这里
            _formKey.currentState.save();
            if(!(_passNickname && _passMobile)){
              showToast('昵称或手机号码未通过验证');
              return;
            }

            // 验证昵称唯一性
          // final ResponseData nickData = await BjuHttp.post(API.existNickname,params: {'nickname':_userNickname}).then((onValue) => ResponseData.fromJson(onValue.data));
          //   if(nickData.statusCode == 1){
          //       print('昵称已注册！');
          //       showToast('昵称已注册！');
          //       return;
          //   } 
          //   print('昵称有效！');

            // 验证手机号唯一性
          // final ResponseData mobileData = await BjuHttp.post(API.existMobile+_userMobile).then((onValue) => ResponseData.fromJson(onValue.data));
          //   if(mobileData.statusCode == 1){
          //       print('手机号码已注册！');
          //       showToast('手机号码已注册！');
          //       return;
          //   }
          //   print('手机号码有效！');

            // 验证码准确性
          final ResponseData validateData = await BjuHttp.post(API.verifyCode,params: {'mobile':_userMobile,'verifyCode':_validateNum}).then((onValue) => ResponseData.fromJson(onValue.data));
            if(validateData.statusCode == 1){
                print('验证码无效！');
                showToast('验证码无效！');
                if(!mounted) return;
                setState(() {
                  _disableSendVerifyCode = false;
                });
                return;
            }
             print('验证码有效！');

            // 注册提交数据
            final Map<String,dynamic> data = {
              "userNickName":_userNickname,
              "userMobile": _userMobile,
              "userPassword": _userPassword
            }; 
            print('发送的注册信息：' + data.toString());
            // 发送数据到服务器
            ResponseData resData = await BjuHttp.post(
              API.register,
              params: data, 
              // options:  Options(contentType: "application/x-www-form-urlencoded")
            ).then((response){
                print("*****注册返回******"+response.toString());
                return ResponseData.fromJson(response.data);
            }).catchError((onError){
                print('注册异常：');
                showToast('请求服务器异常！');
                print(onError);
                return;
            });
            if(resData == null) return;
           //dynamic data =  res.data;
           if(resData.statusCode == 0){ // 注册成功
              
              // 返回上一页，带手机号
              Navigator.pop(context, _userMobile);
              showToast('注册成功！');
              return;
           } else {

              showToast('注册失败，请重试！');
              print('注册失败！');
              return;

           }
            
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width:750,height:1334);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).pop(),),
        title: Text('注册中心'),
      ),
      body: GestureDetector( // 手势操作，点击空白区域的监听
        onTap: (){
          print('用户点击了空白区域');
          _nicknameFocusNode.unfocus();
          _mobileFocusNode.unfocus();
          _passwordFocusNode.unfocus();
          _validateNumFocusNode.unfocus();                  
        },
        child: ListView(
          children: [
            SizedBox(height:ScreenUtil().setHeight(180)),
            _createRegisterForm(),
            SizedBox(height:ScreenUtil().setHeight(40)),
             _registerButton(),

            ]
        ),
      ),
    );
  }
}










/* 

Container(
          margin: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            SizedBox(height:ScreenUtil().setHeight(180)),
            _createRegisterForm(),
            SizedBox(height:ScreenUtil().setHeight(40)),
             _registerButton(),

            ]
          )
        ), */













