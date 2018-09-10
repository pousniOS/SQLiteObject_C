//
//  SQLITEObjectC.m
//  SQLiteLanguageStructure
//
//  Created by POSUN-MAC on 2018/6/25.
//  Copyright © 2018年 POSUN-MAC. All rights reserved.
//

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
        sQLITEObjectC=[[SQLITEObjectC alloc] init];
    });
    return sQLITEObjectC;
}
-(BOOL)openWithFilePath:(NSString *)filePath{
    if (sqlite3_open([filePath UTF8String], &_db)==SQLITE_OK) {
        _isOpen=YES;
        _dbPath=filePath;
        return YES;
    }else{
        [self close];
        return NO;
    }
}
-(BOOL)close{
    if (sqlite3_close(_db)==SQLITE_OK) {
        _isOpen=NO;
        return YES;
    }else{
        _isOpen=YES;
        return NO;
    }
}

-(BOOL)execByTRANSACTIONWithSQLL:(SQLiteLanguage *)SQLL result:(void(^)(NSString *errorInfor,NSArray<NSDictionary *> *resultArray))result{
    SQLiteLanguage *sqll =[SQLlang.BEGIN.TRANSACTION SEMICOLON];
    sqll.APPEND(SQLL);
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
    for(i = 0;i < ncolumn; i++)
    {
        if (columnname[i]!=NULL&&columnvalue[i]!=NULL) {
            [dic setObject:[NSString stringWithUTF8String:columnvalue[i]] forKey:[NSString stringWithUTF8String:columnname[i]]];
        }
    }
    [execSQLResultArray addObject:dic];
    return 0;
}

