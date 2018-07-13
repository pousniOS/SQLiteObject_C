# SQLiteObject_C

**前言**
           
说一说写这个类的初衷吧，在写项目的时候做数据持久化存储是必不可少的,所以在项目里会频繁的使用到sqlite数据库。
虽然现在有很多相关的对sqlist C语言API封装的工具类库(比如经常在用的FMDB)，但是依然发现有一个不尽人意的地方。
当我在使用FMDB提供的API来做查增删改等操作时，需要我们写SQL语句来执行API，这时就需要我手动的书写SQL语句字符
串。有时我们写的SQL语句会比较复杂然后就会很容易出现SQL语句书写错误的情况，然后蛋疼的事情来了你的去检查你的S
QL字符串倒地错哪了,费时又费脑，然后我就在思考我可不可以写一个用来描述SQL语句的工具类呢(当然工具类得达到我的预期
才行)?，答案是肯定的SQLiteLanguage就是用来描述SQL语句的类（main文件里有实例代码）。SQLiteLanguage里定义了
一些SQL关键字的方法，后续将会不断完善（如果有什么做的不对的地方希望得到各位的大神的提点）。

>**使用实例： 测试函数**

>>1.打开数据库，通过SQLITEObjectC类的单例来创建数据库连接：
```
void openDB(){
NSString *pathStr =[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/School.db"];
if (![[SQLITEObjectC share] openWithFilePath:pathStr]) {
NSLog(@"数据库打开失败");
}
}
#pragma mark - 2.关闭数据库：
void closeDB(){
if (![[SQLITEObjectC share] close]) {
NSLog(@"数据库关闭失败");
}
}
```
>>3.创建表，通过SQLiteLanguage来构建SQL然后通过SQLITEObjectC类的单例的-(BOOL)execSQL:(SQLiteLanguage *)sqll方法执行SQL语句：
```
void createTable(){
SHARESQLITEObjectC.SQLL.CREATE.TABEL(@"Sutdent").COLUMNS(
SQLlang.columnName(@"age").INTEGER,//列名叫age,INTEGER类型的数据,不许为空
SQLlang.columnName(@"name").TEXT,
SQLlang.columnName(@"ID").TEXT.NOT(@"NULL").PRIMARY.KEY(nil),//列名叫ID,TEXT类型的数据同时设置为主键,不许为空
nil
);
if (![[SQLITEObjectC share] execSQLL]) {
NSLog(@"创建表失败");
}
}
```
>>4.删除表：
```
void dropTable(){
SHARESQLITEObjectC.SQLL.DROP.TABEL(@"Sutdent");
if (![[SQLITEObjectC share] execSQLL]) {
NSLog(@"删除表失败");
}
}
```

>>5.向表插入数据：
```
void insert(){
SHARESQLITEObjectC.SQLL.INSERT.INTO(@"Sutdent").COLUMNS(@"age",@"name",@"ID",nil).VALUES(@"24",@"'马悦'",@"120702010013",nil);
if (![[SQLITEObjectC share] execSQLL]) {
NSLog(@"数据插入失败");
}
}
```

>>6.数据查询，查询到的结果通过SQLITEObjectC类的单例execSQLResultArray获取：
```
void SELECT(){
SHARESQLITEObjectC.SQLL.SELECT(SQL_DISTINCT,@"*",nil).FROM(@"Sutdent").WHERE(@"name='马悦'");
if (![[SQLITEObjectC share] execSQLL]) {
NSLog(@"数据查询失败");
}else{
NSLog(@"%@",[SQLITEObjectC share].execSQLResultArray);
}
}
```
>>7.修改表数据：
```
void UPDATE(){
SHARESQLITEObjectC.SQLL.UPDATE(@"Sutdent").SET(@"name='小明'",@"age=90",nil).WHERE(@"ID='120702010019'");
if (![[SQLITEObjectC share] execSQLL]) {
NSLog(@"数据更新失败");
}
}
```
>>8.删除表数据：
```
void DELETE(){
SHARESQLITEObjectC.SQLL.DELETE.FROM(@"Sutdent").WHERE(@"ID='120702010019'");
if (![[SQLITEObjectC share] execSQLL]) {
NSLog(@"数据删除失败");
}
}
```
>>9.排序：
```
void ORDERBY(){
SHARESQLITEObjectC.SQLL.SELECT(SQL_DISTINCT,@"*",nil).FROM(@"Sutdent").ORDER.BY(@"ID").DESC;
if (![[SQLITEObjectC share] execSQLL]) {
NSLog(@"排序失败");
}else{
NSLog(@"%@",[SQLITEObjectC share].execSQLResultArray);
}
}
```
>>10.事务：
```
void Transaction(){
NSLog(@"start:%@",[NSDate date]);
SHARESQLITEObjectC.SQLL.BEGIN.TRANSACTION.SEMICOLON;
for (NSInteger i=0; i<100000; i++) {
SHARESQLITEObjectC.SQLL.INSERT.INTO(@"Goods").COLUMNS(@"ID",@"name",@"price",@"imageUrl",nil).VALUES(@"'120702010011'",@"'这是啥东西'",@"9999999999999",@"'https://120702010011/yangyue.com'",nil).SEMICOLON;
}
SHARESQLITEObjectC.SQLL.COMMIT.SEMICOLON;
    
NSLog(@"start:%@",[NSDate date]);
if (!SHARESQLITEObjectC.execSQLL) {
NSLog(@"事物执行失败");
}
NSLog(@"end:%@",[NSDate date]);
}
```



    
