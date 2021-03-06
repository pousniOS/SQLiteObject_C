//
//  SQLITEObjectC.m
//  SQLiteLanguageStructure
//
//  Created by POSUN-MAC on 2018/6/25.
//  Copyright © 2018年 POSUN-MAC. All rights reserved.
//
#import <sqlite3.h>
#import "SQLITEObjectC.h"
/**SQL执行结果回调**/
int callback(void *para,int ncolumn,char ** columnvalue,char *columnname[]);
@interface SQLITEObjectC()
{
    sqlite3 *_db;
}
@end
@implementation SQLITEObjectC
+(instancetype)share{
    static SQLITEObjectC *sQLITEObjectC=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sQLITEObjectC=[[super allocWithZone:NULL] init];
    });
    return sQLITEObjectC;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    return [SQLITEObjectC share];
}
-(id)copyWithZone:(NSZone *)zone{
    return [SQLITEObjectC share];
}
-(id)mutableCopyWithZone:(NSZone *)zone{
    return [SQLITEObjectC share];
}
-(BOOL)connectionWithFilePath:(NSString *)filePath{
    if ([filePath isEqualToString:_dbPath]) {
        return [self open];
    }else{
        if ([self close]) {
            _dbPath = filePath;
            return [self open];
        }else{
            return NO;
        }
    }
}
-(BOOL)open{
    if (_isOpen) {
        return YES;
    }else{
        if (sqlite3_open([_dbPath UTF8String], &(self->_db))==SQLITE_OK) {
            self->_isOpen=YES;
            return YES;
        }else{
            [self close];
            return NO;
        }
    }
}

-(BOOL)close{
    if (_isOpen==NO) {
        return YES;
    }
    if (sqlite3_close(_db)==SQLITE_OK) {
        _isOpen=NO;
        return YES;
    }else{
        _isOpen=YES;
        return NO;
    }
}
-(BOOL)execByTransactionWithSQLL:(SQLiteLanguage *)SQLL result:(void(^)(NSString *errorInfor,NSArray<NSDictionary *> *resultArray))result{
    SQLiteLanguage *sqll =[SQLlang.BEGIN.TRANSACTION SEMICOLON];
    sqll.APPEND(SQLL.SEMICOLON);
    [sqll.COMMIT SEMICOLON];
    return [self execSQLL:sqll result:result];
}
-(BOOL)execSQLL:(SQLiteLanguage *)SQLL result:(void(^)(NSString *errorInfor,NSArray<NSDictionary *> *resultArray))result{
    char *errmsg=NULL;
    NSArray *execSQLResultArray=[[NSMutableArray alloc] init];
    if (sqlite3_exec(_db, [SQLL.sql UTF8String], &callback, (__bridge void *)execSQLResultArray, &errmsg)==SQLITE_OK) {
        result(nil,execSQLResultArray);
        return YES;
    }else{
        if (errmsg==NULL) {
            result(nil,execSQLResultArray);
        }else{
            NSLog(@"%@",[NSString stringWithUTF8String:errmsg]);
            result([NSString stringWithUTF8String:errmsg],execSQLResultArray);
        }
        return NO;
    }
}
@end
/**SQL执行结果回调**/
int callback(void *para,int ncolumn,char ** columnvalue,char *columnname[]){
    int i;
    NSMutableArray *execSQLResultArray=(__bridge NSMutableArray *)para;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    for(i = 0;i < ncolumn; i++){
        if (columnname[i]!=NULL&&columnvalue[i]!=NULL) {
            [dic setObject:[NSString stringWithUTF8String:columnvalue[i]] forKey:[NSString stringWithUTF8String:columnname[i]]];
        }
    }
    [execSQLResultArray addObject:dic];
    return 0;
}

