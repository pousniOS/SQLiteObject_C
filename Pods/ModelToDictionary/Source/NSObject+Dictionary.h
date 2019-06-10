//
//  NSObject+Dictionary.h
//  ModelToDictionary
//
//  Created by POSUN-MAC on 2018/7/13.
//  Copyright © 2018年 POSUN-MAC. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString  *const PropertyName=@"PropertyName";
static NSString  *const PropertyType=@"PropertyType";

@interface NSObject (Dictionary)
/**对象转Dic**/
-(id)toDictionary;
/**获取对象的属性名以及属性类型**/
-(NSArray *)propertyInforArray;
/**
 通过在调用toDictionary方法对象的类里重写该方法，返回一个包含属性名称的NSSet对象，来屏蔽掉不需要转换成NSDictionary对象的属性。
 **/
-(NSSet *)YYMTD_UnconversionProperty;
/**
 通过在调用toDictionary方法对象的类里重写该方法，返回一个包含属性名称和重置成的Key的键值对的NSDictionary象，来重置生成NSDictionary对象的Key。
 **/
-(NSDictionary*)YYMTD_ResetKeyDictionary;

-(NSArray *)filterProperty:(NSSet *)set;
+(BOOL)isCFNumberType:(NSString *)type;
+(BOOL)isCNumberType:(NSString *)type;
@end
