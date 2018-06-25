//
//  SQLITEObjectC.h
//  SQLiteLanguageStructure
//
//  Created by POSUN-MAC on 2018/6/25.
//  Copyright © 2018年 POSUN-MAC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "SQLiteLanguage.h"
@interface SQLITEObjectC : NSObject
@property(nonatomic,assign,readonly)sqlite3 *DB;
/**执行SQL后返回的结果**/
@property(nonatomic,retain,readonly)NSMutableArray<NSDictionary*> *execSQLResultArray;
/**关闭数据库,数据库使用完记得调用该方法断开数据库连接**/
-(BOOL)close;
/**打开或创建数据库**/
-(BOOL)openWithFilePath:(NSString *)filePath;
/**执行SQL语句**/
-(BOOL)execSQL:(SQLiteLanguage *)sqll;
+(instancetype)share;
@end
