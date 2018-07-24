//
//  NSObject+SQLITE.h
//  SQLiteObject_C
//
//  Created by POSUN-MAC on 2018/7/23.
//  Copyright © 2018年 POSUN-MAC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLITEObjectC.h"
/**改类别的目的是实现一些可以通过Model文件快速创建数据库表的方法**/
@interface NSObject (SQLITE)
/**
 需要在创建表的Model类里重写该方法来设置db文件路径
 **/
+(NSString *)dbPath;
/**
 判断表是否存在
 **/
+(BOOL)isExistTable;
/**
 创建表
 **/
+(BOOL)createTable;
/**
 删除表
 **/
+(BOOL)dropTable;

//-(BOOL)insertToTable;
//-(BOOL)deleteFromTable;

@end
