
import 'dart:convert';

///
/// 用户模型
///   用于登录，视图渲染，修改更新用户信息
/// 
/// [userId] 用户ID
/// [roleId] 角色ID
///
class User {
  int userId;
  int roleId;
  String userAvatar;
  String userNickname;
  String userMobile;
  String userBorth;
  String userAddress;
  String userHobby;
  String userMotto;
  int facultyId;
  int specialtyId;
  /// 院系名称
  String facultyName;
  /// 专业名称
  String specialtyName;

  User({
    this.userId,
    this.roleId,
    this.userAvatar,
    this.userNickname,
    this.userMobile,
    this.userBorth,
    this.userAddress,
    this.userHobby,
    this.userMotto,
    this.facultyId,
    this.specialtyId,
    this.facultyName,
    this.specialtyName
  });

  // /// 
  // /// 创建用户登录模型
  // /// 
  // factory User.createLoginUser(String loginMoblie, String loginPwd){
  //   return User(userMobile: loginMoblie, userPwd: loginPwd);
  // }

  @override
  String toString() {
     return '{userId: '+this.userId.toString()
              +', roleId: '+this.roleId.toString()
              +', userAvatar: '+this.userAvatar
              +', userNickname: '+this.userNickname
              +', userMobile: '+this.userMobile
              +', userBorth: '+this.userBorth
              +', userAddress: '+this.userAddress
              +', userHobby: '+this.userHobby
              +', userMotto: '+this.userMotto
              +', facultyId: '+this.facultyId.toString()
              +', specialtyId: '+this.specialtyId.toString()
              +', facultyName: '+this.facultyName
              +', specialtyName: '+this.specialtyName+'}';
  } 
  
    ///
    /// Json数据转换
    ///
    factory User.fromJson(Map<String,dynamic> json){
      print('用户model获取服务器数据信息：json=$json');
      return User(
        userId:int.parse(json['userId'].toString()), // 非空
        roleId:int.parse(json['roleId'].toString()), // 非空
        userAvatar:json.putIfAbsent('userAvatar', () => ''),
        userNickname:json.putIfAbsent('userNickname',() => null), // 非空
        userMobile:json.putIfAbsent('userMobile',() => null), // 非空
        userBorth:json.putIfAbsent('userBorth', () => ''),
        userAddress:json.putIfAbsent('userAddress', () => ''),
        userHobby:json.putIfAbsent('userHobby', () => ''),
        userMotto:json.putIfAbsent('userMotto', () => ''),
        facultyId:int.parse(json['facultyId'].toString()), // 非空
        specialtyId:int.parse(json['specialtyId'].toString()), // 非空
        facultyName:json.putIfAbsent('facultyName', () => null),
        specialtyName:json.putIfAbsent('specialtyName', () => null)
      );
    }
  
    ///
    /// 将Model转为Json
    ///
    Map<String, dynamic> toJson(User user){
      return {
      'userId':userId,
      'roleId':roleId,
      'userAvatar':userAvatar,
      'userNickname':userNickname,
      'userMobile':userMobile,
      'userBorth':userBorth,
      'userAddress':userAddress,
      'userHobby':userHobby,
      'userMotto':userMotto,
      'facultyId':facultyId,
      'specialtyId':facultyId
      };
    }
  
  
  
  }