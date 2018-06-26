//
//  main.m
//  SQLiteObject_C
//
//  Created by POSUN-MAC on 2018/6/25.
//  Copyright © 2018年 POSUN-MAC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLITEObjectC.h"
#pragma mark - ====== 测试函数 ======
void createTable(){
    SQLiteLanguage *sqll=[[SQLiteLanguage alloc] init];
    sqll.CREATE.TABEL(@"Sutdent").COLUMN(
                                         SQLlang.columnName(@"age").INTEGER,//列名叫age,INTEGER类型的数据,不许为空
                                         SQLlang.columnName(@"name").TEXT,
                                         SQLlang.columnName(@"ID").TEXT.NOT(@"NULL").PRIMARY.KEY(nil),//列名叫ID,TEXT类型的数据同时设置为主键,不许为空
                                         nil
                                         );
    if (![[SQLITEObjectC share] execSQL:sqll]) {
        NSLog(@"创建表失败");
    }
    
   sqll=[[SQLiteLanguage alloc] init];
    
    
    
    
}
void dropTable(){
    SQLiteLanguage *sqll=[[SQLiteLanguage alloc] init];
    sqll.DROP.TABEL(@"Sutdent");
    if (![[SQLITEObjectC share] execSQL:sqll]) {
        NSLog(@"删除表失败");
    }
}
void insert(){
    SQLiteLanguage *sqll=[[SQLiteLanguage alloc] init];
    sqll.INSERT.INTO(@"Sutdent").COLUMN(@"age",@"name",@"ID",nil).VALUES(@"24",@"'马悦'",@"120702010013",nil);
    if (![[SQLITEObjectC share] execSQL:sqll]) {
        NSLog(@"数据插入失败");
    }
}
void SELECT(){
    SQLiteLanguage *sqll=[[SQLiteLanguage alloc] init];
    sqll.SELECT(@"*",nil).FROM(@"Sutdent").WHERE(@"name='马悦'");
    if (![[SQLITEObjectC share] execSQL:sqll]) {
        NSLog(@"数据查询失败");
    }else{
        NSLog(@"%@",[SQLITEObjectC share].execSQLResultArray);
    }
}
#pragma mark - ====== main函数 ======

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *pathStr =[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/School.db"];
        if (![[SQLITEObjectC share] openWithFilePath:pathStr]) {
            NSLog(@"数据库打开失败");
        }
//        createTable();//创建表
//        dropTable();//删除表
//        insert();//插入数据
//        SELECT();//数据查询
        SQLiteLanguage *sqll=[[SQLiteLanguage alloc] init];
        sqll.UPDATE(@"Sutdent").SET(@"name='小明'",@"age=90",nil).WHERE(@"ID='120702010019'");
        
//        sqll.INSERT.INTO(@"Sutdent").COLUMN(@"ID",@"age",@"name",@"sex").VALUES(@"'120702010019'",@"26",@"'朱小明'",@"'男'");
        [[SQLITEObjectC share] execSQL:sqll];
        [sqll clear];
        
        sqll.SELECT(@"*",nil).FROM(@"Sutdent");
        [[SQLITEObjectC share] execSQL:sqll];
        NSLog(@"%@",[SQLITEObjectC share].execSQLResultArray);
        

        
        
        
        if (![[SQLITEObjectC share] close]) {
            NSLog(@"数据库关闭失败");
        }
        
        
        
        
    }
    return 0;
}

