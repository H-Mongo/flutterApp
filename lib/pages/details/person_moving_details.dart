import 'package:flutter/material.dart';


///
/// 用户动态详情页面
///
class PersonMovingDetailsPage extends StatefulWidget {
  PersonMovingDetailsPage({Key key}) : super(key: key);

  @override
  _PersonMovingDetailsPageState createState() => _PersonMovingDetailsPageState();
}

class _PersonMovingDetailsPageState extends State<PersonMovingDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed:()=>Navigator.of(context).pop()),
        title: Text('个人主页'),
      ),
    );
  }
}