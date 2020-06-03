import 'package:bju_information_app/api/api.dart';
import 'package:bju_information_app/models/moving.dart';
import 'package:bju_information_app/models/response.dart';
import 'package:bju_information_app/net/bju_net.dart';
import 'package:bju_information_app/pages/details/moving_details.dart';
import 'package:bju_information_app/utils/bju_timeline_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' as SU;
import 'package:oktoast/oktoast.dart';

///
/// 校园之声
/// 2020/04/06 17:30
///
class CampusVoiceModule extends StatefulWidget {
  CampusVoiceModule({Key key}) : super(key: key);

  @override
  _CampusVoiceModuleState createState() => _CampusVoiceModuleState();
}

class _CampusVoiceModuleState extends State<CampusVoiceModule> {

  // 模块Id号码
  int _moduleId = 3;

  /// 校园之声数据列表
  List<Moving> _campusVoiceList = [];


  @override
  void initState() { 
    super.initState();
    
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 初始化数据
    _loadData();
  }

  @override
  void dispose() { 
    
    super.dispose();
  }

  /// 加载数据
  void _loadData() async {
    // 向服务器获取数据信息
    ResponseData resData = await BjuHttp.get(API.queryMovingByModuleId + _moduleId.toString())
          .then((onValue) => ResponseData.fromJson(onValue.data))
          .catchError((onError){
            print('获取校园之声模块数据异常！');
            print(onError);
            showToast('请求服务器异常！');
          });
    if(resData == null){
      Future.delayed(Duration(microseconds: 1500), () => showToast('网络请求失败！'));
      return;
    }
    if(resData != null && resData.statusCode == 1){
      showToast(resData.message);
      return;
    }
    if(!mounted) return;
    setState(() {
      // 刷新数据
      _campusVoiceList = (resData.res as List).map<Moving>((m) => Moving.fromJson(m)).toList();
    });

  }

  /// 创建模块体
  Widget _buildModuleBody(){
    print('校园之声模块的数据为：');
    print(_campusVoiceList);
    return RefreshIndicator(
        color: Colors.lightBlue,
        backgroundColor: Colors.white54,
        child: _campusVoiceList.isEmpty 
          ? Center(child: Text('没有谏言类相关信息！', style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black38,
                wordSpacing: 2,
              )
            )
          )
          : ListView.separated(
            itemBuilder: (context,index){
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                margin: EdgeInsets.fromLTRB(4, 3, 4, index == (_campusVoiceList.length -1) ? 10 : 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // 发布时间
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 10, top: 5),
                          child: Text(BjuTimelineUtil.formatDateStr(_campusVoiceList[index].movingCreateTime) + ' 发布', style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            wordSpacing: 2,
                            color: Colors.lightBlue,
                          ),),
                        )
                      ],
                    ),
                    Divider(),
                    // 主要内容
                    Padding(
                      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Text(_campusVoiceList[index].movingContent, style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          wordSpacing: 2,
                          // color: Colors.lightBlue,
                        ),
                      )
                    ),
                    Divider(),
                    // 详情链接
                    GestureDetector(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text('详情信息', style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            wordSpacing: 4,
                            color: Colors.lightBlue,
                          ),
                        ),
                      ),
                      onTap: (){
                        // 进入详情页面
                        print('校园之声点击了详情：' + _campusVoiceList[index].movingId.toString());
                        final int movingId = _campusVoiceList[index].movingId;
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
                  ],
                ),
              );
            },
            separatorBuilder: (context,index) => SizedBox(height: SU.ScreenUtil().setHeight(10)),
            itemCount: _campusVoiceList.length,
          ), 
        onRefresh: (){
          // 刷新数据
          _loadData();
          return;
        }
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
        title: Text('校园之声'),
      ),
      body: _buildModuleBody(),
    );
  }
}