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
    
    PersonModel *supermodel=[[PersonModel alloc] init];
    supermodel.ID=@"1207020210010";
    supermodel.name=@"iOS0";
    supermodel.sex=0;
    supermodel.age=33;
    
    
    StudentModel *model=[[StudentModel alloc] init];
    model.ID=@"1207020210011";
    model.name=@"iOS";
    model.sex=0;
    model.age=22;
    model.family=[@[supermodel] mutableCopy];
    model.stdID=@"1";
    model.cls=@"102";
    model.grade=[[GradeModel alloc] init];
    model.grade.language=88;
    model.grade.mathematics=99;
//    NSLog(@"%@",[NSObject sqlite_dbSeeTables]);
    
    if ([StudentModel sqlite_tableCreateWithIsAssociation:YES]) {
        NSLog(@"表创建成功");
    }
//    if ([StudentModel sqlite_tableDropIsAssociation:NO]) {
//        NSLog(@"删除成功");
//    }
//    if ([model sqlite_tableInsertWithIsAssociation:YES]) {
//        NSLog(@"写入成功");
//    }
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
