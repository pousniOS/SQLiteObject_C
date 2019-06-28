
//
//  SQLITEObjectCTests.m
//  SQLiteObject_CTests
//
//  Created by mac on 2019/6/28.
//  Copyright © 2019 POSUN-MAC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SQLITEObjectC.h"
@interface SQLITEObjectCTests : XCTestCase
@end

@implementation SQLITEObjectCTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.

}
- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}
#pragma mark - 数据库连接
-(void)test_connectionWithFilePath{
    BOOL result = [SHARESQLITEObjectC connectionWithFilePath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:[NSString stringWithFormat:@"/%@",@"SQLITE_DATABASEE"]]];
    XCTAssert(result,@"数据库连接失败");
}
#pragma mark - 打开数据库
-(void)test_open{
    [self test_connectionWithFilePath];
    BOOL result = [SHARESQLITEObjectC open];
    XCTAssert(result,@"数据库打开失败");
}
#pragma mark - 关闭数据库
-(void)test_close{
    [self test_connectionWithFilePath];
    BOOL result = [SHARESQLITEObjectC close];
    XCTAssert(result,@"数据库关闭失败");
}
#pragma mark - 执行SQLL创建表
-(void)test_execSQLL_Create{


    [self test_connectionWithFilePath];
    SQLiteLanguage *sql=SQLlang.SELECT(@"count(*)",nil).FROM(@"sqlite_master").WHERE(@"type='table'").AND([NSString stringWithFormat:@"tbl_name='%@'",@"Student"]);
    __block NSInteger count = NO;
    [SHARESQLITEObjectC execSQLL:sql result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
        if (resultArray.count == 1&&[resultArray[0][@"count(*)"] integerValue] == 1) {
            count = [resultArray[0][@"count(*)"] integerValue];
        }
    }];
    if (count) {return;}
   sql =SQLlang.CREATE.TABLE(@"Student").COLUMNS(
                                                  SQLlang.columnName(@"ID").TEXT,
                                                  SQLlang.columnName(@"age").INTEGER,
                                                  SQLlang.columnName(@"name").TEXT,
                                                  nil
                                                  );
    BOOL result  = [SHARESQLITEObjectC execSQLL:sql result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
    }];
    XCTAssert(result,@"表创建失败");
    [self test_close];
}

#pragma mark - 执行SQLL插入数据
-(void)test_execSQLL_Insert{
    [self test_execSQLL_Create];
    [self test_connectionWithFilePath];
    SQLiteLanguage *sql  = SQLlang.INSERT.INTO(@"Student").COLUMNS(@"ID",@"age",@"name",nil).VALUES(@"'120702010011'",@"22",@"'yangYue'",nil);
    BOOL result = [SHARESQLITEObjectC execSQLL:sql result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
    }];
    XCTAssert(result,@"插入失败");
    [self test_close];
}

#pragma mark - 执行SQLL查询数据
-(void)test_execSQLL_Select{
    [self test_connectionWithFilePath];
    SQLiteLanguage *sql = SQLlang.SELECT(@"*",nil).FROM(@"Student");
    BOOL result = [SHARESQLITEObjectC execSQLL:sql result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
        NSLog(@"%@",resultArray);
    }];
    XCTAssert(result,@"查询失败");
    [self test_close];
}
#pragma mark - 事务方式执行SQLL创建表
-(void)test_execByTransactionWithSQLL{
    [self test_connectionWithFilePath];
    SQLiteLanguage *sql=SQLlang.SELECT(@"count(*)",nil).FROM(@"sqlite_master").WHERE(@"type='table'").AND([NSString stringWithFormat:@"tbl_name='%@'",@"Student"]);
    __block NSInteger count = NO;
    [SHARESQLITEObjectC execByTransactionWithSQLL:sql result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
        if (resultArray.count == 1&&[resultArray[0][@"count(*)"] integerValue] == 1) {
            count = [resultArray[0][@"count(*)"] integerValue];
        }
    }];
    if (count) {return;}
    sql =SQLlang.CREATE.TABLE(@"Student").COLUMNS(
                                                  SQLlang.columnName(@"ID").TEXT,
                                                  SQLlang.columnName(@"age").INTEGER,
                                                  SQLlang.columnName(@"name").TEXT,
                                                  nil
                                                  );
    BOOL result  = [SHARESQLITEObjectC execByTransactionWithSQLL:sql result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
    }];
    XCTAssert(result,@"表创建失败");
    [self test_close];
}
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
