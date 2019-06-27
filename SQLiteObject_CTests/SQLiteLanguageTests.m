//
//  SQLiteLanguageTests.m
//  SQLiteObject_CTests
//
//  Created by mac on 2019/6/27.
//  Copyright © 2019 POSUN-MAC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SQLiteLanguage.h"
@interface SQLiteLanguageTests : XCTestCase

@end

@implementation SQLiteLanguageTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}


-(void)test_Create{
    XCTAssert([SQLlang.CREATE.sql isEqualToString:@"CREATE "],@"sql 应该返回‘CREATE ’");
}

-(void)test_FOREIGN{
    XCTAssert([SQLlang.FOREIGN.sql isEqualToString:@"FOREIGN "],@"sql 应该返回‘FOREIGN ’");
}

-(void)test_REFERENCES{
    XCTAssert([SQLlang.REFERENCES(@"Student").sql isEqualToString:@"REFERENCES Student "],@"sql 应该返回‘REFERENCES Student ’");
}
-(void)test_PRIMARY{
    XCTAssert([SQLlang.PRIMARY.sql isEqualToString:@"PRIMARY "],@"sql 应该返回‘PRIMARY ’");
}
-(void)test_KEYS{
    NSString *sql = SQLlang.KEY(@"name",@"id",nil).sql;
    XCTAssert([sql isEqualToString:@"KEY(name,id)  "],@"sql 应该返回‘KEY(name,id)  ’");
    sql = SQLlang.KEY(nil).sql;
    XCTAssert([sql isEqualToString:@"KEY "],@"sql 应该返回‘KEY ’");
}
-(void)test_NOT{
    NSString *sql = SQLlang.NOT(@"yangYue").sql;
    XCTAssert([sql isEqualToString:@"NOT yangYue "],@"sql 应该返回‘NOT yangYue ’");
}
-(void)test_TABLE{
    NSString *sql = SQLlang.TABLE(@"Student").sql;
    XCTAssert([sql isEqualToString:@"TABLE Student "],@"sql 应该返回‘TABLE Student ’");
}
-(void)test_COLUMNS{
    NSString *sql = SQLlang.COLUMNS(@"name",@"sex",nil).sql;
    XCTAssert([sql isEqualToString:@"(name,sex) "],@"sql 应该返回‘(name,sex) ’");
    
    NSString *subSql = SQLlang.COLUMNS(@"name",@"sex",nil).sql;
    sql = SQLlang.COLUMNS(@"name",@"sex",subSql,nil).sql;
    XCTAssert([sql isEqualToString:@"(name,sex,(name,sex) ) "],@"sql 应该返回‘(name,sex,(name,sex) ) ’");
}
-(void)test_columnName{
    NSString *sql = SQLlang.columnName(@"name").sql;
    XCTAssert([sql isEqualToString:@"name "],@"sql 应该返回‘name ’");
}
-(void)test_CONSTRAINT{
    NSString *sql = SQLlang.CONSTRAINT(@"index").sql;
    XCTAssert([sql isEqualToString:@"CONSTRAINT index "],@"sql 应该返回‘CONSTRAINT name ’");
}

-(void)test_UNIQUE{
    NSString *sql = SQLlang.UNIQUE.sql;
    XCTAssert([sql isEqualToString:@"UNIQUE "],@"sql 应该返回‘UNIQUE ’");
}
-(void)test_CHECK{
    NSString *sql = SQLlang.CHECK(@"yangYue").sql;
    XCTAssert([sql isEqualToString:@"CHECK (yangYue) "],@"sql 应该返回‘CHECK (yangYue) ’");
}

-(void)test_DEFAULT{
    NSString *sql = SQLlang.DEFAULT(@"NULL").sql;
    XCTAssert([sql isEqualToString:@"DEFAULT NULL "],@"sql 应该返回‘DEFAULT NULL ’");
}
-(void)test_AUTOINCREMENT{
    NSString *sql = SQLlang.AUTOINCREMENT.sql;
    XCTAssert([sql isEqualToString:@"AUTOINCREMENT "],@"sql 应该返回‘AUTOINCREMENT ’");
}
-(void)test_INTEGER{
    NSString *sql = SQLlang.INTEGER.sql;
    XCTAssert([sql isEqualToString:@"INTEGER "],@"sql 应该返回‘INTEGER ’");
}

-(void)test_REAL{
    NSString *sql = SQLlang.REAL.sql;
    XCTAssert([sql isEqualToString:@"REAL "],@"sql 应该返回‘REAL ’");
}

-(void)test_TEXT{
    NSString *sql = SQLlang.TEXT.sql;
    XCTAssert([sql isEqualToString:@"TEXT "],@"sql 应该返回‘TEXT ’");
}

-(void)test_BLOB{
    NSString *sql = SQLlang.BLOB.sql;
    XCTAssert([sql isEqualToString:@"BLOB "],@"sql 应该返回‘BLOB ’");
}
-(void)test_DROP{
    NSString *sql = SQLlang.DROP.sql;
    XCTAssert([sql isEqualToString:@"DROP "],@"sql 应该返回‘DROP ’");
}
-(void)test_INSERT{
    NSString *sql = SQLlang.INSERT.sql;
    XCTAssert([sql isEqualToString:@"INSERT "],@"sql 应该返回‘INSERT ’");
}

-(void)test_INTO{
    NSString *sql = SQLlang.INTO(@"Student").sql;
    XCTAssert([sql isEqualToString:@"INTO Student "],@"sql 应该返回‘INTO Student ’");
}
-(void)test_VALUES{
    NSString *sql = SQLlang.VALUES(@"yangYue",@"20",nil).sql;
    XCTAssert([sql isEqualToString:@"VALUES(yangYue,20)  "],@"sql 应该返回‘VALUES(yangYue,20)  ’");
    sql = SQLlang.VALUES(nil).sql;
    XCTAssert([sql isEqualToString:@"VALUES "],@"sql 应该返回‘VALUES ’");
}
-(void)test_FROM{
    NSString *sql = SQLlang.FROM(@"Student").sql;
    XCTAssert([sql isEqualToString:@"FROM Student "],@"sql 应该返回‘FROM Student ’");
}
-(void)test_SELECT{
    NSString *sql = SQLlang.SELECT(@"*",nil).sql;
    XCTAssert([sql isEqualToString:@"SELECT * "],@"sql 应该返回‘SELECT * ’");
    sql = SQLlang.SELECT(@"name",@"sex",@"age",nil).sql;
    XCTAssert([sql isEqualToString:@"SELECT name sex,age  "],@"sql 应该返回‘SELECT name sex,age  ’");
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
