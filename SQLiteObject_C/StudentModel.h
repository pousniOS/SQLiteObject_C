//
//  StudentModel.h
//  SQLiteObject_C
//
//  Created by POSUN-MAC on 2018/9/14.
//  Copyright © 2018年 POSUN-MAC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GradeModel.h"
@interface StudentModel : NSObject
@property(nonatomic,copy)NSString *stdID;//学号
@property(nonatomic,copy)NSString *cls;//班级
@property(nonatomic,copy)NSString *name;
@property(nonatomic,assign)BOOL sex;
@property(nonatomic,retain)NSMutableArray<GradeModel *> *transcript;
@end
