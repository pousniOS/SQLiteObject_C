//
//  NSObject+SQLITE.h
//  SQLiteObject_C
//
//  Created by POSUN-MAC on 2018/7/23.
//  Copyright © 2018年 POSUN-MAC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLITEObjectC.h"
#import "NSString+SQLITE.h"
/**
 改类别的目的是实现一些可以通过Model文件快速创建数据库一系列相关的表的方法
 **/
@interface NSObject (SQLITE)
/**
 需要在创建表的Model类里重写该方法来设置db文件路径,否则默认为沙盒路径下的SQLIT_DATABASEE.db
 **/
+(NSString *)dbPath;
/**判断表是否存在**/
+(BOOL)tableIsExist;
/**创建表**/
+(BOOL)tableCreate;
/**将数据插入表中**/
-(BOOL)table_Insert;
/**获取model类创建的表**/
+(NSArray<NSString *>*)getTables;
/**删除表**/
+(BOOL)tableDrop;
/**删除所有的关联的表**/
+(BOOL)tableDropAll;
/**可以通过重新该方法为表重命名默认是model类的名称**/
+(NSString *)tableName;
/**
 设置创建表时不需要的字段,注意该类别的tableCreate方法只支持包含NSString，
 基础类型，NSValue，NSArray的Model类转换生成Sqlist数据表。如果包含其它类型
 的属性需从写该方法过滤掉
 **/
+(NSSet*)table_UnconversionProperty;
/**
 如果Model类里有数组类型的属性那么需要重写该方法知道数组里装的是什么类型的数据，
 否则创建的表将没有这属性的字段
 **/
+(NSDictionary*)table_ArrayPropertyNameAndElementTypeDictionary;
/**
 在Model类重写该方法设置主键
 **/
+(NSString*)table_PrimaryKey;
/**
 在Model类重写该方法设置外键
 **/
+(NSString*)table_ForeignKey;
/**
 重写改方法设置表的外键来源的的表名称
 **/
+(NSString*)table_ForeignKeyFromKey;
/**
 重写改方法设置表的外键来源的表
 **/
+(NSString*)table_ForeignKeyFromTable;
@end
