//
//  ViewController.m
//  SQLiteObject_C
//
//  Created by POSUN-MAC on 2019/3/29.
//  Copyright © 2019 POSUN-MAC. All rights reserved.
//

#import "ViewController.h"
#import "SQLITEObjectC.h"
#import "NSObject+SQLITE.h"
#import "NSObject+Dictionary.h"
#import "StudentModel.h"
@interface ViewController ()

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,retain)NSMutableArray *dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"SQLiteObjectC使用实例";
    [self.view addSubview:self.tableView];
    
//    PersonModel *superModel=[[PersonModel alloc] init];
//    superModel.ID=@"1207020210010";
//    superModel.name=@"iOS0";
//    superModel.sex=0;
//    superModel.age=33;
//
//    PersonModel *supermodel=[[PersonModel alloc] init];
//    supermodel.ID=@"1207020210010";
//    supermodel.name=@"iOS0";
//    supermodel.sex=0;
//    supermodel.age=33;
//    superModel.family=[@[supermodel] mutableCopy];

//    [PersonModel sqlite_tableCreateWithIsAssociation:YES];
    
    
    
    StudentModel *model=[[StudentModel alloc] init];
    model.ID=@"1207020210011";
    model.name=@"iOS";
    model.sex=0;
    model.age=22;
//    model.family=[@[supermodel] mutableCopy];
    model.stdID=@"1";
    model.cls=@"102";
    
    
    GradeModel *modelg=[[GradeModel alloc] init];
    modelg.language=88;
    modelg.mathematics=99;
    
    
    GradeModel *modelg1=[[GradeModel alloc] init];
    modelg1.language=8;
    modelg1.mathematics=9;
    
    model.data=[@[modelg,modelg1] mutableCopy];
    
//    [StudentModel sqlite_tableCreateWithIsAssociation:YES];
    NSLog(@"%@",[StudentModel sqlite_dbSeeTables]);

    NSArray *array=[StudentModel sqlite_tableSelectWithCondition:nil IsAssociation:YES];
//    [model sqlite_tableInsertWithIsAssociation:YES];
    
    
//   NSArray *array = [StudentModel sqlite_tableSelectWithCondition:nil IsAssociation:YES];
//    if ([model sqlite_tableInsertWithIsAssociation:YES]) {
//        NSLog(@"成功");
//    };
    
//    NSLog(@"%@",[NSObject sqlite_dbSeeTables]);
//    if ([model sqlite_tableInsertWithIsAssociation:YES]) {
//        NSLog(@"写入成功");
//    }

//    NSLog(@"%@",[NSObject sqlite_dbSeeTables]);
//    NSArray *array =[StudentModel sqlite_tableSelectWithCondition:nil IsAssociation:NO];
//    NSLog(@"%@",array);
    
//    if ([StudentModel sqlite_tableCreateWithIsAssociation:YES]) {
//        NSLog(@"表创建成功");
//    }
//    [GradeModel sqlite_tableDropIsAssociation:NO];
//    NSLog(@"%@",[StudentModel sqlite_dbSeeTables]);

//    SQLiteLanguage *sql=[[SQLiteLanguage alloc] init];
//    sql.SELECT(@"*",nil).FROM(@"StudentModel");
//    NSArray *array =[StudentModel sqlite_tableSelectWithCondition:nil IsAssociation:YES];
//    NSLog(@"%@",array);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
