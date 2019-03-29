//
//  StudentModel.h
//  SQLiteObject_C
//
//  Created by POSUN-MAC on 2018/9/14.
//  Copyright © 2018年 POSUN-MAC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GradeModel.h"
#import "PersonModel.h"
@interface StudentModel : PersonModel
@property(nonatomic,copy)NSString *stdID;//学号
@property(nonatomic,copy)NSString *cls;//班级
@property(nonatomic,retain)GradeModel *grade;




@end
