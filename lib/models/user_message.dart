///
/// 用户消息（服务端通知用户，并携带的用户消息）2020/04/17 21:02
///  * 0 ==> 应用通知
///  * 1 ==> mongo@大宝
///  * 2 ==> mongo评论了你的动态
///  * 3 ==> mongo回复了你的评论
///  * 4 ==> mongo赞了你的动态
///  * 5 ==> mongo赞了你的评论
/// * **其中，[2,3]均为APP端评论我类型；[4,5]均为APP端赞我类型**
/// 
///
class UserMessage {

  ///
  /// 消息的编号
  ///
  //String sendno;
  ///
  /// 消息头
  ///   例如：
  ///        0. 应用通知
  ///        1. mongo@大宝
  ///        2. mongo评论了你的动态
  ///        3. mongo回复了你的评论
  ///        4. mongo赞了你的动态
  ///        5. mongo赞了你的评论
  ///
  ///
  String title; // 

  ///
  /// 消息体
  ///   显示的具体内容，用于在消息页面中进行显示
  String content; 

  ///
  /// 消息类型
  ///   参照消息头中的编号
  int messageType;

  /// 目标用户名
  String toUserName; 

  /// 来源用户名
  String fromUserName; 

  /// 来源用户的ID
  int fromUserId; 

  /// 来源用户头像
  String fromUserAvatar; 

  /// 用于查询消息context所对应的具体moving
  int queryId; 

  /// 接收时间
  String receivedTime; 

  /// 是否已读
  String read; 

/*   int commentId; // 评论ID
  
  int movingId; // 动态ID
  
  int replyId; // 评论回复ID */
/* 
  String commentContext; // 评论内容

  String movingContext; // 动态内容

  String replyContext; // 评论回复内容
*/
 
  UserMessage({this.title,this.content,this.messageType,this.fromUserId,this.fromUserName,this.fromUserAvatar,this.read = 'false',this.toUserName = '',this.queryId = 0,this.receivedTime});

  @override
  String toString() {
    return '{'
              +', title= ' + this.title
              +', content= ' + this.content
              +', messageType= ' + this.messageType.toString()
              +', fromUserName= ' + this.fromUserName
              +', fromUserId= ' + this.fromUserId.toString()
              +', fromUserAvatar= ' + this.fromUserAvatar
              +', toUserName= ' + this.toUserName
              +', queryId= ' + this.queryId.toString()
              +', receivedTime= ' + this.receivedTime
              +', read= ' + this.read.toString()+
            '}';
   }

  ///
  /// Json模型化
  ///
  factory UserMessage.fromJson(Map<String, dynamic> json){
      // print('UserMessage接收消息:'+json.toString());
      // print(json.runtimeType.toString());
      if(json.isEmpty){
        print('没有信息可以构造UserMessage！');
        return null;
      }

        // final String tilte = json['title'];
        // final String content = json['content'];
        // final int messageType = int.parse(json['messageType'].toString());
        // final String fromUserName = json.putIfAbsent('fromUserName', () => null);
        // final int fromUserId = int.parse(json['fromUserId'].toString());
        // final String fromUserAvatar = json.putIfAbsent('fromUserAvatar',() => null);
        // final int queryId = int.parse(json['queryId'].toString());
        // final String receivedTime = json['receivedTime'];
        // final String read = json['read'];
        // print('UserMessage中的Map取出来的信息值：');
        // print(tilte);
        // print(content);
        // print(messageType.toString());
        // print(fromUserName);
        // print(fromUserId.toString());
        // print(fromUserAvatar);
        // print(queryId.toString());
        // print(receivedTime);
        // print(read);
        UserMessage userMessage;

      

       try{
          userMessage =  UserMessage( 
              title : json['title'],
              content : json['content'],
              messageType : int.parse(json['messageType'].toString()),
              fromUserName : json.putIfAbsent('fromUserName', () => ''),
              fromUserId : int.parse(json['fromUserId'].toString()),
              fromUserAvatar : json.putIfAbsent('fromUserAvatar',() => ''),
              // toUserName : null,
              queryId : int.parse(json['queryId'].toString()),
              receivedTime : json['receivedTime'],
              read : json['read'],
            );
          }catch (e){
            print('构造用户信息模型异常了!');
            print(e);
          }
        print('用户信息类中创建的对象为:');
        print(userMessage);

      return userMessage;
  }

  ///
  /// UserMessage转为Map
  /// 
  Map<String,dynamic> toMap(){

    Map<String,dynamic> messageMap = {
      "title" : this.title,
      "content" : this.content,
      "messageType" : this.messageType,
      "fromUserName" : this.fromUserName,
      "fromUserId" : this.fromUserId,
      "fromUserAvatar" : this.fromUserAvatar,
      "toUserName" : this.toUserName,
      "queryId" : this.queryId,
      "receivedTime" : this.receivedTime,
      "read" : this.read
    }; 
    print('当前UserMessage转为Map，转换结果：messageMap= ' + messageMap.toString());
    return messageMap;

  }

}