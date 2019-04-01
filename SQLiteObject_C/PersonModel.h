//
//  PersonModel.h
//  SQLiteObject_C
//
//  Created by POSUN-MAC on 2018/9/14.
//  Copyright © 2018年 POSUN-MAC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersonModel : NSObject
@property(nonatomic,copy)NSString *name;//名字
@property(nonatomic,copy)NSString *ID;//身份证ID
@property(nonatomic,assign)NSInteger age;//年龄
@property(nonatomic,assign)BOOL sex;//性别
@property(nonatomic,copy)NSString *sexStr;//性别
//@property(nonatomic,retain)NSMutableArray<PersonModel*> *family;

@end

