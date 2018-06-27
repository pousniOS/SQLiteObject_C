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
#pragma mark - 1.打开数据库，通过SQLITEObjectC类的单例来创建数据库连接：
void openDB(){
    NSString *pathStr =[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/School.db"];
    if (![[SQLITEObjectC share] openWithFilePath:pathStr]) {
        NSLog(@"数据库打开失败");
    }
}
#pragma mark - 2.关闭数据库：
void closeDB(){
    if (![[SQLITEObjectC share] close]) {
        NSLog(@"数据库关闭失败");
    }
}
#pragma mark - 3.创建表，通过SQLiteLanguage来构建SQL然后通过SQLITEObjectC类的单例的-(BOOL)execSQL:(SQLiteLanguage *)sqll方法执行SQL语句：
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
#pragma mark - 4.删除表：
void dropTable(){
    SQLiteLanguage *sqll=[[SQLiteLanguage alloc] init];
    sqll.DROP.TABEL(@"Sutdent");
    if (![[SQLITEObjectC share] execSQL:sqll]) {
        NSLog(@"删除表失败");
    }
}
#pragma mark - 5.向表插入数据：
void insert(){
    SQLiteLanguage *sqll=[[SQLiteLanguage alloc] init];
    sqll.INSERT.INTO(@"Sutdent").COLUMNS(@"age",@"name",@"ID",nil).VALUES(@"24",@"'马悦'",@"120702010013",nil);
    if (![[SQLITEObjectC share] execSQL:sqll]) {
        NSLog(@"数据插入失败");
    }
}
#pragma mark - 6.数据查询，查询到的结果通过SQLITEObjectC类的单例execSQLResultArray获取：
void SELECT(){
    SQLiteLanguage *sqll=[[SQLiteLanguage alloc] init];
    sqll.SELECT(SQL_DISTINCT,@"*",nil).FROM(@"Sutdent").WHERE(@"name='马悦'");
    if (![[SQLITEObjectC share] execSQL:sqll]) {
        NSLog(@"数据查询失败");
    }else{
        NSLog(@"%@",[SQLITEObjectC share].execSQLResultArray);
    }
}
#pragma mark - 7.修改表数据：
void UPDATE(){
    SQLiteLanguage *sqll=[[SQLiteLanguage alloc] init];
    sqll.UPDATE(@"Sutdent").SET(@"name='小明'",@"age=90",nil).WHERE(@"ID='120702010019'");
    if (![[SQLITEObjectC share] execSQL:sqll]) {
        NSLog(@"数据更新失败");
    }
}
#pragma mark - 8.删除表数据：
void DELETE(){
    SQLiteLanguage *sqll=[[SQLiteLanguage alloc] init];
    sqll.DELETE.FROM(@"Sutdent").WHERE(@"ID='120702010019'");
    if (![[SQLITEObjectC share] execSQL:sqll]) {
        NSLog(@"数据删除失败");
    }
}
#pragma mark - 9.排序：
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
        openDB();
//        createTable();//创建表
//        dropTable();//删除表
//        insert();//插入数据
//        SELECT();//数据查询
        ORDERBY();
        closeDB();
        
        
        
    }
    return 0;
}

