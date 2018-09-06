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
<
UITableViewDelegate,
UITableViewDataSource
>
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,retain)NSMutableArray *dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    cell.textLabel.text=self.dataArray[indexPath.row];
    return cell;
}
-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0f;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    NSString *code=cell.textLabel.text;
    if ([code isEqualToString:@"查看数据库表结构"]) {
        [self db_seeTables];
    }else if ([code isEqualToString:@"创建表"]) {
        [self table_create];
    }else if ([code isEqualToString:@"删除表"]){
        [self table_drop];
    }else if ([code isEqualToString:@"表插入数据"]){
        [self table_insert];
    }else if ([code isEqualToString:@"数据查询"]){
        [self table_select];
    }
}
#pragma mark - ====== Get ======
-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray=[[NSMutableArray alloc] init];
        [_dataArray addObject:@"查看数据库表结构"];
        [_dataArray addObject:@"创建表"];
        [_dataArray addObject:@"删除表"];
        [_dataArray addObject:@"表插入数据"];
        [_dataArray addObject:@"数据查询"];
    }
    return _dataArray;
}
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView=[[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.delegate=self;
        _tableView.dataSource=self;
    }
    return _tableView;
}
#pragma mark - ====== "NSString+SQLITE.h"测试函数 ======
-(void)table_create{
    if ([TEST tableCreate]) {
        NSLog(@"创建成功");
    }else{
        NSLog(@"表创建失败");
    }
}
-(void)table_drop{
    if ([TEST tableDropAll]) {
        NSLog(@"删除成功");
    }else{
        NSLog(@"删除失败");
    }
}
-(void)table_insert{
    //给test对象赋值（注意填写正确的文件路径）
    NSString *str=[NSString stringWithContentsOfFile:@"/Users/POSUN/Documents/SQLiteObject_C/SQLiteObject_C/Model/TestJson.json" encoding:NSUTF8StringEncoding error:nil];
    
    if (str == nil){return ;}
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error=nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
    TEST *test=[[TEST alloc] init];
    [test setValuesForKeysWithDictionary:dic];
    if ([test table_Insert]) {
        NSLog(@"插入成功");
    }else{
        NSLog(@"插入失败");
    }
}
-(void)db_seeTables{
    NSLog(@"%@",[TEST db_seeTables]);
}
-(void)table_select{
    NSArray<TEST *> *array=[TEST table_SelectWithCondition:nil];
    [array enumerateObjectsUsingBlock:^(TEST * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj table_SelectWithPropertyName:@"salesOrder" andCondition:nil];
        NSLog(@"%@",obj.salesOrder);
        [obj.salesOrder table_SelectWithPropertyName:@"salesOrderParts" andCondition:nil];
        NSLog(@"%@",obj.salesOrder.salesOrderParts);
        
        
        [obj.salesOrder.salesOrderParts enumerateObjectsUsingBlock:^(SalesOrderParts * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj table_SelectWithPropertyName:@"goods" andCondition:nil];
            NSLog(@"%@",obj.goods);
        }];
    }];
}

#pragma mark - ====== SQLiteLanguage测试函数 ======
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
    SQLiteLanguage *sql =SQLlang.CREATE.TABLE(@"Sutdent").COLUMNS(
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
    SQLiteLanguage *sql= SQLlang.DROP.TABLE(@"Sutdent");
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
