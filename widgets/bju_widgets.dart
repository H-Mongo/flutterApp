import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';

///
/// 加载动画
///
void showLoading(BuildContext context){
  showToastWidget(
    Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white54,
      child: Center(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(height: ScreenUtil().setHeight(6),),
                  Text('加载中...', style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      wordSpacing: 2,
                      color: Colors.lightBlue,
                    ),
                  ),
              ],
          ),
      ),
    ),
    duration: Duration(seconds: 3),
    // position: ToastPosition.center,
  );
}