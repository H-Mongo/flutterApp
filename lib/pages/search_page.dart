

import 'package:bju_information_app/api/api.dart';
import 'package:bju_information_app/models/response.dart';
import 'package:bju_information_app/net/bju_net.dart';
import 'package:bju_information_app/pages/details/moving_details.dart';
import 'package:bju_information_app/utils/bju_timeline_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';

///
/// 搜索页
/// 2020/04/06 10:10
///
class SearchPage extends StatefulWidget {
  SearchPage({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  /// 滑动控制器
  ScrollController _scrollController = ScrollController();

  /// 搜索框输入焦点
  FocusNode _searchFocusNode = FocusNode();

  /// 搜索框文本控制器
  TextEditingController _searchEditingController = TextEditingController();

  /// 搜索结果列表
  List<Map<String, dynamic>> _searchResultList = []; 
  

  @override
  void initState() { 
    super.initState();
    _searchEditingController.text = '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
  }

  @override
  void dispose() { 
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
    
  }


  ///
  /// 搜索框布局
  ///
  Widget _searchBarLayout(){

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
              // 输入框
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(30, 10, 0, 15),
            child: TextField(
                controller: _searchEditingController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: '请输入您要搜索的内容...',
                  contentPadding: EdgeInsets.only(left: 10),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightBlue[600], width: 3,),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
            ),
          ),
        ),
        FlatButton(
          child: Icon(Icons.search, color: Colors.lightBlue, size: 56,), 
          onPressed: () async {
            // 搜索关键字
            final String searchKeyword= _searchEditingController.text??'';
            if(searchKeyword.isEmpty){
              showToast('请输入搜索的内容！');
              return;
            }
            // 向服务器请求数据
           ResponseData resData = await BjuHttp.get(API.fuzzySearchMoving+searchKeyword)
            .then((onValue) => ResponseData.fromJson(onValue.data))
            .catchError((onError){
              print('模糊搜索请求失败！');
              print(onError);
              showToast('服务器请求异常');
            });
            if(resData == null){
              showToast('网络开小差了！');
              return;
            }
            if(resData.statusCode == 1){
              showToast(resData.message);
              return;
            }
            if(!mounted) return;
            // 刷新数据
            setState(() {
              print('模糊查询结果为：res= ' + resData.res.toString());
              _searchResultList = (resData.res as List).map<Map<String, dynamic>>((m) => m).toList();
              print('刷新结果为：searchResultList= ' + _searchResultList.toString());
            });
            return;
          }, 
        )]
            ),
          ),
        ),
      ],
    );
  }
  
  ///
  /// 搜索结果布局
  ///
  Widget _searchResultLayout(){

    return _searchResultList.isEmpty ? Center(child: Text('暂无搜索结果！')) : ListView.separated(
      shrinkWrap: true,
      itemBuilder: (context,index){
        // 搜索结果的底部右侧样式
        final TextStyle resultTextStyle = TextStyle(
          fontSize: 12,
          color: Colors.black38,
        );
        return Card(
          elevation: 4,
          margin: EdgeInsets.fromLTRB(4, 4, 4, index != (_searchResultList.length - 1) ? 0 : 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          child: Container(
            height: ScreenUtil().setHeight(160),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(8,8,8,0),
                    child: Text(_searchResultList[index].putIfAbsent("content", () => ''), 
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(

                      ),
                    ),
                  )
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(8, 0, 5, 8),
                      child: Text('赞'+_searchResultList[index].putIfAbsent("likeCount", () => '0').toString(), style: resultTextStyle,),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(3, 0, 5, 8),
                      child: Text(_searchResultList[index].putIfAbsent("author", () => '0').toString(), style: resultTextStyle,),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(3, 3, 5, 8),
                      child: Text(BjuTimelineUtil.formatDateStr(_searchResultList[index].putIfAbsent("time", () => '0').toString()), style: resultTextStyle,)
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 5, right: 10, bottom: 8,),
                            child: GestureDetector(
                              child: Text('查看详情', style: TextStyle(color: Colors.lightBlue),),
                              onTap: (){
                                // 跳转页面到详情页面
                                try{
                                    print('搜索页点击详情进入：' + _searchResultList[index].putIfAbsent("id", () => '0').toString());
                                    final int movingId = int.parse(_searchResultList[index].putIfAbsent("id", () => '0').toString());
                                    if(movingId == 0){
                                      print('跳转的动态ID不存在!');
                                      showToast('动态信息有误！');
                                      return;
                                    }
                                    // 跳转到动态详情页面
                                    Navigator.push<Map<String,int>>(context, MaterialPageRoute(builder: (context)=> MovingDetailsPage(movingId) ));
                                    return;
                                }catch(e){
                                  print(e);
                                    showToast('产生异常！');
                                    return;
                                }
                              },
                            ),
                          )
                        ],
                      )
                    )
                  ],
                ),
              ],
            ),
          )
        );
      }, 
      separatorBuilder: (context,index){
        return SizedBox(height: ScreenUtil().setHeight(10));
      }, 
      itemCount: _searchResultList.length,
    );

  }

  @override
  Widget build(BuildContext context) {
    // 屏幕适配处理
    ScreenUtil.init(context, width:750,height:1334);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed:(){
          Navigator.of(context).pop();
        }),
        title: Text('搜索页'),
      ),
      body: GestureDetector(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _searchBarLayout(),
            Expanded(child: _searchResultLayout(),)
          ],
        ),
        onTap: (){
          // 点击空白关闭键盘
          _searchFocusNode.unfocus();
        }
      )
    );
  }
}




/// 用于页面测试的数据列表
List<Map<String, Object>> testData = [
    {
      "id": 1,
      "content": "这是一条用于测试搜索页面的输入，用户通过输入关键字像服务器发送请求，服务器完成对应的搜索，返回符合要求的数据信息列表，APP端接受数据完成数据的渲染任务。用户可通过点击渲染的据列表来查看数据的详情内容！",
      "likeCount": 1999,
      "time": '2020-04-06 11:04:56',
      "author": '测试人员-1',
    },
    {
      "id": 2,
      "content": "这是一条用于测试搜索页面的输入，用户通过输入关键字像服务器发送请求，服务器完成对应的搜索，返回符合要求的数据信息列表，APP端接受数据完成数据的渲染任务。用户可通过点击渲染的据列表来查看数据的详情内容！",
      "likeCount": 1999,
      "time": '2020-04-06 11:04:56',
      "author": '测试人员-2',
    },
    {
      "id": 3,
      "content": "这是一条用于测试搜索页面的输入，用户通过输入关键字像服务器发送请求，服务器完成对应的搜索，返回符合要求的数据信息列表，APP端接受数据完成数据的渲染任务。用户可通过点击渲染的据列表来查看数据的详情内容！",
      "likeCount": 1999,
      "time": '2020-04-06 11:04:56',
      "author": '测试人员-3',
    },
    {
      "id": 4,
      "content": "这是一条用于测试搜索页面的输入，用户通过输入关键字像服务器发送请求，服务器完成对应的搜索，返回符合要求的数据信息列表，APP端接受数据完成数据的渲染任务。用户可通过点击渲染的据列表来查看数据的详情内容！",
      "likeCount": 1999,
      "time": '2020-04-06 11:04:56',
      "author": '测试人员-4',
    },
    {
      "id": 5,
      "content": "这是一条用于测试搜索页面的输入，用户通过输入关键字像服务器发送请求，服务器完成对应的搜索，返回符合要求的数据信息列表，APP端接受数据完成数据的渲染任务。用户可通过点击渲染的据列表来查看数据的详情内容！",
      "likeCount": 1999,
      "time": '2020-04-06 11:04:56',
      "author": '测试人员-5',
    },
    {
      "id": 6,
      "content": "这是一条用于测试搜索页面的输入，用户通过输入关键字像服务器发送请求，服务器完成对应的搜索，返回符合要求的数据信息列表，APP端接受数据完成数据的渲染任务。用户可通过点击渲染的据列表来查看数据的详情内容！",
      "likeCount": 1999,
      "time": '2020-04-06 11:04:56',
      "author": '测试人员-6',
    },
    {
      "id": 7,
      "content": "这是一条用于测试搜索页面的输入，用户通过输入关键字像服务器发送请求，服务器完成对应的搜索，返回符合要求的数据信息列表，APP端接受数据完成数据的渲染任务。用户可通过点击渲染的据列表来查看数据的详情内容！",
      "likeCount": 1999,
      "time": '2020-04-06 11:04:56',
      "author": '测试人员-7',
    },
    {
      "id": 8,
      "content": "这是一条用于测试搜索页面的输入，用户通过输入关键字像服务器发送请求，服务器完成对应的搜索，返回符合要求的数据信息列表，APP端接受数据完成数据的渲染任务。用户可通过点击渲染的据列表来查看数据的详情内容！",
      "likeCount": 1999,
      "time": '2020-04-06 11:04:56',
      "author": '测试人员-8',
    },
    {
      "id": 9,
      "content": "这是一条用于测试搜索页面的输入，用户通过输入关键字像服务器发送请求，服务器完成对应的搜索，返回符合要求的数据信息列表，APP端接受数据完成数据的渲染任务。用户可通过点击渲染的据列表来查看数据的详情内容！",
      "likeCount": 1999,
      "time": '2020-04-06 11:04:56',
      "author": '测试人员-9',
    },
    {
      "id": 10,
      "content": "这是一条用于测试搜索页面的输入，用户通过输入关键字像服务器发送请求，服务器完成对应的搜索，返回符合要求的数据信息列表，APP端接受数据完成数据的渲染任务。用户可通过点击渲染的据列表来查看数据的详情内容！",
      "likeCount": 1999,
      "time": '2020-04-06 11:04:56',
      "author": '测试人员-10',
    },
    {
      "id": 11,
      "content": "这是一条用于测试搜索页面的输入，用户通过输入关键字像服务器发送请求，服务器完成对应的搜索，返回符合要求的数据信息列表，APP端接受数据完成数据的渲染任务。用户可通过点击渲染的据列表来查看数据的详情内容！",
      "likeCount": 1999,
      "time": '2020-04-06 11:04:56',
      "author": '测试人员-11',
    },
    {
      "id": 12,
      "content": "这是一条用于测试搜索页面的输入，用户通过输入关键字像服务器发送请求，服务器完成对应的搜索，返回符合要求的数据信息列表，APP端接受数据完成数据的渲染任务。用户可通过点击渲染的据列表来查看数据的详情内容！",
      "likeCount": 1999,
      "time": '2020-04-06 11:04:56',
      "author": '测试人员-12',
    },
    {
      "id": 13,
      "content": "这是一条用于测试搜索页面的输入，用户通过输入关键字像服务器发送请求，服务器完成对应的搜索，返回符合要求的数据信息列表，APP端接受数据完成数据的渲染任务。用户可通过点击渲染的据列表来查看数据的详情内容！",
      "likeCount": 1999,
      "time": '2020-04-06 11:04:56',
      "author": '测试人员-13',
    },
    {
      "id": 14,
      "content": "这是一条用于测试搜索页面的输入，用户通过输入关键字像服务器发送请求，服务器完成对应的搜索，返回符合要求的数据信息列表，APP端接受数据完成数据的渲染任务。用户可通过点击渲染的据列表来查看数据的详情内容！",
      "likeCount": 1999,
      "time": '2020-04-06 11:04:56',
      "author": '测试人员-14',
    },
    {
      "id": 15,
      "content": "这是一条用于测试搜索页面的输入，用户通过输入关键字像服务器发送请求，服务器完成对应的搜索，返回符合要求的数据信息列表，APP端接受数据完成数据的渲染任务。用户可通过点击渲染的据列表来查看数据的详情内容！",
      "likeCount": 1999,
      "time": '2020-04-06 11:04:56',
      "author": '测试人员-15',
    },
];