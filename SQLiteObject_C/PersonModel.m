//
//  PersonModel.m
//  SQLiteObject_C
//
//  Created by POSUN-MAC on 2018/9/14.
//  Copyright © 2018年 POSUN-MAC. All rights reserved.
//

#import "PersonModel.h"

@implementation PersonModel

-(void)setValue:(id)value forKey:(NSString *)key{
    if ([key isEqualToString:@"family"]&&(![NSDictionary class]||![NSArray class])) {
        _family=[[NSMutableArray alloc] init];
        [value enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PersonModel *model=[[PersonModel alloc] init];
            [model setValuesForKeysWithDictionary:obj];
            [self->_family addObject:model];
        }];
    }else{
        [super setValue:value forKey:key];
    }
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}


-(NSString *)sexStr{
    if (_sex) {
        return @"男";
    }else{
        return @"女";
    }
}
+(NSDictionary*)sqlite_tablePropertyNameAndElementTypeDictionary{
    return @{@"family":@"PersonModel"};
}
@end
