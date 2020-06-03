
///
/// 评论实体
/// 2020/03/26 15:56
///
class Comment{

    
}

///
/// 评论VO
/// 2020/03/24 16:45
///
class CommentVO {


  /// 评论ID
  int commentId;
  /// 评论内容
  String commentContent;
  /// 评论点赞量
  int commentLike;
  /// 点赞用户列表
  List<String> commentLikeUsers;
  /// 评论时间
  String commentCreateTime;
  /// 评论人ID
  int commentAuthorId;
  /// 评论人头像
  String commentAuthorAvatar;
  /// 评论人昵称
  String commentAuthorName;
  /// 评论人手机号
  String commentAuthorPhone;
  /// 父评论ID
  int parentCommentId;
  /// 父评论内容
  String parentCommentContent;
  /// 父评论点赞量
  int parentCommentLike;
  /// 父评论创建时间
  String parentCommentCreateTime;
  /// 父评论作者ID
  int parentCommentAuthorId;
  /// 父评论作者头像
  String parentCommentAuthorAvatar;
  /// 父评论作者昵称
  String parentCommentAuthorName;
  /// 父评论作者手机号码
  String parentCommentAuthorPhone;


  CommentVO({
    this.commentId,
    this.commentContent,
    this.commentLike,
    this.commentLikeUsers,
    this.commentCreateTime,
    this.commentAuthorId,
    this.commentAuthorAvatar,
    this.commentAuthorName,
    this.commentAuthorPhone,
    this.parentCommentId,
    this.parentCommentContent,
    this.parentCommentLike,
    this.parentCommentCreateTime,
    this.parentCommentAuthorId,
    this.parentCommentAuthorAvatar,
    this.parentCommentAuthorName,
    this.parentCommentAuthorPhone,
  });


  factory CommentVO.fromJson(Map<String, dynamic> json) => CommentVO(
      commentId: int.parse(json['commentId'].toString()),
      commentContent: json['commentContent'],
      commentLike: int.parse(json['commentLike'].toString()),
      commentLikeUsers: json.putIfAbsent('commentLikeUsers', () => [])?.toString()?.split(','),
      commentCreateTime: json['commentCreateTime'],
      commentAuthorId: int.parse(json['commentLike'].toString()),
      commentAuthorAvatar: json['commentAuthorAvatar'],
      commentAuthorName: json['commentAuthorName'],
      commentAuthorPhone: json['commentAuthorPhone'],
      parentCommentId: json.putIfAbsent('parentCommentId', () => null),
      parentCommentContent: json.putIfAbsent('parentCommentContent', () => null),
      parentCommentLike: json.putIfAbsent('parentCommentLike', () => null),
      parentCommentCreateTime: json.putIfAbsent('parentCommentCreateTime', () => null),
      parentCommentAuthorId: json.putIfAbsent('parentCommentAuthorId', () => null),
      parentCommentAuthorAvatar: json.putIfAbsent('parentCommentAuthorAvatar', () => null),
      parentCommentAuthorName: json.putIfAbsent('parentCommentAuthorName', () => null),
      parentCommentAuthorPhone: json.putIfAbsent('parentCommentAuthorPhone', () => null),
  );

  @override
  String toString() {
    return '{: commentId: ' + this.commentId.toString()
            +', commentContent: ' + this.commentContent
            +', commentLike: ' + this.commentLike.toString()
            +', commentLikeUsers: ' + this.commentLikeUsers.toString()
            +', commentCreateTime: ' + this.commentCreateTime
            +', commentAuthorId: ' + this.commentAuthorId.toString()
            +', commentAuthorAvatar: ' + this.commentAuthorAvatar
            +', commentAuthorName: ' + this.commentAuthorName
            +', commentAuthorPhone: ' + this.commentAuthorPhone
            +', parentCommentId: ' + this.parentCommentId.toString()??''
            +', parentCommentContent: ' + this.parentCommentContent??''
            +', parentCommentLike: ' + this.parentCommentLike.toString()??''
            +', parentCommentCreateTime: ' + this.parentCommentCreateTime??''
            +', parentCommentAuthorId: ' + this.parentCommentAuthorId.toString()??''
            +', parentCommentAuthorAvatar: ' + this.parentCommentAuthorAvatar??''
            +', parentCommentAuthorName: ' + this.parentCommentAuthorName??''
            +', parentCommentAuthorPhone: ' + this.parentCommentAuthorPhone??'' + '}';
  }

}