# SQLiteObject_C
## 简介
**SQLiteObject_C** 的目的在于让coder **高效、便捷、简单** 的使用Sqlite.提供**数据Model对象**级别的对数据库的操作,便捷**创建关联表**, 便捷对关联 **查询、删除、插入**.
**SQLiteObject_C**分为三个部分:
* 项目地址:https://github.com/pousniOS/SQLiteObject_C/tree/master/SQLiteObject_C
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
2. ```-(BOOL)open;```打开数据库.
```
//打开数据库
[SHARESQLITEObjectC open];
```
3. ```-(BOOL)close;```关闭数据库.
```
//关闭数据库
[SHARESQLITEObjectC close];
```
4. ``` -(BOOL)execSQLL:(SQLiteLanguage *)SQLL result:(void(^)(NSString *errorInfor,NSArray<NSDictionary *> *resultArray))result; ``` 执行**SQL**并返回执行结果YES执行成功NO执行失败,result **Block**获取执行结果,例子如下:
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

5. ``` -(BOOL)execByTransactionWithSQLL:(SQLiteLanguage *)SQLL result:(void(^)(NSString *errorInfor,NSArray<NSDictionary *> *resultArray))result; ``` 事务的方式执行**SQL**.

***
## 二. NSObject (SQLITE) 类别.
提供数据Model对象级别的对数据库的操作,**便捷创建关联表, 便捷对关联 查询、删除、插入**,下面我来实际举例.假设我们要对学生的 **个人信息、学生的学习成绩信息** 做存储、查询、删除、更新操作.
1. 我们有如下的Model类:
* 学生成绩的Model类**GradeModel**:
```
#import <Foundation/Foundation.h>
@interface GradeModel : NSObject
@property(nonatomic,copy)NSString *ID; 
@property(nonatomic,copy)NSString *remark;//备注
@property(nonatomic,copy)NSString *name;//科目名称
@property(nonatomic,assign)NSInteger fraction;//分数
@end
```
```
#import "GradeModel.h"
@implementation GradeModel
-(void)setValue:(id)value forKey:(NSString *)key{
[super setValue:value forKey:key];
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
}
+(NSString*)sqlite_tablePrimaryKeyValueSetProperty{
return @"ID";
}
@end
```

* 学生信息的Model类**StudentModel**:
```
#import <Foundation/Foundation.h>
#import "GradeModel.h"
@interface StudentModel : NSObject
@property(nonatomic,copy)NSString *stdID;//学号
@property(nonatomic,copy)NSString *cls;//班级
@property(nonatomic,copy)NSString *name;//名字
@property(nonatomic,assign)BOOL sex;//性别
@property(nonatomic,retain)NSMutableArray<GradeModel *> *transcript;//成绩单
@en
```
```
#import "StudentModel.h"
@implementation StudentModel
-(void)setValue:(id)value forKey:(NSString *)key{
if ([key isEqualToString:@"data"]) {
_transcript=[[NSMutableArray alloc] init];
[value enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
if ([value isKindOfClass:[NSDictionary class]]) {
GradeModel *model=[[GradeModel alloc] init];
[model setValuesForKeysWithDictionary:value];
[self->_transcript addObject:model];
}else{
[self->_transcript addObject:obj];
}
}];
}else{
[super setValue:value forKey:key];
}
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
}
//重写NSObject (SQLITE)类别的该方法,说明transcript属性里存储的是GradeModel类型的数据
+(NSDictionary*)sqlite_tablePropertyNameAndElementTypeDictionary{
return @{@"transcript":@"GradeModel"};
}
+(NSString*)sqlite_tablePrimaryKeyValueSetProperty{
return @"stdID";
}
@end
```
2. 我们通过 ```+(BOOL)sqlite_tableCreateWithIsAssociation:(BOOL)flag;```方法执行```[StudentModel sqlite_tableCreateWithIsAssociation:YES],```将创建出表明为**GradeModel、StudentModel**的两张数据库表包含里model类里的字段:
```
if ([StudentModel sqlite_tableCreateWithIsAssociation:YES]) {
NSLog(@"表创建成功");
}
```
3. ```-(BOOL)sqlite_tableInsertWithIsAssociation:(BOOL)flag;```方法插入数据,StudentModel表关联的GradeModel表的学生成绩信息也将一并被插入到GradeModel表里.
```
StudentModel *std=[[StudentModel alloc] init];
std.name=@"杨越";
std.stdID=@"000000";
std.sex=NO;
std.cls=@"六年级";
GradeModel *gradModel=[[GradeModel alloc] init];
gradModel.ID=@"0";
gradModel.name=@"数学";
gradModel.fraction=99;
gradModel.remark=@"考得不错再接再厉";

GradeModel *gradModel1=[[GradeModel alloc] init];
gradModel1.ID=@"1";
gradModel1.name=@"语文";
gradModel1.fraction=60;
gradModel1.remark=@"要加油哦";
std.transcript=[@[gradModel,gradModel1] mutableCopy];

//插入数据
if ([std sqlite_tableInsertWithIsAssociation:YES]) {
NSLog(@"插入成功");
}
```
4. ```+(NSArray *)sqlite_tableSelectWithCondition:(SQLiteLanguage *)condition IsAssociation:(BOOL)flag;```进行数据查询,StudentModel表关联的GradeModel表的学生成绩信息也将一并被查询出来.
```
NSArray *array=[StudentModel sqlite_tableSelectWithCondition:SQLlang.WHERE(@"stdID='000000'") IsAssociation:YES];
[array toDictionary];
```
5. ```-(BOOL)sqlite_tableUpdateWithIsAssociation:(BOOL)flag;```通过主键更新表数据,StudentModel表关联的GradeModel表的学生成绩信息也将一并被更新.
```
StudentModel *std=[[StudentModel alloc] init];
std.name=@"杨越";
std.stdID=@"000000";
std.sex=NO;
std.cls=@"五年级";
GradeModel *gradModel=[[GradeModel alloc] init];
gradModel.ID=@"0";
gradModel.name=@"数学";
gradModel.fraction=99;
gradModel.remark=@"考得不错再接再厉";

GradeModel *gradModel1=[[GradeModel alloc] init];
gradModel1.ID=@"1";
gradModel1.name=@"语文";
gradModel1.fraction=100;
gradModel1.remark=@"要加油哦";
std.transcript=[@[gradModel,gradModel1] mutableCopy];

if ([std sqlite_tableUpdateWithIsAssociation:YES]) {
NSLog(@"更新成功");
} 
```
6. ``` +(BOOL)sqlite_tableDeleteWithCondition:(SQLiteLanguage *)condition IsAssociation:(BOOL)flag;```删除表数据,StudentModel表关联的GradeModel表的学生成绩信息也将一并被删除.
```
if ([StudentModel sqlite_tableDeleteWithCondition:SQLlang.WHERE(@"stdID='000000'") IsAssociation:YES]){
NSLog(@"删除成功");
}
```
NSObject (SQLITE)类别还支持很多功能可以通过查看提供的API.
***
