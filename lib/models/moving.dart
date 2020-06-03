import 'dart:convert';

import 'package:bju_information_app/models/comment.dart';


///
/// 动态模型
/// 2020/2/23 22:06
///
class Moving {

int movingAuthorId;
String movingAuthorAvatar;
String movingAuthorName;
String movingAuthorPhone;
String movingContent;
int movingId;
/// 图片组：英文‘,’分割
List movingImages;
String movingType;
/// 话题组：英文‘,’分割
List movingTopics;
int movingLike;
/// 点赞用户组：英文‘,’分割
List movingLikeUsers;
int movingBrowse;
int movingCommentCount;
String movingCreateTime;

Moving({
  this.movingAuthorId,
  this.movingAuthorAvatar,
  this.movingAuthorName,
  this.movingAuthorPhone,
  this.movingContent,
  this.movingId,
  this.movingImages,
  this.movingType,
  this.movingTopics,
  this.movingLike,
  this.movingLikeUsers,
  this.movingBrowse,
  this.movingCommentCount,
  this.movingCreateTime
});

factory Moving.fromJson(Map<String,dynamic> json) => Moving(
  movingAuthorId: int.parse(json['movingAuthorId'].toString()),
  movingAuthorAvatar: json['movingAuthorAvatar'],
  movingAuthorName: json['movingAuthorName'],
  movingAuthorPhone: json['movingAuthorPhone'],
  movingContent: json['movingContent'],
  movingId: int.parse(json['movingId'].toString()),
  movingImages: json.putIfAbsent('movingImages', () => [])?.toString()?.split(','),
  movingType: json['movingType'],
  movingTopics: json.putIfAbsent('movingTopics', () => [])?.toString()?.split(','),
  movingLike: int.parse(json['movingLike'].toString()),
  movingLikeUsers: json.putIfAbsent('movingLikeUsers', () => [])?.toString()?.split(','),
  movingBrowse: int.parse(json['movingBrowse'].toString()),
  movingCommentCount: int.parse(json['movingCommentCount'].toString()),
  movingCreateTime: json['movingCreateTime']
);

 @override
  String toString() {
    
    return '{movingAuthorId: '+this.movingAuthorId.toString()
              +', movingAuthorAvatar: '+this.movingAuthorAvatar
              +', movingAuthorName: '+this.movingAuthorName
              +', movingAuthorPhone: '+ this.movingAuthorPhone
              +', movingContent: '+this.movingContent
              +', movingId: '+this.movingId.toString()
              +', movingImages: '+ this.movingImages.toString()
              +', movingType: '+this.movingType
              +', movingTopics: '+ this.movingTopics.toString()
              +', movingLike: '+ this.movingLike.toString()
              +', movingLikeUsers: '+ this.movingLikeUsers.toString()
              +', movingBrowse: '+this.movingBrowse.toString()
              +', movingCommentCount: '+ this.movingCommentCount.toString()
              +', movingCreateTime: '+ this.movingCreateTime+'}';
  }

}

/// 动态详情模型
/// 2020/3/20 15:42
class MovingDetails {


int movingAuthorId;
// String movingAuthorAvatar;
String movingAuthorName;
String movingAuthorPhone;
String movingContent;
int movingId;
/// 图片组：英文‘,’分割
List movingImages;
String movingType;
/// 话题组：英文‘,’分割
List movingTopics;
int movingLike;
/// 点赞用户组：英文‘,’分割
List<String> movingLikeUsers;
int movingBrowse;
String movingCreateTime;

// 评论列表
List<CommentVO> commentReplyList;


MovingDetails({
  this.movingAuthorId,
  // this.movingAuthorAvatar,
  this.movingAuthorName,
  this.movingAuthorPhone,
  this.movingContent,
  this.movingId,
  this.movingImages,
  this.movingType,
  this.movingTopics,
  this.movingLike,
  this.movingLikeUsers,
  this.movingBrowse,
  this.movingCreateTime,
  this.commentReplyList
});

factory MovingDetails.fromJson(Map<String, dynamic> json) => MovingDetails(
  movingAuthorId: int.parse(json['movingAuthorId'].toString()),
  // movingAuthorAvatar: json['movingAuthorAvatar'],
  movingAuthorName: json['movingAuthorName'],
  movingAuthorPhone: json['movingAuthorPhone'],
  movingContent: json['movingContent'],
  movingId: int.parse(json['movingId'].toString()),
  movingImages: json.putIfAbsent('movingImages', () => [])?.toString()?.split(','),
  movingType: json['movingType'],
  movingTopics: json.putIfAbsent('movingTopics', () => [])?.toString()?.split(','),
  movingLike: int.parse(json['movingLike'].toString()),
  movingLikeUsers: json.putIfAbsent('movingLikeUsers', () => [])?.toString()?.split(','),
  movingBrowse: int.parse(json['movingBrowse'].toString()),
  movingCreateTime: json['movingCreateTime'],
  commentReplyList: (json.putIfAbsent('commentReplyList', () => []) as List)?.map<CommentVO>((m)=> CommentVO.fromJson(m))?.toList()
);

@override
String toString() {
    
  return '{movingAuthorId: ' + this.movingAuthorId.toString()
            // +', movingAuthorAvatar:' + this.movingAuthorAvatar
            +', movingAuthorName:' + this.movingAuthorName
            +', movingAuthorPhone:' + this.movingAuthorPhone
            +', movingContent:' + this.movingContent
            +', movingId:' + this.movingId.toString()
            +', movingImages:' + this.movingImages.toString()
            +', movingType:' + this.movingType
            +', movingTopics:' + this.movingTopics.toString()
            +', movingLike:' + this.movingLike.toString()
            +', movingLikeUsers:' + this.movingLikeUsers.toString()
            +', movingBrowse:' + this.movingBrowse.toString()
            +', movingCreateTime:' + this.movingCreateTime
            +', commentReplyList:' + this.commentReplyList.toString() + '}';
}













}

