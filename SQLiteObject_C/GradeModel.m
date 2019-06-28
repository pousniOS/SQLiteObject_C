//
//  GradeModel.m
//  SQLiteObject_C
//
//  Created by POSUN-MAC on 2018/9/14.
//  Copyright © 2018年 POSUN-MAC. All rights reserved.
//

#import "GradeModel.h"

@implementation GradeModel
-(void)setValue:(id)value forKey:(NSString *)key{
    [super setValue:value forKey:key];
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
}
+(NSString*)sqlite_tablePrimaryKeyValueSetProperty{
    return @"ID";
}
@end
