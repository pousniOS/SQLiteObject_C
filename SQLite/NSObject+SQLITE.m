//
//  NSObject+SQLITE.m
//  SQLiteObject_C
//
//  Created by POSUN-MAC on 2018/7/23.
//  Copyright © 2018年 POSUN-MAC. All rights reserved.
//

#import "NSObject+SQLITE.h"
@implementation NSObject (SQLITE)

+(NSString *)dbPath{
    return nil;
}
+(BOOL)isExistTable{
    [self dbOpen];
    SHARESQLITEObjectC.SQLL.SELECT(@"count(*)",nil).FROM(@"sqlite_master").WHERE(@"type='table'");
    if (SHARESQLITEObjectC.execSQLL) {
        NSDictionary *countDic = [SHARESQLITEObjectC.execSQLResultArray firstObject];
        NSString *countStr=[countDic objectForKey:@"count(*)"];
        return [countStr integerValue];
    }else{
        return NO;
    }
}
+(BOOL)createTable{
    
    
    return YES;
}
+(BOOL)dropTable{
    return YES;
}
+(BOOL)dbOpen{
    if (SHARESQLITEObjectC.isOpen) {
        if ([SHARESQLITEObjectC.dbPath isEqualToString:self.dbPath]) {
            return YES;
        }else{
            if ([SHARESQLITEObjectC close]) {
                return [SHARESQLITEObjectC openWithFilePath:self.dbPath];
            }else{
                return NO;
            }
        }
    }else{
        return [SHARESQLITEObjectC openWithFilePath:self.dbPath];
    }
}
@end
