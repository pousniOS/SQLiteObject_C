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
    if ([key isEqualToString:@"grade"]&&(![NSDictionary class]||![NSArray class])) {
        _grade=[[GradeModel alloc] init];
        [_grade setValuesForKeysWithDictionary:value];
        
    }else{
        [super setValue:value forKey:key];
    }
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
@end
