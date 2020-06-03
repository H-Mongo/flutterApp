
/*  
 * 视图模型对应的dart文件
 * 
 * 时间：2020/04/15 12:19
 * 描述： 主要用来存储用于视图展示所需要的View Model类型
 * 
 */


/// 
/// 用于展示 @ 用户的视图模型，返回存储 @ 时所需要的信息
/// 2020/04/15 12:20
/// 
class AtUserVO{

  /// @用户手机号
  String phone;

  /// @用户昵称
  String nickname;

  /// @用户头像
  String avatar;

  /// @用户个性签名
  String motto;

  AtUserVO({this.phone,this.nickname,this.avatar,this.motto});

  /// 将Map数据模型化
  factory AtUserVO.fromJson(Map<String,dynamic> json){
    return AtUserVO(
      phone: json.putIfAbsent('phone', () => ''),
      nickname: json.putIfAbsent('nickname', () => ''),
      avatar: json.putIfAbsent('avatar', () => ''),
      motto: json.putIfAbsent('motto', () => '')
    );
  }

  @override
  String toString() {

    return '{' 
            + ', phone:' + this.phone
            + ', nickname:' + this.nickname
            + ', avatar:' + this.avatar
            + ', motto:' + this.motto
          +'}';
  }


}


