//
//  SQLiteLanguage.h
//  SQLiteLanguageStructure
//
//  Created by POSUN-MAC on 2018/6/23.
//  Copyright © 2018年 POSUN-MAC. All rights reserved.
//
/**
 该类的目的是快速准确的书写要执行的SQL语句，包含了SQL常用的关键字,
 通过提供的关键字来书写你要执行的SQL语句。后续将不断完善。
 **/
#import <Foundation/Foundation.h>
/**排重关键字**/
static NSString *const SQL_DISTINCT=@"DISTINCT";
/**快速创建SQLiteLanguage对象**/
#define SQLlang [[SQLiteLanguage alloc] init]
@interface SQLiteLanguage : NSObject
/**SQL语句**/
@property(nonatomic,copy,readonly)NSString *sql;

/**清除构造的sql语句**/
-(SQLiteLanguage*)RESET;
+(instancetype)share;
#pragma mark ============ 创建表 ============
/**创建**/
-(SQLiteLanguage *)CREATE;
-(SQLiteLanguage *)FOREIGN;
-(SQLiteLanguage * (^)(NSString *tableName))REFERENCES;
-(SQLiteLanguage *)PRIMARY;
/**
 该方法的用处
 1.可以用来表示设置主键外键时的key。
 **/
-(SQLiteLanguage * (^)(NSString *fristName,...))KEY;//结束记得加nil。
-(SQLiteLanguage * (^)(NSString *value))NOT;
-(SQLiteLanguage * (^)(NSString *name))TABEL;
-(SQLiteLanguage * (^)(id fristColumn,...))COLUMNS;//结束记得加nil。
-(SQLiteLanguage * (^)(NSString *name))columnName;
-(SQLiteLanguage * (^)(NSString *name))CONSTRAINT;
#pragma mark - ============ 约束 ============
- (SQLiteLanguage * )UNIQUE;
- (SQLiteLanguage * (^)(NSString *condition))CHECK;
- (SQLiteLanguage * (^)(NSString *value))DEFAULT;
- (SQLiteLanguage *)AUTOINCREMENT;
#pragma mark - ============ 表字段数据类型 ============
/**整型**/
-(SQLiteLanguage *)INTEGER;//值是一个带符号的整数，根据值的大小存储在 1、2、3、4、6 或 8 字节中。
/**浮点**/
-(SQLiteLanguage *)REAL;//值是一个浮点值，存储为 8 字节的 IEEE 浮点数字。
/**字符串**/
-(SQLiteLanguage *)TEXT;//值是一个文本字符串，使用数据库编码（UTF-8、UTF-16BE 或 UTF-16LE）存储。
/**布尔**/
-(SQLiteLanguage *)BLOB;//值是一个 blob 数据，完全根据它的输入存储。

#pragma mark ============ 删除表 ============
/**删除**/
-(SQLiteLanguage *)DROP;
#pragma mark ============ 表数据插入 ============
/**插入**/
-(SQLiteLanguage *)INSERT;
- (SQLiteLanguage * (^)(NSString *tableName))INTO;
/**值**/
- (SQLiteLanguage * (^)(NSString *fristValue,...))VALUES;//结束记得加nil。
#pragma mark ============ SELECT查询 ============
/**从**/
- (SQLiteLanguage * (^)(NSString *tableName))FROM;
- (SQLiteLanguage * (^)(NSString *condition,NSString *fristName,...))SELECT;//结束记得加nil。
- (SQLiteLanguage * (^)(NSString *name))WHERE;
/**偏移**/
- (SQLiteLanguage * (^)(NSString *rowNumber))OFFSET;
- (SQLiteLanguage * (^)(NSString *rows))LIMIT;

#pragma mark ============ 运算符 ============
/**与**/
- (SQLiteLanguage * (^)(NSString *value))AND;
/**或**/
- (SQLiteLanguage * (^)(NSString *value))OR;
/**存在**/
- (SQLiteLanguage * (^)(SQLiteLanguage *sqll))EXISTS;
/**什么和什么之间**/
- (SQLiteLanguage * (^)(NSString *value))BETWEEN;
/**像什么**/
- (SQLiteLanguage * (^)(NSString *value))LIKE;
/**是**/
- (SQLiteLanguage * (^)(NSString *value))IS;
- (SQLiteLanguage * (^)(NSString *value))GLOB;
/**在什么里**/
- (SQLiteLanguage * (^)(NSString *value,...))IN;//结束记得加nil。

#pragma mark ============ UPDATE更新表数据 ============
/**更新**/
-(SQLiteLanguage * (^)(NSString *tableName))UPDATE;
/**
 设置
 **/
-(SQLiteLanguage * (^)(NSString *keyAndValue,...))SET;//结束记得加nil。

#pragma mark ============ DELETE删除表数据 ============
/**
 删除
 **/
-(SQLiteLanguage *)DELETE;
#pragma mark ============ ORDER BY排序 ============
/**通过**/
-(SQLiteLanguage * (^)(NSString *name))BY;
-(SQLiteLanguage *)ORDER;
/**降序**/
-(SQLiteLanguage *)DESC;
/**升序**/
-(SQLiteLanguage *)ASC;
#pragma mark ============ GROUP BY分组 ============
/**分组**/
-(SQLiteLanguage *)GROUP;
#pragma mark ============ HAVING ============
/**
 HAVING 子句允许指定条件来过滤将出现在最终结果中的分组结果。
 WHERE 子句在所选列上设置条件，而 HAVING 子句则在由 GROUP BY 子句创建的分组上设置条件。
 **/
- (SQLiteLanguage * (^)(NSString *value))HAVING;
#pragma mark ============ ALTER修改表 ============
/**添加**/
-(SQLiteLanguage * (^)(NSString *value))ADD;
/**修改**/
-(SQLiteLanguage *)ALTER;
/**列**/
-(SQLiteLanguage * (^)(NSString *name))COLUMN;
#pragma mark ============ 事务 ============
/**开始**/
-(SQLiteLanguage *)BEGIN;
/**事务**/
-(SQLiteLanguage *)TRANSACTION;
/**提交**/
-(SQLiteLanguage *)COMMIT;
/**回滚**/
-(SQLiteLanguage *)ROLLBACK;
#pragma mark ============ VACUUM ============
/**VACUUM 命令通过复制主数据库中的内容到一个临时数据库文件，然后清空主数据库，并从副本中重新载入原始的数据库文件。这消除了空闲页，把表中的数据排列为连续的，另外会清理数据库文件结构。**/
- (SQLiteLanguage * (^)(NSString *value))VACUUM;
#pragma mark ============ 其他 ============
/**
 分号结束符,有时一条SQL结束需要加分号表示结尾因此你需要调用SEMICOLON。
 **/
-(SQLiteLanguage *)SEMICOLON;
@end
