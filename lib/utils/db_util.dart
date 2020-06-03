import 'package:bju_information_app/constants/bju_constant.dart';
import 'package:bju_information_app/models/user_message.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

///
/// SqlLite数据库工具类
/// 2020/04/17 22:54
///
class DBUtil{

  /// 数据库版本号
  static final int _DB_VERSION = 1;

  /// 数据库名称
  static final String _DB_NAME = 'BJU.db';

  /// 数据库中表的名称
  static final String _TABLE_NAME = 'user_message';

  /// 建表的SQL语句 (与UserMessage字段基本一致，多了owner字段，该字段标识UserMessage所属的用户)
  static final String _CREATE_TABLE_SQL = '''
              CREATE TABLE $_TABLE_NAME (
                title CHAR(30) NOT NULL,
                content TEXT NOT NULL,
                messageType INT NOT NULL,
                fromUserName CHAR(25),
                fromUserId INT, 
                fromUserAvatar TEXT,
                toUserName CHAR(25),
                queryId INT NOT NULL,
                receivedTime TEXT NOT NULL,
                read CHAR(10) NOT NULL,
                owner CHAR(25)
              )
              ''';

  /// 数据库实例
  static Database _database;

  get database => _database;

  // 打开数据库
  static Future<Database> openDB() async {

    // 获取数据库路径databasesPath
    final String databasesPath = await getDatabasesPath();
    print('获取的SqlLite数据库路径为：dbPath=' + databasesPath);
    String dbPath = join(databasesPath,_DB_NAME);
    print('获取的SqlLite数据库文件的路径为：dbPath=' + dbPath);
    // 打开并创建数据库
    final Database db =  await openDatabase(dbPath, version: _DB_VERSION, onCreate: (db,version) async {
      // 数据库创建的时候创建表
      final bool isExist = await _isExistTable(db,_TABLE_NAME);
      print('数据库工具类中，建表前判断表是否存在：isExist=' + isExist.toString());
      // 表已经存在      
      if(isExist) return;
      // 执行建表语句
      await db.execute(_CREATE_TABLE_SQL);
      
    });
    print('获取的数据库实例为 db=' + db.toString());
    // 设置数据库实例
    // _database = db;
    return db;
  }

  /// 判断数据库中是否存在待创建的表
  /// * [db]  当前数据库
  /// * [tableName] 表的名称
  static Future<bool> _isExistTable(Database db,String tableName) async {
    // 执行查询操作，表中是否有数据
    final int count = await db.query(tableName)
        .then((onValue) => onValue?.length??0)
        .catchError((onError) {
          print('判断表是否存在出错了，错误信息如下：');
          print(onError);
        });
    print('数据库工具类中，建表前判断表是否存在，查询表中的记录数：count=' + count.toString());
    return count != null && count > 0;
  }

  ///
  /// 插入UserMessage到表中（包含用户信息）
  /// * [values]  插入的数据
  /// *__返回执行的结果（true?false）__
  ///
  static Future<bool> insertMessage(Map<String,dynamic> values) async {
    print('数据库工具类，插入UserMessage到表中，入参：type=' + values.toString());
    if((values?.isEmpty??false)){
      print('数据库工具类，插入UserMessage到表中，等待插入的数据无效！');
      return false;
    }
    /// 获取数据库实例
    Database db = (_database??await openDB());
    print('数据库工具类，插入UserMessage到表中：获得 DB=' + db.toString());
    // 插入数据到SQLLite表中
    int count = await db.insert(_TABLE_NAME, values, conflictAlgorithm:ConflictAlgorithm.replace);
    // 关闭数据库
    close();
    print('数据库工具类，插入UserMessage到表：插入结果 count=' + count.toString());
    return count == null || count == 0 ? false : true;
  }

  /// 
  /// 更新信息列表为已读
  /// * [type]  消息类型
  /// * [owner] 登录的用户手机号码
  /// *__返回执行的结果（true?false）__
  /// 
  static Future<bool> readMessagesWithTypeAndOwner(int type,String owner) async {
    print('数据库工具类，更新UserMessage表中的数据为已读，入参：type=$type，owner=$owner');
    if(type == null || (owner?.isEmpty??true)){
      print('数据库工具类，更新UserMessage表中的数据为已读，更新条件无效！');
      return false;
    }
    /// 获取数据库实例
    Database db = (_database??await openDB());
    print('数据库工具类，更新UserMessage表中的数据为已读，获得 DB=' + db.toString());
    // 标记表中的数据为已读状态
    int count = await db.update(_TABLE_NAME,{'read':'true'},where: 'owner = ? and messageType = ?',whereArgs: [owner,type]);
    // 关闭数据库
    close();
    print('数据库工具类，更新UserMessage表中的数据为已读，更新结果 count=' + count.toString());
    return count == null || count == 0 ? false : true;
  }

  ///
  /// 查询user_message表中数据（按照时间排序）
  /// * [type]  消息类型
  /// * [owner] 登录的用户手机号码
  /// *__返回执行的结果（List<UserMessage>）__
  ///
  static Future<List<UserMessage>> queryMessagesWithTypeAndOwner(int type,String owner) async {
    print('数据库工具类，按照类别与拥有者查询，入参：type=$type，owner=$owner');
    // if(type == null || (owner?.isEmpty??true)){
    //   print('数据库工具类，按照类别与拥有者查询，，查询条件无效！');
    //   return null;
    // }
    if((type == null || type != 0) && (owner == null || owner == '')){
      print('数据库工具类，按照类别与拥有者查询，非应用消息查询，owner无效');
      return null;
    }
    /// 获取数据库实例
    Database db = (_database??await openDB());
    print('数据库工具类，按照类别与拥有者查询：获得 DB=' + db.toString());
    // 执行查询操作
    List<Map<String, dynamic>> queryList = await db.query(_TABLE_NAME, 
      columns: [
        'title',
        'content',
        'messageType',
        'fromUserName',
        'fromUserId',
        'fromUserAvatar',
        'toUserName',
        'queryId',
        'receivedTime',
        'read'
      ],
      where:'owner = ? and messageType = ?',
      whereArgs:[type == 0 ? BJUConstants.alertOwner : owner,type],
      orderBy: 'receivedTime DESC'
    );
    // 关闭数据库
    close();
    // 转换结果
    final List<UserMessage> resultList = transformList2UserMessage(queryList);
    print('数据库工具类，按照类别与拥有者查询：获得结果 resultList=' + resultList.toString());
    return resultList;
  }


  static Future<int> queryCountWithTypeAndOwner(int type,String owner) async {
    print('数据库工具类，按照类别与拥有者查询，入参：type=$type，owner=$owner');
    // if(type == null || (owner?.isEmpty??true)){
    //   print('数据库工具类，按照类别与拥有者查询，，查询条件无效！');
    //   return null;
    // }
    if((type == null || type != 0) && (owner == null || owner == '')){
      print('数据库工具类，按照类别与拥有者查询，非应用消息查询，owner无效');
      return null;
    }
    /// 获取数据库实例
    Database db = (_database??await openDB());
    print('数据库工具类，按照类别与拥有者查询：获得 DB=' + db.toString());
    // 执行查询操作
    List<Map<String, dynamic>> queryList = await db.query(_TABLE_NAME, 
      columns: [
        'title',
        'content',
        'messageType',
        'fromUserName',
        'fromUserId',
        'fromUserAvatar',
        'toUserName',
        'queryId',
        'receivedTime',
        'read'
      ],
      where:'owner = ? and messageType = ?',
      whereArgs:[type == 0 ? BJUConstants.alertOwner : owner,type],
      orderBy: 'receivedTime DESC'
    );
    // 关闭数据库
    close();
    // 转换结果
    final List<UserMessage> resultList = transformList2UserMessage(queryList);
    print('数据库工具类，按照类别与拥有者查询：获得结果 resultList=' + resultList.toString());
    return 0;
  }

  ///
  /// 查询得到的数据转换并包装
  /// * **List<Map<String, dynamic>>** 转为 **UserMessage**
  /// 
  static List<UserMessage> transformList2UserMessage(List<Map<String, dynamic>> mapList){
    // map封装为具体类型
    final List<UserMessage> list = mapList.map<UserMessage>((m) => UserMessage.fromJson(m)).toList();
    print('数据库工具类，查询结果转换模型，结果为：list=' + list.toString());
    return list;
  }
// static Future<void> deleteDatabase(){
  
// }


  static Future<void> deleteTable() async {
    int count = await (_database??await openDB()).delete(_TABLE_NAME);
    print('数据库工具类，删除数据表，结果：count= ' + count.toString());
  }



  /// 关闭数据库
  static Future<void> close(){
    // 关闭数据库连接
    _database?.close();
    // 空引用
    _database = null;
  }
  


}