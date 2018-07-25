//
//  NSObject+Dictionary.m
//  ModelToDictionary
//
//  Created by POSUN-MAC on 2018/7/13.
//  Copyright © 2018年 POSUN-MAC. All rights reserved.
//

#import "NSObject+Dictionary.h"
#import <objc/runtime.h>




static NSString  *const type_char=@"char";
static NSString  *const type_int=@"int";
static NSString  *const type_short=@"short";
static NSString  *const type_long=@"long";
static NSString  *const type_unsigned_char=@"unsigned char";
static NSString  *const type_unsigned_int=@"unsigned int";
static NSString  *const type_unsigned_short=@"unsigned short";
static NSString  *const type_unsigned_long=@"unsigned long";
static NSString  *const type_unsigned_long_long=@"unsigned long long";
static NSString  *const type_float=@"float";
static NSString  *const type_double=@"double";
static NSString  *const type_BOOL=@"BOOL";
static NSString  *const type_void=@"void";
static NSString  *const type_char_X=@"char *";
static NSString  *const type_char_SEL=@"SEL";
static NSString  *const type_char_id=@"id";
static NSString  *const type_char_Class=@"Class";

static NSString *const type_NSArray=@"NSArray";
static NSString *const type_NSMutableArray=@"NSMutableArray";
static NSString *const type_NSObject=@"NSObject";
static NSString *const type_NSDictionary=@"NSDictionary";
static NSString *const type_NSMutalbleDictionary=@"NSMutalbleDictionary";
static NSString *const type_NSString=@"NSString";
static NSString *const type_NSMutalbleString=@"NSMutalbleString";
static NSString *const type_NSValue=@"NSValue";
static NSString *const type_NSNumber=@"NSNumber";

static NSString *const protocol_NSCopying=@"NSCopying";

static NSDictionary *typeDic=nil;
@implementation NSObject (Dictionary)

+(void)load{
    typeDic=@{@"c":type_char,
              @"i":type_int,
              @"s":type_short,
              @"q":type_long,
              @"C":type_unsigned_char,
              @"I":type_unsigned_int,
              @"S":type_unsigned_short,
              @"Q":type_unsigned_long,
              @"Q":type_unsigned_long_long,
              @"f":type_float,
              @"d":type_double,
              @"B":type_BOOL,
              @"v":type_void,
              @"*":type_char_X,
              @":":type_char_SEL,
              @"@":type_char_id,
              @"#":type_char_Class};
}
#pragma makr - Model转Dictionary
-(id)toDictionary{
    if ([NSStringFromClass(self.class) isEqualToString:type_NSObject]) {
        return nil;
    }
    else if([NSObject isDictionaryType:NSStringFromClass(self.class)]){
        return (NSDictionary*)self;
    }else if ([NSObject isArrayType:NSStringFromClass(self.class)]){
        __block NSMutableArray *mutableArray=[[NSMutableArray alloc] init];
        [(NSArray *)self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id object=[obj toDictionary];
            if (object) {
                [mutableArray addObject:object];
            }else{
            }
        }];
        return mutableArray;
    }
    else{
        NSArray *propertyInforArray=[self filterUnconversionProperty];
        NSMutableDictionary *mutableDictionary=[[NSMutableDictionary alloc] init];
        [propertyInforArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *propertyName=obj[PropertyName];
            NSString *propertyType=obj[PropertyType];
            id value=[self valueForKey:propertyName];
            if ([NSObject  isCNumberType:propertyType]||
                [NSObject  isCFNumberType:propertyType]||
                [NSObject isStringType:propertyType]||
                [NSObject isValueType:propertyType]) {
                [self setDic:mutableDictionary andValue:value andKey:propertyName];
            }
            else if ([NSObject isArrayType:propertyType]){
                [value enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self setDic:mutableDictionary andValue:[obj toDictionary] andKey:propertyName];
                }];
            }else if ([NSObject isDictionaryType:propertyType]){
                [self setDic:mutableDictionary andValue:[value toDictionary] andKey:propertyName];
            }
            else{
                [self setDic:mutableDictionary andValue:[value toDictionary] andKey:propertyName];
            }
        }];
        return mutableDictionary;
    }
}
-(void)setDic:(NSMutableDictionary *)dic andValue:(id)value andKey:(id)key{
    if (value) {
        NSString *resetKey=[self YYMTD_ResetKeyDictionary][key];
        if (resetKey) {
            [dic setObject:value forKey:resetKey];
        }else{
            [dic setObject:value forKey:key];
        }
    }
}
-(NSArray *)filterUnconversionProperty{
    return [self filterProperty:[self YYMTD_UnconversionProperty]];
}
-(NSArray *)filterProperty:(NSSet *)set{
    NSArray *propertyInforArray=[self propertyInforArray];
    NSMutableArray *array=[[NSMutableArray alloc] init];
    [propertyInforArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *propertyName=obj[PropertyName];
        if (![set containsObject:propertyName]) {
            [array addObject:obj];
        }
    }];
    return array;
}
#pragma mark - 获取成员变量名及类型
-(NSArray *)propertyInforArray{
    NSMutableArray *propertyArray=[[NSMutableArray alloc] init];
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([self class], &propsCount);
    for(int i = 0;i < propsCount; i++){
        objc_property_t  prop = props[i];
        NSString *propertyName = [self propertyName:prop];
        NSString *propertyType=[self propertyType:prop];
        [propertyArray addObject:@{
                                   PropertyName:propertyName,
                                   PropertyType:propertyType
                                   }];
    }
    free(props);
    return propertyArray;
}
-(NSString *)propertyName:(objc_property_t)property{
    return [NSString stringWithUTF8String:property_getName(property)];
}
-(NSString *)propertyType:(objc_property_t)property{
    NSString *property_data_type = nil;
    const char * property_attr = property_getAttributes(property);
    if (property_attr[1] == '@') {
        char * occurs1 =  strchr(property_attr, '@');
        char * occurs2 =  strrchr(occurs1, '"');
        char dest_str[40]= {0};
        strncpy(dest_str, occurs1, occurs2 - occurs1);
        char * realType = (char *)malloc(sizeof(char) * 50);
        int i = 0, j = 0, len = (int)strlen(dest_str);
        for (; i < len; i++) {
            if ((dest_str[i] >= 'a' && dest_str[i] <= 'z') ||
                (dest_str[i] >= 'A' && dest_str[i] <= 'Z')) {
                realType[j++] = dest_str[i];
            }
        }
        property_data_type = [NSString stringWithUTF8String:realType];
        free(realType);
    }else {
        char t = property_attr[1];
        property_data_type=typeDic[[NSString stringWithUTF8String:&t]];
    }
    return property_data_type;
}
+(BOOL)isCNumberType:(NSString *)type{
    if ([type isEqualToString:type_int]||
        [type isEqualToString:type_short]||
        [type isEqualToString:type_long]||
        [type isEqualToString:type_unsigned_int]||
        [type isEqualToString:type_unsigned_short]||
        [type isEqualToString:type_unsigned_long]||
        [type isEqualToString:type_unsigned_long_long]||
        [type isEqualToString:type_float]||
        [type isEqualToString:type_double]||
        [type isEqualToString:type_BOOL]) {
        return YES;
    }else{
        return NO;
    }
}
+(BOOL)isCFNumberType:(NSString *)type{
    if ([type isEqualToString:type_float]||
        [type isEqualToString:type_double]) {
        return YES;
    }else{
        return NO;
    }
}


+(BOOL)isArrayType:(NSString *)type{
    if ([type isEqualToString:type_NSArray]||
        [type isEqualToString:type_NSMutableArray]){
        return YES;
    }else{
        return NO;
    }
}

+(BOOL)isDictionaryType:(NSString *)type{
    if ([type isEqualToString:type_NSDictionary]||
        [type isEqualToString:type_NSMutalbleDictionary]){
        return YES;
    }else{
        return NO;
    }
}

+(BOOL)isStringType:(NSString *)type{
    if ([type isEqualToString:type_NSString]||
        [type isEqualToString:type_NSMutalbleString]){
        return YES;
    }else{
        return NO;
    }
}
+(BOOL)isValueType:(NSString *)type{
    if ([type isEqualToString:type_NSValue]||
        [type isEqualToString:type_NSNumber]){
        return YES;
    }else{
        return NO;
    }
}
-(NSSet*)YYMTD_UnconversionProperty{
    return nil;
}
-(NSSet*)YYMTD_ResetKeyDictionary{
    return nil;
}
@end
