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
    sqll.CREATE.TABEL(@"Sutdent").COLUMNS(
                                         SQLlang.columnName(@"age").INTEGER,//列名叫age,INTEGER类型的数据,不许为空
                                         SQLlang.columnName(@"name").TEXT,
                                         SQLlang.columnName(@"ID").TEXT.NOT(@"NULL").PRIMARY.KEY(nil),//列名叫ID,TEXT类型的数据同时设置为主键,不许为空
                                         nil
                                         );
    if (![[SQLITEObjectC share] execSQL:sqll]) {
        NSLog(@"创建表失败");
    }
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
    sqll.INSERT.INTO(@"Sutdent").COLUMNS(@"age",@"name",@"ID",nil).VALUES(@"24",@"'马悦'",@"120702010013",nil);
    if (![[SQLITEObjectC share] execSQL:sqll]) {
        NSLog(@"数据插入失败");
    }
}
void SELECT(){
    SQLiteLanguage *sqll=[[SQLiteLanguage alloc] init];
    sqll.SELECT(SQL_DISTINCT,@"*",nil).FROM(@"Sutdent").WHERE(@"name='马悦'");
    if (![[SQLITEObjectC share] execSQL:sqll]) {
        NSLog(@"数据查询失败");
    }else{
        NSLog(@"%@",[SQLITEObjectC share].execSQLResultArray);
    }
}
void UPDATE(){
    SQLiteLanguage *sqll=[[SQLiteLanguage alloc] init];
    sqll.UPDATE(@"Sutdent").SET(@"name='小明'",@"age=90",nil).WHERE(@"ID='120702010019'");
    if (![[SQLITEObjectC share] execSQL:sqll]) {
        NSLog(@"数据更新失败");
    }
}
void DELETE(){
    SQLiteLanguage *sqll=[[SQLiteLanguage alloc] init];
    sqll.DELETE.FROM(@"Sutdent").WHERE(@"ID='120702010019'");
    if (![[SQLITEObjectC share] execSQL:sqll]) {
        NSLog(@"数据删除失败");
    }
}
void ORDERBY(){
    SQLiteLanguage *sqll=[[SQLiteLanguage alloc] init];
    sqll.SELECT(SQL_DISTINCT,@"*",nil).FROM(@"Sutdent").ORDER.BY(@"ID").DESC;
    if (![[SQLITEObjectC share] execSQL:sqll]) {
        NSLog(@"排序失败");
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
        ORDERBY();
        if (![[SQLITEObjectC share] close]) {
            NSLog(@"数据库关闭失败");
        }
        
        
        
    }
    return 0;
}

