import 'package:flustars/flustars.dart';

///
/// 应用时间线工具类
/// 2020/04/07 12:55
///
class BjuTimelineUtil{

 /// 将时间格式化为时间线的形式
 /// * dateStr 时间字符串 
 static String formatDateStr(String dateStr){
  //  print('时间字符串为: dateStr=' + dateStr);
   // 设置时间线信息
   setLocaleInfo('zh_BjuApp',ZHBjuAppTimelineInfo()); 
   // 将时间字符串转为DateTime对象
   final DateTime dateTime = DateTime.parse(dateStr);
  //  print('转换时间为：');
  //  print(dateTime);
   // 时间线工具
   //  TimelineUtil.format();
   final String timelineStr = TimelineUtil.formatByDateTime(dateTime,locale: 'zh_BjuApp', dayFormat: DayFormat.Common);
   print('时间线形式：timelineStr= ' + timelineStr);
   return timelineStr;
 }

}

///
/// 自定义的时间线格式类
/// 2020/04/07 13:18
///
class ZHBjuAppTimelineInfo implements TimelineInfo {
  String suffixAgo() => '前';
  String suffixAfter() => '后';
  String lessThanTenSecond() => '刚刚';
  String customYesterday() => '昨天';
  bool keepOneDay() => true;
  bool keepTwoDays() => false;
  String oneMinute(int minutes) => '$minutes分';
  String minutes(int minutes) => '$minutes分';
  String anHour(int hours) => '$hours小时';
  String hours(int hours) => '$hours小时';
  String oneDay(int days) => '$days天';
  String days(int days) => '$days天';
}
