# SQLiteObject_C
## 简介
**SQLiteObject_C** 的目的在于让coder **高效、便捷、简单** 的使用Sqlite.提供**数据Model对象**级别的对数据库的操作,便捷**创建关联表**, 便捷对关联 **查询、删除、插入**.
**SQLiteObject_C**分为三个部分:
***
## 一. SQLiteLanguage
**SQLiteLanguage**的作用是用来书写SQL(数据库结构化查询语言)的工具类,可以避开手写sql stirng 易出同时还保证了可读性,以下是简单举例:
1. 写一个创建Student数据库表的SQL:
```
SQLiteLanguage *sql = SQLlang.CREATE.TABLE(@"Student").COLUMNS(
SQLlang.columnName(@"ID").TEXT,
SQLlang.columnName(@"age").INTEGER,
SQLlang.columnName(@"name").TEXT,
nil
);
```
2. 写一个对Student数据库表进行插入的SQL:
```
SQLiteLanguage *sql  = SQLlang.INSERT.INTO(@"Student").COLUMNS(@"ID",@"age",@"name",nil).VALUES(@"'120702010011'",@"22",@"'yangYue'",nil);
```
3. 写一个对Student数据库表进行查询的SQL:
```
SQLiteLanguage *sql = SQLlang.SELECT(@"*",nil).FROM(@"Student");
```

***
## 二. SQLITEObjectC
一个对**Sqlite3 API** 进行封装的工具类,提供**连接打开、执行、关闭**数据库的基本操作
1. ```-(BOOL)connectionWithFilePath:(NSString *)filePath;```通过路径连接打开数据库如果数据库不存在则创建,例如:
```
//连接打开数据库(不存在则创建)
BOOL result = [SHARESQLITEObjectC connectionWithFilePath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:[NSString stringWithFormat:@"/%@",@"SQLITE_DATABASEE"]]];
```

2. ``` -(BOOL)execSQLL:(SQLiteLanguage *)SQLL result:(void(^)(NSString *errorInfor,NSArray<NSDictionary *> *resultArray))result; ``` 执行**SQL**并返回执行结果YES执行成功NO执行失败,result **Block**获取执行结果,例子如下:
* 创建Student数据库表:
```
//连接打开数据库(不存在则创建)
BOOL result = [SHARESQLITEObjectC connectionWithFilePath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:[NSString stringWithFormat:@"/%@",@"SQLITE_DATABASEE"]]];
//建Student表的sql
SQLiteLanguage * sql =SQLlang.CREATE.TABLE(@"Student").COLUMNS(
SQLlang.columnName(@"ID").TEXT,
SQLlang.columnName(@"age").INTEGER,
SQLlang.columnName(@"name").TEXT,
nil
);
result  = [SHARESQLITEObjectC execSQLL:sql result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {

}];
//关闭数据库
[self test_close];
```
* Student数据库表插入数据:
```
//连接打开数据库(不存在则创建)
BOOL result = [SHARESQLITEObjectC connectionWithFilePath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:[NSString stringWithFormat:@"/%@",@"SQLITE_DATABASEE"]]];
//Student表插入数据的sql
SQLiteLanguage *sql  = SQLlang.INSERT.INTO(@"Student").COLUMNS(@"ID",@"age",@"name",nil).VALUES(@"'120702010011'",@"22",@"'yangYue'",nil);
//执行sql
result = [SHARESQLITEObjectC execSQLL:sql result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
}];
//关闭数据库
[self test_close];
```
* 从Student数据库表查询数据:
```
//连接打开数据库(不存在则创建)
BOOL result = [SHARESQLITEObjectC connectionWithFilePath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:[NSString stringWithFormat:@"/%@",@"SQLITE_DATABASEE"]]];
//查询Student的sql
SQLiteLanguage *sql = SQLlang.SELECT(@"*",nil).FROM(@"Student");
//执行sql查询
result = [SHARESQLITEObjectC execSQLL:sql result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
NSLog(@"%@",resultArray);
}];
//关闭数据库
[self test_close];
```

3. ``` -(BOOL)execByTransactionWithSQLL:(SQLiteLanguage *)SQLL result:(void(^)(NSString *errorInfor,NSArray<NSDictionary *> *resultArray))result; ``` 事务的方式执行**SQL**.

***
