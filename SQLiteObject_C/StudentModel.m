//
//  StudentModel.m
//  SQLiteObject_C
//
//  Created by POSUN-MAC on 2018/9/14.
//  Copyright © 2018年 POSUN-MAC. All rights reserved.
//

#import "StudentModel.h"

@implementation StudentModel
-(void)setValue:(id)value forKey:(NSString *)key{
    if ([key isEqualToString:@"data"]) {
        _transcript=[[NSMutableArray alloc] init];
        [value enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([value isKindOfClass:[NSDictionary class]]) {
                GradeModel *model=[[GradeModel alloc] init];
                [model setValuesForKeysWithDictionary:value];
                [self->_transcript addObject:model];
            }else{
                [self->_transcript addObject:obj];
            }
        }];
    }
    else{
        [super setValue:value forKey:key];
    }
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
-(NSString *)sqlite_tableName{
    return @"test";
}
+(NSDictionary*)sqlite_tablePropertyNameAndElementTypeDictionary{
    return @{@"transcript":@"GradeModel"};
}
+(NSString*)sqlite_tablePrimaryKeyValueSetProperty{
    return @"stdID";
}
@end
