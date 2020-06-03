import 'dart:typed_data';

import 'package:bju_information_app/api/api.dart';
import 'package:bju_information_app/models/response.dart';
import 'package:bju_information_app/models/user.dart';
import 'package:bju_information_app/net/bju_net.dart';
import 'package:bju_information_app/pages/square_page.dart';
import 'package:bju_information_app/providers/login_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

///
/// 发布页面
///
class PublishPage extends StatefulWidget {

  /// 动态类型
  int _movingType;

  PublishPage(this._movingType,{Key key}) : super(key: key);

  @override
  _PublishPageState createState() => _PublishPageState(this._movingType);
}

class _PublishPageState extends State<PublishPage> {

  /// 头部标题
  final List<String> _publishTitles = ['表白墙','万能墙','谏言贴','兼职汇'];
  /// 模块对应的话题列表
  List<dynamic> _topics = List();
  /// 选中的话题
  List<String> _selectedTopics = [];
  /// 待上传的图片列表
  List<Asset> _images = [];
  /// 动态类型
  int _movingType;
  /// 废弃定位 start
  /// 定位
  // Location location = Location();
  /// 定位服务开启
  // bool _serviceEnabled;
  /// 应用定位授权状态
  // PermissionStatus _permissionGranted;
  /// 定位数据
  // LocationData _locationData;
  /// 废弃定位 end
  

  /// 定位插件geolocater的使用
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;
  /// 位置描述（经纬度）
  Position _currentPosition;
  /// 可视化位置（位置字符串）
  String _currentAddress;

  /// 表单Key
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  /// 动态文本控制器
  TextEditingController _movingTextController = TextEditingController();
  /// 动态文本焦点
  FocusNode _movingContentFocusNode = FocusNode();
  /// 动态文本内容
  String _movingContent = '';

  /// 表单是否为空
  bool _isFormEmpty = true;
  

  _PublishPageState(this._movingType);


  @override
  void initState() {
    super.initState();
    
    // 为动态文本添加监听器监听 ‘@’ 符号的输入
    _movingTextController.addListener((){
        if(_movingTextController.text.trim().length > 0 || _images.isNotEmpty){
            
            setState(() {
              _isFormEmpty = false;
            });
         }
    });

    _initTopics(_movingType);

    
  }

  ///
  ///初始化topic数据
  Future _initTopics(int moduleId) async {

    ResponseData resData = await BjuHttp.get(API.topics,params: {"moduleId":moduleId})
      .then((onValue){
        return ResponseData.fromJson(onValue.data);
      })
      .catchError((onError){
        print("网络请求出错了!");
        print(onError);
      });
      if(resData == null){
        Future.delayed(Duration(milliseconds: 1500),() => showToast("网络请求失败！"));
        return;
      }
      print("获取话题信息：");
      print(resData);
      if(resData.res != null){
        if(!mounted) return;
        setState(() {
          _topics = resData.res;
          print('话题信息为：_topics=');
          print(_topics);
        });
      }


  }

  /// 图片上传
  Future<void> _multiImage() async {
    List<Asset> resultList = List<Asset>();
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 9, // 最多9张图片
        enableCamera: true, // 允许使用照相机
        selectedAssets: _images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "图片上传",
          allViewTitle: "所有图片",
          //okButtonDrawable: 'OK',
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      print(e);
    }
    if(!mounted) return; // 未挂载到widget树中
    setState(() {
      _images = resultList;
      print('****图片列表***'+resultList.toString());
    });
  }

  /// 从Asset中获取Image
  /// 返回List<AssetThumb>集合
  List<Widget> _getImagesFromAsset(List<Asset> assets){

    // 没有选择图片
    if(assets.isEmpty){
      return null;
    }
    return assets.map((asset){
      return Container(
        width: 30,
        height: 30,
        child: AssetThumb(asset: asset, width: 150, height: 150),
      );
    }).toList();
  }



  /// 创建选择话题区域
  Widget _createTopicsArea(){

      return _topics == null || _topics.length == 0 ?  Container(): Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Stack(
            children:[
              Align(
                alignment: Alignment.centerLeft,
                child: FlatButton.icon(
                  icon: Icon(FontAwesomeIcons.tags, color: Colors.lightBlue,), 
                  label: Text('选择话题类型',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w100,
                      // color: Colors.blue,
                    ),
                  ),
                  onPressed: _multiImage, 
                ),
              ),
              /* Align(
                alignment: Alignment.centerRight,
                child: Icon(FontAwesomeIcons.chevronRight)
              ) */
            ]
          ),
        Padding(
          padding: EdgeInsets.only(left:12, right: 12),
          child: Wrap(
            spacing: 1,
            runAlignment: WrapAlignment.center,
            children: _topics.map((t){
              return ChoiceChip(
                  avatar: Icon(FontAwesomeIcons.solidHeart,color: _selectedTopics.contains(t) ? Colors.orangeAccent : Colors.white54,),
                  //labelPadding: EdgeInsets.all(5),
                  //backgroundColor:Colors.grey, // 背景色
                  //selectedColor: Colors.orangeAccent, // 选中时的颜色
                  label: Text(t,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w100,
                            ),
                        ), 
                  selected: _selectedTopics.contains(t),
                  onSelected: (selected){
                    print('selected:'+selected.toString());
                    setState(() {
                      // 逻辑处理
                      if(selected){ // 选中，切没有包含
                        _selectedTopics.add(t);
                      } else { // 未选中，包含
                          _selectedTopics.remove(t);
                      }
                      print('-----'+_selectedTopics.toString());
                    });
                  },
                );
            }).toList(),
          ),
        ),


      ],
    );
  }

 /// 获取当前position 
  _getCurrentLocation() async{
    // GeolocationStatus geolocationStatus = await geolocator.checkGeolocationPermissionStatus();
    // print('定位权限：'+geolocationStatus.toString());
    // print(await geolocator.isLocationServiceEnabled()); // 定位开启与否
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      
      print('定位经纬度：'+_currentPosition.toJson().toString());
      // 将经纬度地理编码
      _getAddressFromLatLng();
    }).catchError((e) {
      print('定位异常：');
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude,
          // localeIdentifier: 'zh_CN',
          );
      // 获取第一个位置标记
      Placemark place = p[0];
      print('地理编码地址：');
      print(place.toJson().toString());
      setState(() {
        // 中国-陕西省-商洛市-山阳县
        _currentAddress =
            "${place.administrativeArea}-${place.locality}-${place.subLocality}";
      });
    } catch (e) {
      print('地理编码异常：');
      print(e);
    }
  }


  /// 定位信息Area
  Widget _createLocationArea(){
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            children:[
              Align(
                alignment: Alignment.centerLeft,
                child: FlatButton.icon(
                  icon: Icon(FontAwesomeIcons.mapMarkerAlt, color: Colors.lightBlue,), 
                  label: Text('获取位置',
                      style:TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w100,
                        // color: Colors.blue,
                      )
                    ),
                  onPressed: _getCurrentLocation, 
                ),
              ),
              /* Align(
                alignment: Alignment.centerRight,
                child: Text(_currentAddress??'未定位'),
              ) */
            ]
          ),
          Padding(
            padding: EdgeInsets.only(left:20),
            child: Text(_currentAddress??'未定位',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w200
              ),
            ),
          )
        ],
      );
  }

  /// 创建图片区域
  Widget _createImagesArea(){
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Stack(
            children:[
              Align(
                alignment: Alignment.centerLeft,
                child: FlatButton.icon(
                  icon: Icon(FontAwesomeIcons.camera, color: Colors.lightBlue,), 
                  label: Text('上传图片',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w100,
                      // color: Colors.blue,
                    ),
                  ),
                  onPressed: _multiImage, 
                ),
              ),
              /* Align(
                alignment: Alignment.centerRight,
                child: Icon(FontAwesomeIcons.chevronRight)
              ) */
            ]
          ),
        _images.isNotEmpty ? GridView.count(
            padding: EdgeInsets.all(8),
            crossAxisCount: 3,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
            shrinkWrap:true,
            children:_getImagesFromAsset(_images),
          ) : SizedBox(),


      ],
    );
  }

 /// 对话框
 YYDialog _showConfirmDialog(BuildContext context){

  //  _movingContentFocusNode.unfocus();
   
    return YYDialog().build(context)
      ..width = ScreenUtil().setWidth(600)
      ..borderRadius = 4.0
      ..text(
        padding: EdgeInsets.all(25.0),
        alignment: Alignment.center,
        text: "保存到草稿箱中？",
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
          Navigator.pop(context);
        },
        text2: "确定",
        color2: Colors.redAccent,
        fontSize2: 14.0,
        fontWeight2: FontWeight.bold,
        onTap2: () async {
           showToastWidget(
              CircularProgressIndicator(backgroundColor: Colors.black38),
              context: context,
              duration: Duration(milliseconds: 5000),
           );
          _saveMovingWithAPI(API.saveDraftMoving);
          // Navigator.pop(context);

        },
      )
      ..show();
  }

 /// 创建文本框
 Widget _createFormArea(){
   return Container(
    //  margin: EdgeInsets.all(10),
     padding: EdgeInsets.all(5),
    //  decoration: BoxDecoration(
    //    borderRadius: BorderRadius.circular(8),
    //  ),
     child: Form(
       key: _formKey,
       onWillPop:() async {

         if(_isFormEmpty) return true;
            // 提示内容为提交
          _showConfirmDialog(context);
          return false;
       },
       child: TextFormField(
              controller:_movingTextController, // 
              autofocus: false, //自动获取焦点
              focusNode: _movingContentFocusNode,// 焦点
              maxLength: 255,
              maxLengthEnforced: true, // 最大长度阻止输入
              maxLines: 6,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: '留下你的文字...',
                border: OutlineInputBorder(
                  borderRadius:BorderRadius.circular(4)
                ),
              ), // 输入框样式
             // onFieldSubmitted:null,// 输入完成时回调
              validator: (text){
                if(!(text.trim().length > 0)){
                  return '请输入发布内容！';
                }
                return null;
              },// 验证器 
              onSaved:(content){
                this._movingContent = content;
              },
          ),
       ),
   );
 }

  /// 构建发布页面主体
 Widget _buildPublishBody(){


   return GestureDetector(
     child:ListView(
      children: <Widget>[
        //  SizedBox(height: ScreenUtil().setHeight(30),),
        // content
        _createFormArea(),
        //  SizedBox(height: ScreenUtil().setHeight(10),),
        // images
        _createImagesArea(),
        SizedBox(height: ScreenUtil().setHeight(30),),
        // topics
        _createTopicsArea(),
        SizedBox(height: ScreenUtil().setHeight(30),),
        // location
        Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: _createLocationArea(),
        ),
        
      ]
    ),
    onTap: (){
      // 关闭焦点
      _movingContentFocusNode.unfocus();
    },
   );

}

/// 保存动态信息（草稿箱中或者发布）
  void _saveMovingWithAPI(String apiUrl) async {
                  // 发布动态
                  // 获取登录的用户
                  User user = Provider.of<LoginProvider>(context,listen: false).loginUser;
                  print('获得登录用户数据：$user');
                  // 判断用户是否存在
                  if(user == null){
                    showToast('未登录！');
                    return;
                  }
                  // 不能发送空内容
                  if(_movingTextController.text.trim().length == 0){
                    showToast('请输入发布内容！');
                    return;
                  }
                  // 多文件数组
                  final List<MultipartFile> files = List();
                  // 获取图片字节流
                  for (var image in _images) {
                    // 图片名称
                    String imageName = image.name;
                    
                    // 获取图片字节数据
                    ByteData byteData =await image.getByteData();
                    // 将字节数据转为数组
                    List<int> imageData = byteData.buffer.asUint8List();
                    
                    // 构造用于上传文件对象
                    MultipartFile file = MultipartFile.fromBytes(imageData,filename:imageName);
                    files.add(file);
                  }
                  print('待发布的图片个数：length= ' + files.length.toString());
                  print('文件数组：files= ' + files.toString());
                  // 创建文件上传对象
                  FormData formData = FormData.fromMap({
                      "movingType" : _movingType,
                      "movingContent" : _movingTextController.text,
                      "currentAddress" : _currentAddress,
                      "userName" : user.userNickname,
                      "userId" : user.userId,
                      "selectedTopics" : _selectedTopics,
                      "files" : files
                    });
                // formData.f
                // 获取登录时的token信息
                final String token = BjuHttp.dio.options.headers.putIfAbsent('Authorization', () => 'Bearer ');
                // 创建Dio connectTimeout: 6000,receiveTimeout: 4000,
                final Dio dio = Dio(BaseOptions(baseUrl: API.baseUri,));
                // 添加监听器
              //   dio.interceptors.add(InterceptorsWrapper(
              //     onRequest:(RequestOptions options) async {
              //     // 
              //     print('发布请求前打印：' + options.data.toString());
              //     return options; //continue
                  
              //     },
              //     onResponse:(Response response) async {
                  
              //     return response; // continue
              //     },
              //     onError: (DioError e) async {
                  
              //     return  e;//continue
              //     }
              // ));
                print('待提交的发布信息内容，图片信息：' + formData.files.toString());
                // 请求后端x信息发布接口
                ResponseData res = await dio.post(apiUrl, data: formData, options:  Options(
                                contentType: "multipart/form-data",
                                headers: {
                                    "Authorization" : token,
                                    "content-type" : "multipart/form-data"
                                },
                              ),)
                            .then((onValue){
                              return ResponseData.fromJson(onValue.data);
                          }).catchError((onError){
                              print('发布异常：');
                              print(onError);
                          });
                if(res == null){
                  Future.delayed(Duration(milliseconds: 1500),() => showToast('网络出错了！'));
                  return;
                }
                showToast(res.message);
                if(res.statusCode == 0){
                  // 跳转到朋友圈页面并将当前页面移除
                  print('发布成功！');
                  
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SquarePage()));
                  return;
                } else {
                  print("发布失败！");
                  
                  return;
                }
              }

  @override
  Widget build(BuildContext context) {
    // 屏幕适配
    ScreenUtil.init(context, width:750,height:1334);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        leading: BackButton(onPressed:(){
        //  _showConfirmDialog(context);
            // 提示内容为提交
          Navigator.of(context).pop();
        }),
        title:Text("发表动态  "+_publishTitles[_movingType-1]),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right:20),
              child: FlatButton(
                child:Icon(FontAwesomeIcons.paperPlane, color: Colors.lightBlue[300]),
                onPressed: () => _saveMovingWithAPI(API.publishMoving),
            ),
          )
        ],
      ),
      body: _buildPublishBody(),
    );
  }
}








/// 主体布局
/* Column(
     mainAxisSize: MainAxisSize.min,
     mainAxisAlignment: MainAxisAlignment.center,
     children: <Widget>[
       // content
       _createFormArea(),
       
       // images
       _createImagesArea(),
       // topics
       _createTopicsArea(),
       // location
       _createLocationArea(),
      
     ],
   ) */




