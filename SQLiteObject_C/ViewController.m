//
//  ViewController.m
//  SQLiteObject_C
//
//  Created by POSUN-MAC on 2018/7/24.
//  Copyright © 2018年 POSUN-MAC. All rights reserved.
//

#import "ViewController.h"
#import "SQLITEObjectC.h"
#import "TEST.h"
#import "NSObject+SQLITE.h"
#import "NSObject+Dictionary.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [TEST tableCreate];
    

    

    openDB();
//    createTable();
    Transaction();
    closeDB();

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - ====== 测试函数 ======
#pragma mark - 1.打开数据库，通过SQLITEObjectC类的单例来创建数据库连接：
void openDB(){
    NSString *pathStr =[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/TEST.db"];
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
    SQLiteLanguage *sql =SQLlang.CREATE.TABEL(@"Sutdent").COLUMNS(
                                             SQLlang.columnName(@"age").INTEGER,//列名叫age,INTEGER类型的数据,不许为空
                                             SQLlang.columnName(@"name").TEXT,
                                             SQLlang.columnName(@"ID").TEXT.NOT(@"NULL").PRIMARY.KEY(nil),//列名叫ID,TEXT类型的数据同时设置为主键,不许为空
                                             nil
                                             );
    [SHARESQLITEObjectC execSQLL:sql result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
        
    }];
}
#pragma mark - 4.删除表：
void dropTable(){
    SQLiteLanguage *sql= SQLlang.DROP.TABEL(@"Sutdent");
    [SHARESQLITEObjectC execSQLL:sql result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
        
    }];
}
#pragma mark - 5.向表插入数据：
void insert(){
    SQLiteLanguage *sql =SQLlang.INSERT.INTO(@"Sutdent").COLUMNS(@"age",@"name",@"ID",nil).VALUES(@"24",@"'马悦'",@"120702010013",nil);
    [SHARESQLITEObjectC execSQLL:sql result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
        
    }];
}
#pragma mark - 6.数据查询，查询到的结果通过SQLITEObjectC类的单例execSQLResultArray获取：
void SELECT(){
    SQLiteLanguage *sql =SQLlang.SELECT(SQL_DISTINCT,@"*",nil).FROM(@"Sutdent").WHERE(@"name='马悦'");
    [SHARESQLITEObjectC execSQLL:sql result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
        
    }];
}
#pragma mark - 7.修改表数据：
void UPDATE(){
    SQLiteLanguage *sql =SQLlang.UPDATE(@"Sutdent").SET(@"name='小明'",@"age=90",nil).WHERE(@"ID='120702010019'");
    [SHARESQLITEObjectC execSQLL:sql result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
        
    }];
}
#pragma mark - 8.删除表数据：
void DELETE(){
    SQLiteLanguage *sql =SQLlang.DELETE.FROM(@"Sutdent").WHERE(@"ID='120702010019'");
    [SHARESQLITEObjectC execSQLL:sql result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
        
    }];
}
#pragma mark - 9.排序：
void ORDERBY(){
    SQLiteLanguage *sql =SQLlang.SELECT(SQL_DISTINCT,@"*",nil).FROM(@"Sutdent").ORDER.BY(@"ID").DESC;
    [SHARESQLITEObjectC execSQLL:sql result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
        
    }];
}

#pragma mark - 10.事务：
void Transaction(){
    NSLog(@"start:%@",[NSDate date]);
    SQLiteLanguage *sql=SQLlang;
    [sql.BEGIN.TRANSACTION SEMICOLON];
    for (NSInteger i=0; i<100000; i++) {
        [sql.INSERT.INTO(@"Sutdent").COLUMNS(@"age",@"name",@"ID",nil).VALUES(@"24",@"'马悦'",@"120702010013",nil) SEMICOLON];
    }
    [sql.COMMIT.TRANSACTION SEMICOLON];
    NSLog(@"start:%@",[NSDate date]);
    [SHARESQLITEObjectC execSQLL:sql result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
    }];
    NSLog(@"end:%@",[NSDate date]);
}



@end
