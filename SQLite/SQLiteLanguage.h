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
/**快速创建SQLiteLanguage对象**/
#define SQLlang [[SQLiteLanguage alloc] init]
@interface SQLiteLanguage : NSObject
/**SQL语句**/
@property(nonatomic,copy,readonly)NSString *sql;

/**清楚构造的sql语句**/
-(void)clear;

#pragma mark ============ 创建表 ============
-(SQLiteLanguage *)CREATE;
-(SQLiteLanguage *)FOREIGN;
-(SQLiteLanguage * (^)(NSString *tableName))REFERENCES;
-(SQLiteLanguage *)PRIMARY;
/**
 该方法的用处
 1.可以用来表示设置主键外键时的key。
 **/
-(SQLiteLanguage * (^)(NSString *fristName,...))KEY;//结束记得加nil。
- (SQLiteLanguage * (^)(NSString *value))NOT;
-(SQLiteLanguage * (^)(NSString *name))TABEL;
- (SQLiteLanguage * (^)(id fristColumn,...))COLUMN;//结束记得加nil。
-(SQLiteLanguage * (^)(NSString *name))columnName;
-(SQLiteLanguage * (^)(NSString *name))CONSTRAINT;

#pragma mark - ============ 表字段数据类型 ============
-(SQLiteLanguage *)INTEGER;//值是一个带符号的整数，根据值的大小存储在 1、2、3、4、6 或 8 字节中。
-(SQLiteLanguage *)REAL;//值是一个浮点值，存储为 8 字节的 IEEE 浮点数字。
-(SQLiteLanguage *)TEXT;//值是一个文本字符串，使用数据库编码（UTF-8、UTF-16BE 或 UTF-16LE）存储。
-(SQLiteLanguage *)BLOB;//值是一个 blob 数据，完全根据它的输入存储。

#pragma mark ============ 删除表 ============
-(SQLiteLanguage *)DROP;
#pragma mark ============ 表数据插入 ============
-(SQLiteLanguage *)INSERT;
- (SQLiteLanguage * (^)(NSString *tableName))INTO;
- (SQLiteLanguage * (^)(NSString *fristValue,...))VALUES;//结束记得加nil。

#pragma mark ============ SELECT查询 ============
- (SQLiteLanguage * (^)(NSString *tableName))FROM;
- (SQLiteLanguage * (^)(NSString *fristName,...))SELECT;//结束记得加nil。
- (SQLiteLanguage * (^)(NSString *name))WHERE;
- (SQLiteLanguage * (^)(NSString *rowNumber))OFFSET;
- (SQLiteLanguage * (^)(NSString *rows))LIMIT;

#pragma mark ============ 运算符 ============
- (SQLiteLanguage * (^)(NSString *value))AND;
- (SQLiteLanguage * (^)(NSString *value))OR;
- (SQLiteLanguage * (^)(SQLiteLanguage *sqll))EXISTS;
- (SQLiteLanguage * (^)(NSString *value))BETWEEN;
- (SQLiteLanguage * (^)(NSString *value))LIKE;
- (SQLiteLanguage * (^)(NSString *value))IS;
- (SQLiteLanguage * (^)(NSString *value))UNIQUE;
- (SQLiteLanguage * (^)(NSString *value))GLOB;
- (SQLiteLanguage * (^)(NSString *value,...))IN;//结束记得加nil。

#pragma mark ============ UPDATE更新表数据 ============
-(SQLiteLanguage * (^)(NSString *tableName))UPDATE;
-(SQLiteLanguage * (^)(NSString *keyAndValue,...))SET;//结束记得加nil。

#pragma mark ============ DELETE删除表数据 ============
-(SQLiteLanguage *)DELETE;
#pragma mark ============ ORDER BY排序 ============
-(SQLiteLanguage * (^)(NSString *name))BY;
-(SQLiteLanguage *)ORDER;
-(SQLiteLanguage *)DESC;
-(SQLiteLanguage *)ASC;

#pragma mark ============ GROUP BY分组 ============
-(SQLiteLanguage *)GROUP;

#pragma mark ============ HAVING ============
/**
 HAVING 子句允许指定条件来过滤将出现在最终结果中的分组结果。
 WHERE 子句在所选列上设置条件，而 HAVING 子句则在由 GROUP BY 子句创建的分组上设置条件。
 **/
- (SQLiteLanguage * (^)(NSString *value))HAVING;

#pragma mark ============ DISTINCT排除重复 ============
- (SQLiteLanguage * (^)(NSString *fristName,...))SELECT_DISTINCT;

#pragma mark ============ ALTER修改表 ============
-(SQLiteLanguage * (^)(NSString *value))ADD;
-(SQLiteLanguage *)ALTER;
-(SQLiteLanguage * (^)(SQLiteLanguage *value))ALTER_COLUMN;
@end
