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



#define SHARESQLITEObjectC [SQLITEObjectC share]

@interface SQLITEObjectC : NSObject
@property(nonatomic,copy,readonly)NSString *dbPath;

@property(nonatomic,assign,readonly)BOOL isOpen;
/**关闭数据库,数据库使用完记得调用该方法断开数据库连接**/
-(BOOL)close;
/**打开或创建数据库**/
-(BOOL)openWithFilePath:(NSString *)filePath;
/**执行SQL语句并返回结果**/
-(BOOL)execSQLL:(SQLiteLanguage *)SQLL result:(void(^)(NSString *errorInfor,NSArray<NSDictionary *> *resultArray))result;

/**以事物的方式执行SQL语句并返回结果**/
-(BOOL)execByTRANSACTIONWithSQLL:(SQLiteLanguage *)SQLL result:(void(^)(NSString *errorInfor,NSArray<NSDictionary *> *resultArray))result;

+(instancetype)share;
@end
