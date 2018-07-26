//
//  SQLITEObjectC.m
//  SQLiteLanguageStructure
//
//  Created by POSUN-MAC on 2018/6/25.
//  Copyright © 2018年 POSUN-MAC. All rights reserved.
//

#import "SQLITEObjectC.h"
/**SQL执行结果回调**/
static NSMutableArray *ExecSQLResultArray;
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
        return YES;
    }else{
        return NO;
    }
}
-(void)clear{
    ExecSQLResultArray=nil;
}
-(BOOL)execSQLL:(SQLiteLanguage *)SQLL{
    char *errmsg=NULL;
    ExecSQLResultArray=[[NSMutableArray alloc] init];
    BOOL result=NO;
    if (sqlite3_exec(_db, [SQLL.sql UTF8String], &callback, NULL, &errmsg)==SQLITE_OK) {
        result=YES;
    }else{
//        NSLog(@"SQLITEObjectC_Error:[-(BOOL)execSQL:(NSString *)sql]%@",[NSString stringWithUTF8String:errmsg]);
    }
    return result;
}
-(NSMutableArray<NSDictionary *> *)execSQLResultArray{
    return ExecSQLResultArray;
}
@end
/**SQL执行结果回调**/
int callback(void *para,int ncolumn,char ** columnvalue,char *columnname[]){
    int i;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    for(i = 0;i < ncolumn; i++)
    {
        if (columnname[i]!=NULL&&columnvalue[i]!=NULL) {
            [dic setObject:[NSString stringWithUTF8String:columnvalue[i]] forKey:[NSString stringWithUTF8String:columnname[i]]];
        }
    }
    [ExecSQLResultArray addObject:dic];
    return 0;
}
