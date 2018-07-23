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
    SHARESQLITEObjectC.SQLL.CREATE.TABEL(@"Sutdent").COLUMNS(
                                         SQLlang.columnName(@"age").INTEGER,//列名叫age,INTEGER类型的数据,不许为空
                                         SQLlang.columnName(@"name").TEXT,
                                         SQLlang.columnName(@"ID").TEXT.NOT(@"NULL").PRIMARY.KEY(nil),//列名叫ID,TEXT类型的数据同时设置为主键,不许为空
                                         nil
                                         );
    if (![[SQLITEObjectC share] execSQLL]) {
        NSLog(@"创建表失败");
    }
}
#pragma mark - 4.删除表：
void dropTable(){
    SHARESQLITEObjectC.SQLL.DROP.TABEL(@"Sutdent");
    if (![[SQLITEObjectC share] execSQLL]) {
        NSLog(@"删除表失败");
    }
}
#pragma mark - 5.向表插入数据：
void insert(){
    SHARESQLITEObjectC.SQLL.INSERT.INTO(@"Sutdent").COLUMNS(@"age",@"name",@"ID",nil).VALUES(@"24",@"'马悦'",@"120702010013",nil);
    if (![[SQLITEObjectC share] execSQLL]) {
        NSLog(@"数据插入失败");
    }
}
#pragma mark - 6.数据查询，查询到的结果通过SQLITEObjectC类的单例execSQLResultArray获取：
void SELECT(){
    SHARESQLITEObjectC.SQLL.SELECT(SQL_DISTINCT,@"*",nil).FROM(@"Sutdent").WHERE(@"name='马悦'");
    if (![[SQLITEObjectC share] execSQLL]) {
        NSLog(@"数据查询失败");
    }else{
        NSLog(@"%@",[SQLITEObjectC share].execSQLResultArray);
    }
}
#pragma mark - 7.修改表数据：
void UPDATE(){
    SHARESQLITEObjectC.SQLL.UPDATE(@"Sutdent").SET(@"name='小明'",@"age=90",nil).WHERE(@"ID='120702010019'");
    if (![[SQLITEObjectC share] execSQLL]) {
        NSLog(@"数据更新失败");
    }
}
#pragma mark - 8.删除表数据：
void DELETE(){
    SHARESQLITEObjectC.SQLL.DELETE.FROM(@"Sutdent").WHERE(@"ID='120702010019'");
    if (![[SQLITEObjectC share] execSQLL]) {
        NSLog(@"数据删除失败");
    }
}
#pragma mark - 9.排序：
void ORDERBY(){
    SHARESQLITEObjectC.SQLL.SELECT(SQL_DISTINCT,@"*",nil).FROM(@"Sutdent").ORDER.BY(@"ID").DESC;
    if (![[SQLITEObjectC share] execSQLL]) {
        NSLog(@"排序失败");
    }else{
        NSLog(@"%@",[SQLITEObjectC share].execSQLResultArray);
    }
}

#pragma mark - 10.事务：
void Transaction(){
    NSLog(@"start:%@",[NSDate date]);
    SHARESQLITEObjectC.SQLL.BEGIN.TRANSACTION.SEMICOLON;
    for (NSInteger i=0; i<100000; i++) {
        SHARESQLITEObjectC.SQLL.INSERT.INTO(@"Goods").COLUMNS(@"ID",@"name",@"price",@"imageUrl",nil).VALUES(@"'120702010011'",@"'这是啥东西'",@"9999999999999",@"'https://120702010011/yangyue.com'",nil).SEMICOLON;
    }
    SHARESQLITEObjectC.SQLL.COMMIT.SEMICOLON;
    
    NSLog(@"start:%@",[NSDate date]);
    if (!SHARESQLITEObjectC.execSQLL) {
        NSLog(@"事物执行失败");
    }
    NSLog(@"end:%@",[NSDate date]);
}


#pragma mark - ====== main函数 ======

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        openDB();
        
        //        SHARESQLITEObjectC.SQLL.CREATE.TABEL(@"Goods").COLUMNS(SQLlang.columnName(@"ID").TEXT.NOT(@"NULL"),
        //                                                               SQLlang.columnName(@"name").TEXT.NOT(@"NULL"),
        //                                                               SQLlang.columnName(@"price").REAL,
        //                                                               SQLlang.columnName(@"imageUrl").TEXT,
        //                                                               nil);

//        createTable();//创建表
//        dropTable();//删除表
//        insert();//插入数据
//        SELECT();//数据查询
//        ORDERBY();
//        Transaction();
        
        
        
        NSDate *stareDate=[NSDate date];
        NSInteger start=stareDate.timeIntervalSince1970;;
        SHARESQLITEObjectC.SQLL.BEGIN.TRANSACTION.SEMICOLON;
        SHARESQLITEObjectC.execSQLL;
        SHARESQLITEObjectC.SQLL.RESET.INSERT.INTO(@"Goods").COLUMNS(@"ID",@"name",@"price",@"imageUrl",nil).VALUES(@"'120702010011'",@"'这是啥东西'",@"9999999999999",@"'https://120702010011/yangyue.com'",nil).SEMICOLON;
        for (NSInteger i=0; i<1000000; i++) {
            SHARESQLITEObjectC.execSQLL;
        }
        SHARESQLITEObjectC.SQLL.RESET.COMMIT.SEMICOLON;
        SHARESQLITEObjectC.execSQLL;
        NSDate *endDate=[NSDate date];
        NSInteger end=endDate.timeIntervalSince1970;;
        NSLog(@"用时:%ld",end-start);
        
        

//        NSDate *stareDate=[NSDate date];
//        NSInteger start=stareDate.timeIntervalSince1970;;
//        SHARESQLITEObjectC.SQLL.BEGIN.TRANSACTION.SEMICOLON;
//        for (NSInteger i=0; i<1000000; i++) {
//            SHARESQLITEObjectC.SQLL.INSERT.INTO(@"Goods").COLUMNS(@"ID",@"name",@"price",@"imageUrl",nil).VALUES(@"'120702010011'",@"'这是啥东西'",@"9999999999999",@"'https://120702010011/yangyue.com'",nil).SEMICOLON;
//
//        }
//        SHARESQLITEObjectC.SQLL.COMMIT.SEMICOLON;
//        SHARESQLITEObjectC.execSQLL;
//        NSDate *endDate=[NSDate date];
//        NSInteger end=endDate.timeIntervalSince1970;;
//        NSLog(@"用时:%ld",end-start);
        closeDB();
    }
    return 0;
}

