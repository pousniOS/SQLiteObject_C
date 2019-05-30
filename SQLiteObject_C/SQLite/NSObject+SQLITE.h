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
    该类别意在实现通过Model类快速创建数SQLITE以及一系列相关联的TABLE，然后通过操作Model类的一系列方法，
 快速便捷的对Model对象的数据在SQLITE里进行、查、增、删、改。
 **/
@interface NSObject (SQLITE)
/**
方法说明：在需要创建表的Model类里可以重写该方法来设置db文件路径,否则默认为沙盒路径下的SQLIT_DATABASEE.db
 **/
+(NSString *)sqlite_dbPath;
/**
 方法说明：查看数据库里的所有表的定义。
 **/
+(NSArray *)sqlite_dbSeeTables;
/**
 方法说明：判断表是否存在。
 **/
+(BOOL)sqlite_tableIsExist;
/**
 方法说明：创建表。
 参数说明：flag是否把自定义类类型的属性的也同时创建出TABLE。
 **/
+(BOOL)sqlite_tableCreateWithIsAssociation:(BOOL)flag;
/**
 方法说明：将数据插入到表里。
 参数说明：flag是否把自定义类类型的属性的数据也同时插入到对应的TABLE。

 **/
-(BOOL)sqlite_tableInsertWithIsAssociation:(BOOL)flag;
/**
 方法说明：查询表里的数据；
 参数说明：condition 查询条件、flag是否把自定义类类型的属性值也同时查询出来；
 备注：建议flag传入NO需要时在调用”-(BOOL)sqlite_tableSelectWithPropertyName:(NSString *)propertyName andCondition:(SQLiteLanguage *)condition IsAssociation:(BOOL)flag“方法获取。
 **/
+(NSArray *)sqlite_tableSelectWithCondition:(SQLiteLanguage *)condition IsAssociation:(BOOL)flag;
/**
 方法说明：查询表里的数据；
 参数说明：condition 查询条件、flag是否把自定义类类型的属性值也同时查询出来；
    备注：建议flag传入NO需要时在继续”-(BOOL)sqlite_tableSelectWithPropertyName:(NSString *)propertyName andCondition:(SQLiteLanguage *)condition IsAssociation:(BOOL)flag“调用方法获取
 **/
-(BOOL)sqlite_tableSelectWithPropertyName:(NSString *)propertyName andCondition:(SQLiteLanguage *)condition IsAssociation:(BOOL)flag;
/**
 方法说明：删除表里的数据；
 参数说明：condition 删除条件、flag是否把自定义类类型的属性值也同时删除；
 **/
+(BOOL)sqlite_tableDeleteWithCondition:(SQLiteLanguage *)condition IsAssociation:(BOOL)flag;
/**
 方法说明：删除表里的数据；
 参数说明：condition 删除条件、flag是否把自定义类类型的属性值也同时删除；
 **/
-(BOOL)sqlite_tableDeleteWithCondition:(SQLiteLanguage *)condition IsAssociation:(BOOL)flag;
/**
 方法说明：更新表里的数据；
 参数说明：flag是否把自定义类类型的属性值也同时更新；
 **/
-(BOOL)sqlite_tableUpdateWithIsAssociation:(BOOL)flag;
/**
 Model类调用该方法获取创建的表
 **/
+(NSArray<NSString *>*)sqlite_getTablesWithIsAssociation:(BOOL)flag;
/**删除所有的关联的表**/
+(BOOL)sqlite_tableDropIsAssociation:(BOOL)flag;
/**可以通过重新该方法为表重命名默认是model类的名称**/
+(NSString *)sqlite_tableName;
/**
 设置创建表时不需要的字段,注意该类别的tableCreate方法只支持包含NSString，
 基础类型，NSValue，NSArray的Model类转换生成Sqlist数据表。如果包含其它类型
 的属性需重写该方法过滤掉
 **/
+(NSSet*)sqlite_tableUnconversionProperty;
/**
 如果Model类里有数组类型的属性那么需要重写该方法知道数组里装的是什么类型的数据，
 否则创建的表将没有这属性的字段
 **/
+(NSDictionary*)sqlite_tablePropertyNameAndElementTypeDictionary;
/**
 在Model类重写该方法设置主键字段填充的值（主键的默认值为uuid）
 **/
+(NSString*)sqlite_tablePrimaryKeyValueSetProperty;
@end
