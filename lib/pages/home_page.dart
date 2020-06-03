import 'package:bju_information_app/api/api.dart';
import 'package:bju_information_app/pages/browser.dart';
import 'package:bju_information_app/pages/login_page.dart';
import 'package:bju_information_app/pages/modules/campus_voice.dart';
import 'package:bju_information_app/pages/modules/part_time_recruitment.dart';
import 'package:bju_information_app/pages/modules/wall_and_you.dart';
import 'package:bju_information_app/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:getflutter/getflutter.dart';
import 'package:provider/provider.dart';

///
/// 首页
///
class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  /// 页面控制器
  PageController _pageController= PageController();

  // swiper images assets URL
  final List<String> _swiperImgs = [
    'assets/swiper/bju_1.jpg',
    'assets/swiper/bju_2.jpg',
    'assets/swiper/bju_3.jpg',
    'assets/swiper/bju_4.jpg'
  ];

  /// Model Nnames
  final List<String> _modelNames = ['校园快讯','校园之声','墙上有你','兼职招聘'];

  /// 校园公告信息
  final List<Map<String,String>> _campusNoticeList = [
    {
      'noticeTitle': '校园艺术文化节公告',
      'noticeTime': '2020-03-08 10:25',
      'noticeContent': '本次校园文化艺术节，目的在于提高校园文化，为广大的师生，营造一个良好的校园艺术氛围。望广大师生，积极参与到其中，各大社团与要积极配合动员社员加入！'
    },{
      'noticeTitle': '新冠肺炎防疫公告',
      'noticeTime': '20120-02-08 00:25',
      'noticeContent': '因全国疫情严峻，为了打赢疫情保卫阻击战，响应教育部的号召，我校推迟开学时间，具体开学时间待疫情稳定后通知。各位学生要做好学习工作，坚持每日健康打卡。'
    },{
      'noticeTitle': '2020春季开学公告',
      'noticeTime': '2020-04-01 12:24',
      'noticeContent': '2020春季开学，各位学子要准备好防疫口罩及消毒物品，4月起将会下达开学通知，毕业班首先返校，其他年级依次错开返校。返校后，需在校园内进行为期14天的隔离期，无特殊情况，不得擅自离校！'
    },
  ];


  @override
  void initState() { 
    super.initState();


  }



  Widget _modelLayout(double platformWidth,double height){
    return Container(
        //color: Colors.orangeAccent,
        width: platformWidth,
        height: height,
        margin: EdgeInsets.all(5),
        child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
         Align(
           alignment:Alignment.topCenter,
           child:Row(
             mainAxisSize: MainAxisSize.max,
             mainAxisAlignment: MainAxisAlignment.spaceAround,
             children:[
                Expanded(
                  child: Container(
                    height: 50,
                    child: FlatButton.icon(
                    color: Colors.orangeAccent,
                    padding: EdgeInsets.all(1),
                    shape:RoundedRectangleBorder(
                      side: BorderSide(
                        color:Colors.white30,
                      ),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    onPressed: (){
                      final String url = API.campusNews;
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => BrowserPage('宝大校园快讯', url)));
                    }, 
                    icon: Icon(Icons.message), 
                    label: Text(_modelNames[0])
                    )
                  )
                  ),
                Expanded(
                  child: Container(
                    height: 50,
                    child: FlatButton.icon(
                    color: Colors.orangeAccent,
                    padding: EdgeInsets.all(1),
                    shape:RoundedRectangleBorder(
                      side: BorderSide(
                        color:Colors.white30,
                        ),
                      borderRadius: BorderRadius.circular(10)
                      ),
                    onPressed: (){
                      // 跳转到校园之声
                      Navigator.of(context).push(MaterialPageRoute(builder:(context) => CampusVoiceModule()));
                    }, 
                    icon: Icon(Icons.record_voice_over), 
                    label: Text(_modelNames[1])
                    )
                  ),
                  )
             ]
           )
         ),
         Align(
           alignment:Alignment.bottomCenter,
            child:Row(
             children:[
                Expanded(
                  child: Container(
                    height: 50,
                    child: FlatButton.icon(
                    color: Colors.orangeAccent,
                    padding: EdgeInsets.all(1),
                    shape:RoundedRectangleBorder(
                      side: BorderSide(
                        color:Colors.white30,
                        ),
                      borderRadius: BorderRadius.circular(10)
                      ),
                    onPressed: (){
                      // 跳转到墙上有你
                      Navigator.of(context).push(MaterialPageRoute(builder:(context) => WallModule()));
                    }, 
                    icon: Icon(Icons.wallpaper), 
                    label: Text(_modelNames[2])
                    )
                  )
                  ),
                Expanded(
                  child: Container(
                    height: 50,
                    child: FlatButton.icon(
                    color: Colors.orangeAccent,
                    padding: EdgeInsets.all(1),
                    shape:RoundedRectangleBorder(
                      side: BorderSide(
                        color:Colors.white30,
                        ),
                      borderRadius: BorderRadius.circular(10)
                      ),
                    onPressed: (){
                      // 跳转到兼职招聘
                      Navigator.of(context).push(MaterialPageRoute(builder:(context) => RecruitmentModule()));
                    }, 
                    icon: Icon(Icons.work), 
                    label: Text(_modelNames[3])
                    )
                  )
                  ),
             ]
           )
         ),
         Align(
           alignment:Alignment.center,
            child:CircleAvatar(
              radius:40,
              backgroundImage:AssetImage('assets/avatar/bju_xh.jpg',)
            )
        )
      ]
      ),
    );
      
  }

  Widget _createMessageBody(BuildContext context){

    // 获取屏幕数据
    final double platformWidth = MediaQuery.of(context).size.width;
    final double platformHeight = MediaQuery.of(context).size.height;

    // 模块高度
    final double height = 100;

    return Column(
      mainAxisSize:MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children:[
        // 模块布局
        this._modelLayout(platformWidth,height),
      ]
    );
  }

  // Swiper
  Widget _bjuSwiper(){
    return Swiper(
              scrollDirection: Axis.horizontal,
              containerHeight: 180,
              itemCount: this._swiperImgs.length,
              itemBuilder: (BuildContext context, int index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    this._swiperImgs[index],
                    fit: BoxFit.fill,
                  ),
                );
              },
              pagination: SwiperPagination(
                builder: DotSwiperPaginationBuilder(
                  color: Colors.black54,
                  activeColor: Colors.white
                )
              ),
              autoplay: this._swiperImgs != null && this._swiperImgs.length > 1,
              autoplayDelay: 2000,
              //viewportFraction: 1,
              //scale: 0.9,
            );
  }
  
  @override
  Widget build(BuildContext context) {

    // 屏幕适配
    ScreenUtil.init(context, width:750,height:1334);

    String tile = '宝鸡大学信息服务平台';
    return Consumer<LoginProvider>(
      builder: (context,loginProvider,_){
        return CustomScrollView(
          scrollDirection:  Axis.vertical, //主轴为水平轴
          slivers:<Widget>[
            SliverAppBar(
              pinned: true, // 固定AppBar，不滑出屏幕
              expandedHeight: 150.0,
              backgroundColor:Theme.of(context).primaryColor,
              /* leading:ClipOval(
                child:Image.asset(
                  'assets/avatar/default_avatar.jpg',
                  fit: BoxFit.cover,
                  width: 60,
                  height: 60,
                )
                ), */
              title: Text(tile),
              actions: <Widget>[
                //FlatButton(onPressed: (){}, child: Icon(Icons.search)),
               Padding(padding: EdgeInsets.only(right:8),
                child:  FlatButton(
                  child: loginProvider.isLogin ? Text('BJU，欢迎您！') : Text('登录'),
                  onPressed: !loginProvider.isLogin ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage())) : null, 
                ),
               ),
              ],
            ),
            
            // swiper
            SliverToBoxAdapter(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                margin: EdgeInsets.fromLTRB(4, 3, 4, 1),
                child: this._bjuSwiper()
              )
            ),
            
            // model layout
            SliverToBoxAdapter(
              child: this._createMessageBody(context),
            ),

           // 校园公告信息
            SliverToBoxAdapter(
              child:Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 0),child: Container(
                color: Colors.blueGrey,
                height: 30,
                child: Center(
                  child: Text('校园公告栏',style: TextStyle(
                  fontSize: 16,
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                  wordSpacing: 4,
                ),),
              ))),
            ),
            // perfect show
            SliverToBoxAdapter(
              child:Container(
                  color: Colors.grey[100],
                  height: ScreenUtil().setHeight(350),
                  child: PageView(
                    controller: _pageController,
                    scrollDirection: Axis.horizontal,
                    // reverse: true,
                    children: _campusNoticeList.map((m){
                      final TextStyle titleStyle = TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.lightBlue[300],
                        height: 2,
                      );
                      final TextStyle contentSytle = TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        height: 1.5,
                        wordSpacing: 6,
                      );
                      final TextStyle timeStyle = TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.blueGrey[400],
                        height: 4,
                      );
                        return  Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top:Radius.circular(6))),
                              margin: EdgeInsets.all(3),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Center(child: Text(m['noticeTitle']??'公告头部', style: titleStyle,),),
                                  Padding(padding: EdgeInsets.all(5),child:Text('   '+m['noticeContent']??'公告体', style: contentSytle,)),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Text(m['noticeTime']??'发布时间', style: timeStyle,),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                    }).toList(),
                  ),
                )
              ,
            ),
          
          SliverToBoxAdapter(
              child:Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 0),child: Container(
                color: Colors.blueGrey,
                height: 30,
                child: Center(
                  child: Text('院校介绍',style: TextStyle(
                  fontSize: 16,
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                  wordSpacing: 4,
                ),),
              ))),
            ),
          SliverToBoxAdapter(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top:Radius.circular(6))),
              margin: EdgeInsets.fromLTRB(2,2,2,25),
              child: Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Text('      宝鸡文理学院（Baoji University of Arts and Sciences）简称“宝文理”，位于宝鸡。学校是陕西省“国内一流学科建设高校”、硕士学位授予单位、博士学位授予单位立项建设单位、教育部“本科教学工作水平评估”优秀学校 。'
  +'学校前身是1958年创办的省属本科宝鸡大学，1963年停办；1975年陕西师范大学宝鸡分校在宝鸡大学旧址成立，1978年改建为宝鸡师范学院，办学层次依然为本科；1984年职业大学宝鸡大学成立；1992年经原国家教委批准宝鸡师范学院与宝鸡大学合并定名为宝鸡文理学院；2018年成为陕西省“国内一流学科建设高校”。'
  +'截至2019年12月，学校高新、石鼓、蟠龙三个校区占地2800多亩，下设17个二级学院、65个本科专业；拥有7个硕士学位一级学科授权点、5个硕士专业学位授权点；1个国内一流学科建设学科、1个省级一流学科、6个省级重点学科；1个国家级特色专业、1个国家级综合改革试点专业、9个省级一流专业、5个省级特色专业、3个省级品牌专业；专任教师1100多人，双聘院士2人，国务院有突出贡献专家、全国优秀教师、教育部新世纪优秀人才、省级教学名师、省级优秀教师等省部级及以上人才60多人，9个省级教学团队；全日制在校生近2万人，其中本科生近1.9万人，硕士研究生、留学生600多人。',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Colors.black38,
                  height: 1.5,
                ),
                ),
              ),
            )
          ),
          

            // announcenment
          /* SliverFixedExtentList(
            itemExtent: 116, 
            delegate: SliverChildBuilderDelegate((context,index){
                return  GFAccordion(
                    title: 'GF Accordion',
                    content: 'GetFlutter is an open source library that comes with pre-build 1000+ UI components.',
                    collapsedIcon: Icon(Icons.add),
                    expandedIcon: Icon(Icons.minimize)
                );
              }, 
              childCount: 5,
            )
          ) */
            
          ]
        );
      },
    );
  }



}