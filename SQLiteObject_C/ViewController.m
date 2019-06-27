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

#define sql_Opertion @"opertion"
#define sql_Title @"Title"


@interface ViewController ()
<UITableViewDelegate ,UITableViewDataSource>
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,retain)NSMutableArray *dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"SQLiteObjectC使用实例";
    [self.view addSubview:self.tableView];
    
//    NSLog(@"%@",NSClassFromString(@"NSString"));
//    NSLog(@"%@",[NSValue class]);
//    NSLog(@"%@",[[NSClassFromString(@"NSString") alloc] init]);
//    if ( [[[NSClassFromString(@"StudentModel") alloc] init] isKindOfClass:[StudentModel class]]) {
//        NSLog(@"StudentModel");
//    }
//    @"NSStirng" @"NSValue" @"NSArray"
//    NSValue *value=[[NSValue alloc] init];

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -TableViewDetegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.dataArray count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary *dic=self.dataArray[section];
    
    return [dic[sql_Opertion] count];
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *lable=[[UILabel alloc] init];
    NSDictionary *dic=self.dataArray[section];
    lable.textColor=[UIColor redColor];
    lable.text=[NSString stringWithFormat:@"    %@",dic[sql_Title]];
    return lable;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic=self.dataArray[indexPath.section];
    NSArray *array=dic[sql_Opertion];
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    cell.textLabel.text=array[indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic=self.dataArray[indexPath.section];
    NSArray *array=dic[sql_Opertion];
    NSString *opertion=array[indexPath.row];
    if ([dic[sql_Title] isEqualToString:@"SQLiteLanguage类的使用"]) {
        if ([opertion isEqualToString:@"创建表"]) {
            [self createTable];
        }else if ([opertion isEqualToString:@"删除表"]){
            [self deleteTable];
        }else if ([opertion isEqualToString:@"插入数据"]){
            [self insert];
            
        }else if ([opertion isEqualToString:@"查询数据"]){
            [self select];
            
        }else if ([opertion isEqualToString:@"删除数据"]){
            [self delete];
            
        }else if ([opertion isEqualToString:@"更新数据"]){
            [self update];
            
        }else if ([opertion isEqualToString:@"查看数据库结构"]){
            [self seeDataBaseStruct];
        }
    }else if ([dic[sql_Title] isEqualToString:@"NSObject+SQLITE类别方法使用"]){
        if ([opertion isEqualToString:@"创建表"]) {
            [self obj_createTable];
        }else if ([opertion isEqualToString:@"删除表"]){
            [self obj_deleteTable];
        }else if ([opertion isEqualToString:@"插入数据"]){
            [self obj_insert];

        }else if ([opertion isEqualToString:@"查询数据"]){
            [self obj_select];

        }else if ([opertion isEqualToString:@"删除数据"]){
            [self obj_delete];

        }else if ([opertion isEqualToString:@"更新数据"]){
            [self obj_update];

        }else if ([opertion isEqualToString:@"查看数据库结构"]){
            [self obj_seeDataBaseStruct];
        }
    }
}

-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray=[@[
                      @{
                          sql_Title:@"SQLiteLanguage类的使用",
                          sql_Opertion:@[
                                  @"创建表",
                                  @"删除表",
                                  @"插入数据",
                                  @"查询数据",
                                  @"删除数据",
                                  @"更新数据",
                                  @"查看数据库结构"]
                          },
                      @{
                          sql_Title:@"NSObject+SQLITE类别方法使用",
                          sql_Opertion:@[
                                  @"创建表",
                                  @"删除表",
                                  @"插入数据",
                                  @"查询数据",
                                  @"删除数据",
                                  @"更新数据",
                                  @"查看数据库结构"
                                  ]
                          }
                      ] mutableCopy];
    }
    return _dataArray;
}
#pragma mark - SQLiteLanguage类的使用

-(void)createTable{
    
    SQLiteLanguage *sqll =SQLlang.CREATE.TABLE(@"StudentModel_TEST")
    .COLUMNS(
             SQLlang.columnName(@"stdID").TEXT,
             SQLlang.columnName(@"cls").TEXT,
             SQLlang.columnName(@"name").TEXT,
             SQLlang.columnName(@"sex").INTEGER,
             nil
             );
    SQLITEObjectC *db=[SQLITEObjectC share];
    [db openWithFilePath:[NSString sqlite_dbPath]];

    BOOL result=[db execSQLL:sqll result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
    }];
    if (result) {
        NSLog(@"创建成功");
    }
    [db close];
}
-(void)insert{
    SQLiteLanguage *sqll =SQLlang.INSERT.INTO(@"StudentModel_TEST").
    COLUMNS(@"stdID",@"cls",@"name",@"sex",nil).
    VALUES(@"'000000'",@"'六年级'",@"'杨越'",@"0",nil);
    
    SQLITEObjectC *db=[SQLITEObjectC share];
    [db openWithFilePath:[NSString sqlite_dbPath]];
    
    BOOL result=[db execSQLL:sqll result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
    }];
    if (result) {
        NSLog(@"插入成功");
    }
    [db close];
    
}

-(void)update{
    
    SQLiteLanguage *sqll =SQLlang.UPDATE(@"StudentModel_TEST").
    SET(@"stdID ='000000'",@"cls ='五年级'",@"name ='杨越'",@"sex =1",nil).WHERE(@"stdID ='000000'");
    
    SQLITEObjectC *db=[SQLITEObjectC share];
    [db openWithFilePath:[NSString sqlite_dbPath]];

    BOOL result=[db execSQLL:sqll result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
    }];
    if (result) {
        NSLog(@"修改成功");
    }
    [db close];
}

-(void)select{
    SQLiteLanguage *sqll=SQLlang.SELECT(@"*",nil).FROM(@"StudentModel_TEST").WHERE(@"stdID ='000000'");
    SQLITEObjectC *db=[SQLITEObjectC share];
    [db openWithFilePath:[NSString sqlite_dbPath]];
    
    [db execSQLL:sqll result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
        NSLog(@"%@",resultArray);
    }];
    [db close];
}
-(void)delete{
    SQLiteLanguage *sqll=SQLlang.DELETE.FROM(@"StudentModel_TEST").WHERE(@"stdID ='000000'");
    SQLITEObjectC *db=[SQLITEObjectC share];
    [db openWithFilePath:[NSString sqlite_dbPath]];
    BOOL result=[db execSQLL:sqll result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
    }];
    if (result) {
        NSLog(@"删除成功");
    }
    [db close];
}


-(void)seeDataBaseStruct{
    SQLiteLanguage* sqll=SQLlang.SELECT(@"*",nil).FROM(@"sqlite_master");
    SQLITEObjectC *db=[SQLITEObjectC share];
    [db openWithFilePath:[NSString sqlite_dbPath]];
    [db execSQLL:sqll result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
        NSLog(@"%@",resultArray);
    }];
    [db close];
}
-(void)deleteTable{
    SQLiteLanguage *sqll=SQLlang.DROP.TABLE(@"StudentModel_TEST");
    SQLITEObjectC *db=[SQLITEObjectC share];
    [db openWithFilePath:[NSString sqlite_dbPath]];
    BOOL result=[db execSQLL:sqll result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
    }];
    if (result) {
        NSLog(@"删除成功");
    }
    [db close];
    
}



#pragma mark - NSObject+SQLITE类别方法使用
-(void)obj_createTable{
    if ([StudentModel sqlite_tableCreateWithIsAssociation:YES]) {
        NSLog(@"表创建成功");
    }
}
-(void)obj_insert{
    StudentModel *std=[[StudentModel alloc] init];
    std.name=@"杨越";
    std.stdID=@"000000";
    std.sex=NO;
    std.cls=@"六年级";
    GradeModel *gradModel=[[GradeModel alloc] init];
    gradModel.ID=@"0";
    gradModel.name=@"数学";
    gradModel.fraction=99;
    gradModel.remark=@"考得不错再接再厉";
    
    GradeModel *gradModel1=[[GradeModel alloc] init];
    gradModel1.ID=@"1";
    gradModel1.name=@"语文";
    gradModel1.fraction=60;
    gradModel1.remark=@"要加油哦";
    std.transcript=[@[gradModel,gradModel1] mutableCopy];
    
    if ([std sqlite_tableInsertWithIsAssociation:YES]) {
        NSLog(@"插入成功");
    }
}

-(void)obj_update{
    StudentModel *std=[[StudentModel alloc] init];
    std.name=@"杨越";
    std.stdID=@"000000";
    std.sex=NO;
    std.cls=@"五年级";
    GradeModel *gradModel=[[GradeModel alloc] init];
    gradModel.ID=@"0";
    gradModel.name=@"数学";
    gradModel.fraction=99;
    gradModel.remark=@"考得不错再接再厉";
    
    GradeModel *gradModel1=[[GradeModel alloc] init];
    gradModel1.ID=@"1";
    gradModel1.name=@"语文";
    gradModel1.fraction=100;
    gradModel1.remark=@"要加油哦";
    std.transcript=[@[gradModel,gradModel1] mutableCopy];
    
    if ([std sqlite_tableUpdateWithIsAssociation:YES]) {
        NSLog(@"更新成功");
    }
}

-(void)obj_select{
    NSArray *array=[StudentModel sqlite_tableSelectWithCondition:SQLlang.WHERE(@"stdID='000000'") IsAssociation:YES];
    [array toDictionary];
//    NSLog(@"%@",array);
}
-(void)obj_delete{
    if ([StudentModel sqlite_tableDeleteWithCondition:SQLlang.WHERE(@"stdID='000000'") IsAssociation:YES]) {
        NSLog(@"删除成功");
    }
}
-(void)obj_seeDataBaseStruct{
    NSArray *array=[StudentModel sqlite_dbSeeTables];
    NSLog(@"数据库结构：%@",array);
}
-(void)obj_deleteTable{
    if ([StudentModel sqlite_tableDropIsAssociation:YES]) {
        NSLog(@"删除成功");
    }
}
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView=[[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        _tableView.rowHeight=60;
    }
    return _tableView;
}

@end
