//
//  NSObject+SQLITE.m
//  SQLiteObject_C
//
//  Created by POSUN-MAC on 2018/7/23.
//  Copyright © 2018年 POSUN-MAC. All rights reserved.
//
#import "NSObject+SQLITE.h"
#import "NSObject+Dictionary.h"
#import <objc/runtime.h>
#import "NSArray+TypeCheck.h"
#import "NSString+TypeCheck.h"
#import "NSValue+TypeCheck.h"
#import "NSDictionary+TypeCheck.h"

const static char SqliteTableForeignKeyID='\0';
const static char SqliteTablePrimaryKeyID='\0';
const static char SqliteTableRecordingOwnKey='\0';

#define SQLITE_TABLE_PRIMARYKEY_ID @"SQLITE_TABLE_PRIMARYKEY_ID"
#define SQLITE_TABLE_FOREIGNKEY_ID @"SQLITE_TABLE_FOREIGNKEY_ID"
#define SQLITE_TABLE_DEFULTKEY_TYPE @"NSString"
#define SQLITE_DATABASEE @"SQLIT_DATABASEE.db"
//用于指定数据库记录所属Model对象的属性的字段
#define SQLITE_TABLE_RecordingOwn_KEY @"SQLITE_TABLE_RecordingOwn_KEY"
#define SQLITE_TABLE_DICTIONARY_KEY @"SQLITE_TABLE_DICTIONARY_KEY"
#define SQLITE_SQLL_DICTIONARY_KEY @"SQLITE_SQLL_DICTIONARY_KEY"
#define SQLITE_VALUE_DICTIONARY_KEY @"SQLITE_VALUE_DICTIONARY_KEY"

@interface NSObject()
/**
 记录所属的对象属性的字段是谁，因为可能存在这样的数据列如：
 object:{
 data:[b0,b1,b2];
 list:[l0,l1,l3];
 }假设b0对象和l0对象类型相同这是就需要一个字段来记录b0，...;l0,....属于object的哪一个属性字段；
 **/
@property(nonatomic,copy)NSString *sqliteTableRecordingOwnKey;
/**
 数据主键值
 **/
@property(nonatomic,copy)NSString *sqliteTablePrimaryKeyID;
/**
 数据外键值
 **/
@property(nonatomic,copy)NSString *sqliteTableForeignKeyID;
@end

@implementation NSObject (SQLITE)
+(NSString *)sqlite_dbPath{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:[NSString stringWithFormat:@"/%@",SQLITE_DATABASEE]];
}
+(BOOL)sqlite_tableIsExist{
    SQLiteLanguage *sql=SQLlang.SELECT(@"count(*)",nil).FROM(@"sqlite_master").WHERE(@"type='table'").AND([NSString stringWithFormat:@"tbl_name='%@'",[self sqlite_tableName]]);
    __block BOOL result=NO;
    [self sqlite_dbOpen];
    [SHARESQLITEObjectC execSQLL:sql result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
        if (errorInfor) {
            result=NO;
        }else{
            NSDictionary *dic =[resultArray firstObject];
            result=[dic[@"count(*)"] integerValue];
        }
    }];
    [self sqlite_dbClose];
    return result;
}
+(NSArray *)analyticalBuildTableField{
    NSArray *fieldArray =[self propertyInforArray];
    fieldArray=[self filterProperty:[self sqlite_tableUnconversionProperty]];
    fieldArray=[self checkSetKEY:fieldArray andKey:SQLITE_TABLE_PRIMARYKEY_ID];
    fieldArray=[self checkSetKEY:fieldArray andKey:SQLITE_TABLE_FOREIGNKEY_ID];
    return fieldArray;
}


+(BOOL)sqlite_tableCreateWithIsAssociation:(BOOL)flag{

    /**
     1.通过类名获取tableSqlArray，tableSqlArray结构如下
     @[@{
         表名key:表明,
         sql语句对象key:表sql语句对象
         }
     .....
     ]
     **/
    NSMutableArray<NSDictionary *> *tableSqlArray=[[NSMutableArray alloc] init];
    [self tableBuildTableSqlWithTableSqlArray:tableSqlArray IsAssociation:flag];
    /**
     2.通过tableSqlArray拼接成一条sqll对象的创建表的语句
     **/
    SQLiteLanguage *sqll=SQLlang;
    [tableSqlArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        sqll.APPEND(obj[SQLITE_SQLL_DICTIONARY_KEY]);
    }];
    
    /**
     3.通过sqll对象创建数据库表
     **/
    [self sqlite_dbOpen];
    BOOL result=[SHARESQLITEObjectC execByTransactionWithSQLL:sqll result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
    }];
    [self sqlite_dbClose];
    return result;
}
+(void)tableBuildTableSqlWithTableSqlArray:(NSMutableArray<NSDictionary*>*)tableSqlArray IsAssociation:(BOOL)flag{
//    /**
//     判断该类继承的父类不是系统基本类型就创建改父类的Sql表语句
//     **/
//    if (![[self superclass] isBasicType]) {
//        [[self superclass] tableBuildTableSqlWithTableSqlArray:tableSqlArray IsAssociation:flag];
//    }
    /**
     1.创建表sql语句
     **/
    NSArray *fieldArray =[self analyticalBuildTableField];
    SQLiteLanguage *sql =SQLlang;
    sql.columnName(SQLITE_TABLE_RecordingOwn_KEY);
    [sql.TEXT COMMA];
    NSMutableSet *subTableSet=[[NSMutableSet alloc] init];
    for (NSInteger i=0; i<fieldArray.count; i++) {
        NSString *propertyType=fieldArray[i][PropertyType];
        NSString *propertyName=fieldArray[i][PropertyName];
        if ([NSObject isStringType:propertyType]) {
            sql.columnName(propertyName);
            [sql TEXT];
        }else if ([NSObject isCNumberType:propertyType]){
            sql.columnName(propertyName);
            [sql INTEGER];
        }else if ([NSObject isCFNumberType:propertyType]){
            sql.columnName(propertyName);
            [sql REAL];
        }else if ([NSObject isValueType:propertyType]){
            sql.columnName(propertyName);
            [sql REAL];
        }else if ([NSObject isArrayType:propertyType]){
            NSDictionary *dic=[self sqlite_tablePropertyNameAndElementTypeDictionary];
            NSString *type =dic[propertyName];
            [subTableSet addObject:type];
            continue;
        }else if ([NSObject isDictionaryType:propertyType]){
            continue;
        }else{
            [subTableSet addObject:propertyType];
            continue;
        }
        /**设置主键**/
        if ([propertyName isEqualToString:SQLITE_TABLE_PRIMARYKEY_ID]) {
            sql.PRIMARY.KEY(nil);
        }
        if (fieldArray.count!=i+1) {
            [sql COMMA];
        }
    }
    /**
     2.排除重复的表，判断是否有重名的表有就不加入到tableSqlArray
     **/
    __block BOOL fg=NO;
    [tableSqlArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[SQLITE_TABLE_DICTIONARY_KEY] isEqualToString:[self sqlite_tableName]]) {
            fg=YES;
            *stop=YES;
        }
    }];
    if (!fg) {
        SQLiteLanguage *SQLL=[SQLlang.CREATE.TABLE([self sqlite_tableName]).COLUMNS(sql,nil) SEMICOLON];
        NSDictionary *tableSqlDic=@{
                                    SQLITE_TABLE_DICTIONARY_KEY:[self sqlite_tableName],
                                    SQLITE_SQLL_DICTIONARY_KEY:SQLL
                                    };
        [tableSqlArray addObject:tableSqlDic];
    }
    /**
     3.flag是YES,就同时生成和这个类关联的成员属性类型的数据库表
     **/
    if (flag) {
        [subTableSet enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
            Class class=NSClassFromString(obj);
            [class tableBuildTableSqlWithTableSqlArray:tableSqlArray IsAssociation:flag];
        }];
    }
}
+(NSArray<NSString *>*)sqlite_getTablesWithIsAssociation:(BOOL)flag{
    NSMutableArray *tables=[[NSMutableArray alloc] init];
    [tables addObject:[self sqlite_tableName]];
    if (flag) {
        NSArray *propertys =[self propertyInforArray];
        [propertys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *propertyType=propertys[idx][PropertyType];
            NSString *propertyName=propertys[idx][PropertyName];
            if ([NSObject isStringType:propertyType]) {
            }else if ([NSObject isCNumberType:propertyType]){
            }else if ([NSObject isCFNumberType:propertyType]){
            }else if ([NSObject isValueType:propertyType]){
            }else if ([NSObject isArrayType:propertyType]){//table
                NSDictionary *dic=[self sqlite_tablePropertyNameAndElementTypeDictionary];
                NSString *type =dic[propertyName];
                Class class=NSClassFromString(type);
                [self excludeRepeatAddObjects:@[[class sqlite_tableName]] ToArray:tables];
                [self excludeRepeatAddObjects:[class sqlite_getTablesWithIsAssociation:flag] ToArray:tables];
            }else if ([NSObject isDictionaryType:propertyType]){
            }else{//table
                Class class=NSClassFromString(propertyType);
                [self excludeRepeatAddObjects:@[[class sqlite_tableName]] ToArray:tables];
                [self excludeRepeatAddObjects:[class sqlite_getTablesWithIsAssociation:flag] ToArray:tables];
            }
        }];
    }
    return tables;
}

-(void)excludeRepeatAddObjects:(NSArray *)objects ToArray:(NSMutableArray *)array{
    [objects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([array containsObject:obj]) {
            [array removeObject:obj];
        }
        [array addObject:obj];
    }];
}

+(NSArray *)sqlite_dbSeeTables{
    [self sqlite_dbOpen];
    SQLiteLanguage* sql=SQLlang.SELECT(@"*",nil).FROM(@"sqlite_master");
    __block NSArray *resultArr=nil;
    [SHARESQLITEObjectC execSQLL:sql result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
        resultArr=resultArray;
    }];
    [self sqlite_dbClose];
    return resultArr;
}

+(BOOL)sqlite_tableDropIsAssociation:(BOOL)flag{
    SQLiteLanguage *sqll=SQLlang;
    [[self sqlite_getTablesWithIsAssociation:flag] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Class class=NSClassFromString(obj);
        [sqll.DROP.TABLE([class sqlite_tableName]) SEMICOLON];
    }];
    [self sqlite_dbOpen];
    BOOL result=[SHARESQLITEObjectC execByTransactionWithSQLL:sqll result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
        
    }];
    [self sqlite_dbClose];
    return result;
}
+(BOOL)sqlite_dbOpen{
    if (SHARESQLITEObjectC.isOpen) {
        if ([SHARESQLITEObjectC.dbPath isEqualToString:self.sqlite_dbPath]) {
            return YES;
        }else{
            if ([SHARESQLITEObjectC close]) {
                return [SHARESQLITEObjectC openWithFilePath:self.sqlite_dbPath];
            }else{
                return NO;
            }
        }
    }else{
        return [SHARESQLITEObjectC openWithFilePath:self.sqlite_dbPath];
    }
}

+(BOOL)sqlite_dbClose{
    if ([SHARESQLITEObjectC.dbPath isEqualToString:self.sqlite_dbPath]) {
        if (SHARESQLITEObjectC.isOpen) {
            return [SHARESQLITEObjectC close];
        }else{
            return YES;
        }
    }else{
        return YES;
    }
}

+(NSArray *)checkSetKEY:(NSArray *)propertys andKey:(NSString *)key{
    __block BOOL flag=NO;
    [propertys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[PropertyName] isEqualToString:key]) {
            flag=YES;
            *stop=YES;
        }
    }];
    if (!flag) {
        NSMutableArray *array=[propertys mutableCopy];
        [array addObject:@{
                           PropertyName:key,
                           PropertyType:SQLITE_TABLE_DEFULTKEY_TYPE,
                           }];
        propertys=array;
    }
    return propertys;
}
+(NSString *)sqlite_tableName{
    return NSStringFromClass(self);
}
+(NSSet*)sqlite_tableUnconversionProperty{
    return nil;
}
+(NSString *)sqlite_tablePrimaryKeyValueSetProperty{
    return nil;
}
+(NSDictionary*)sqlite_tablePropertyNameAndElementTypeDictionary{
    return nil;
}

+(BOOL)sqlite_tableDeleteWithCondition:(SQLiteLanguage *)condition IsAssociation:(BOOL)flag{
    __block NSMutableArray<SQLiteLanguage*> *sqlArray=[[NSMutableArray alloc] init];
    if (flag) {
        NSArray *resultArray =[self sqlite_tableSelectWithCondition:condition IsAssociation:YES];
        [resultArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableArray<SQLiteLanguage*> *subSqlArray=[[NSMutableArray alloc] init];
            [obj tableBuildDeleteSqlArray:subSqlArray IsAssociation:YES];
            [sqlArray addObjectsFromArray:subSqlArray];
        }];
    }else{
        SQLiteLanguage *sqll=SQLlang.DELETE.FROM([self sqlite_tableName]);
        sqll.APPEND(condition);
        [sqll.COMMIT SEMICOLON];
        [sqlArray addObject:sqll];
    }
    
    SQLiteLanguage *sqll=SQLlang;
    [sqlArray enumerateObjectsUsingBlock:^(SQLiteLanguage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        sqll.APPEND(obj);
    }];
    
    [self.class sqlite_dbOpen];
    BOOL result=[SHARESQLITEObjectC execByTransactionWithSQLL:sqll result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
    }];
    [self.class sqlite_dbClose];
    return result;

}
-(void)tableBuildDeleteSqlArray:(NSMutableArray<SQLiteLanguage *> *)sqlArray IsAssociation:(BOOL)flag{
    Class class=self.class;
    if (flag) {
        NSArray *propertys =[class propertyInforArray];
        [propertys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *propertyType=propertys[idx][PropertyType];
            NSString *propertyName=propertys[idx][PropertyName];
            
            if ([NSObject isStringType:propertyType]) {
            }else if ([NSObject isCNumberType:propertyType]){
            }else if ([NSObject isCFNumberType:propertyType]){
            }else if ([NSObject isValueType:propertyType]){
            }else if ([NSObject isArrayType:propertyType]){//table
                NSArray *array=[self valueForKey:propertyName];
                [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [obj tableBuildDeleteSqlArray:sqlArray IsAssociation:flag];
                }];
            }else if ([NSObject isDictionaryType:propertyType]){
            }else{//table
                [[self valueForKey:propertyName] tableBuildDeleteSqlArray:sqlArray IsAssociation:flag];

            }

        }];
    }
    SQLiteLanguage *sqll=SQLlang.DELETE.FROM([class sqlite_tableName]).WHERE([NSString stringWithFormat:@"%@='%@'",SQLITE_TABLE_PRIMARYKEY_ID,self.sqliteTablePrimaryKeyID]);
    [sqll SEMICOLON];
    [sqlArray addObject:sqll];
}
-(BOOL)sqlite_tableDeleteWithCondition:(SQLiteLanguage *)condition IsAssociation:(BOOL)flag{
    NSMutableArray *sqlArray=[[NSMutableArray alloc] init];
    [self tableBuildDeleteSqlArray:sqlArray IsAssociation:flag];
    SQLiteLanguage *sqll=SQLlang;
    [sqlArray enumerateObjectsUsingBlock:^(SQLiteLanguage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        sqll.APPEND(obj);
    }];

    [self.class sqlite_dbOpen];
    BOOL result=[SHARESQLITEObjectC execByTransactionWithSQLL:sqll result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
    }];
    [self.class sqlite_dbClose];
    return result;
}

-(BOOL)sqlite_tableUpdateWithIsAssociation:(BOOL)flag{
    NSMutableArray<SQLiteLanguage *> *sqllArray=[[NSMutableArray alloc] init];
    [self tableBuildUpdateSqlArray:sqllArray IsAssociation:flag];
    
    SQLiteLanguage *sqll=SQLlang;
    [sqllArray enumerateObjectsUsingBlock:^(SQLiteLanguage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        sqll.APPEND(obj);
    }];
    [self.class sqlite_dbOpen];
    BOOL result=[SHARESQLITEObjectC execByTransactionWithSQLL:sqll result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
    }];
    [self.class sqlite_dbClose];
    return result;
}
-(void)tableBuildUpdateSqlArray:(NSMutableArray<SQLiteLanguage *> *)sqlArray IsAssociation:(BOOL)flag{
    Class class=self.class;
    NSArray *propertys =[class propertyInforArray];
    SQLiteLanguage *sqll=SQLlang;
    sqll.UPDATE([class sqlite_tableName]);
    
    NSMutableArray *setValueArray=[[NSMutableArray alloc] init];
    [propertys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *propertyType=propertys[idx][PropertyType];
        NSString *propertyName=propertys[idx][PropertyName];
        
        if ([NSObject isStringType:propertyType]) {
            [setValueArray addObject:[NSString stringWithFormat:@"%@ ='%@'",propertyName,[self valueForKey:propertyName]]];
        }else if ([NSObject isCNumberType:propertyType]){
            [setValueArray addObject:[NSString stringWithFormat:@"%@ =%@",propertyName,[self valueForKey:propertyName]]];
        }else if ([NSObject isCFNumberType:propertyType]){
            [setValueArray addObject:[NSString stringWithFormat:@"%@ =%@",propertyName,[self valueForKey:propertyName]]];
        }else if ([NSObject isValueType:propertyType]){
            [setValueArray addObject:[NSString stringWithFormat:@"%@ =%@",propertyName,[self valueForKey:propertyName]]];

        }else if ([NSObject isArrayType:propertyType]){//table
            if (flag) {
                NSArray *array=[self valueForKey:propertyName];
                [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [obj tableBuildUpdateSqlArray:sqlArray IsAssociation:flag];
                }];
            }
        }else if ([NSObject isDictionaryType:propertyType]){
        }else{//table
            if (flag) {
                [[self valueForKey:propertyName] tableBuildUpdateSqlArray:sqlArray IsAssociation:flag];
            }
        }
    }];
    
  NSString *sqliteTablePrimaryKeyID=[self valueForKey:[self.class sqlite_tablePrimaryKeyValueSetProperty]];
    
    sqll.SET([setValueArray componentsJoinedByString:@", "],nil).WHERE([NSString stringWithFormat:@"%@ ='%@'",SQLITE_TABLE_PRIMARYKEY_ID,sqliteTablePrimaryKeyID]);
    [sqll SEMICOLON];
    [sqlArray addObject:sqll];
}

-(BOOL)sqlite_tableInsertWithIsAssociation:(BOOL)flag{
    NSMutableArray<SQLiteLanguage *> *sqlArray=[[NSMutableArray alloc] init];
    [self tableBuildInsertSqlArray:sqlArray andForeignKeyValue:nil andRecordingOwnValue:nil IsAssociation:flag];
    SQLiteLanguage *sql=SQLlang;
    [sqlArray enumerateObjectsUsingBlock:^(SQLiteLanguage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        sql.APPEND(obj);
    }];
    BOOL fg=NO;
    [self.class sqlite_dbOpen];
    fg=[SHARESQLITEObjectC execByTransactionWithSQLL:sql result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
        NSLog(@"%@",errorInfor);
    }];
    [self.class sqlite_dbClose];
    return fg;
}
-(void)tableBuildInsertSqlArray:(NSMutableArray<SQLiteLanguage *> *)sqlArray
             andForeignKeyValue:(NSString *)foreignKeyValue
           andRecordingOwnValue:(NSString *)recordingOwnValue
                  IsAssociation:(BOOL)flag{
    Class class=self.class;
    NSArray *fieldArray =[self propertyInforArray];
    SQLiteLanguage *sql =SQLlang;
    sql.INSERT.INTO([class sqlite_tableName]);
    NSMutableArray *columns=[[NSMutableArray  alloc] init];
    NSMutableArray *values=[[NSMutableArray  alloc] init];
    NSMutableArray<NSDictionary *> *subTableArray=[[NSMutableArray alloc] init];

    //主键值设置
    NSString *primaryValue=nil;
    NSString *key=[self.class sqlite_tablePrimaryKeyValueSetProperty];
    if(key){
        primaryValue=[self valueForKey:key];
    }else{
        primaryValue=[NSString sqlite_getUUIDString];
    }
    NSString *primaryKey=SQLITE_TABLE_PRIMARYKEY_ID;
    [columns addObject:primaryKey];
    [values addObject:[NSString stringWithFormat:@"'%@'",primaryValue]];
    
    //外键值设置
    if (foreignKeyValue) {
        NSString *foreignKey=SQLITE_TABLE_FOREIGNKEY_ID;
        [columns addObject:foreignKey];
        [values addObject:[NSString stringWithFormat:@"'%@'",foreignKeyValue]];
    }
    if (recordingOwnValue) {
        [columns addObject:SQLITE_TABLE_RecordingOwn_KEY];
        [values addObject:[NSString stringWithFormat:@"'%@'",recordingOwnValue]];
    }
    
    for (NSInteger i=0; i<fieldArray.count; i++) {
        NSString *propertyType=fieldArray[i][PropertyType];
        NSString *propertyName=fieldArray[i][PropertyName];
        
        if ([NSObject isStringType:propertyType]) {
            id value=[NSString stringWithFormat:@"'%@'",[self valueForKey:propertyName]];
            if (value) {
                [columns addObject:propertyName];
                [values addObject:value];
            }
        }else if ([NSObject isCNumberType:propertyType]){
            id value=[self valueForKey:propertyName];
            if (value) {
                [columns addObject:propertyName];
                [values addObject:value];
            }
        }else if ([NSObject isCFNumberType:propertyType]){
            id value=[self valueForKey:propertyName];
            if (value) {
                [columns addObject:propertyName];
                [values addObject:value];
            }
        }else if ([NSObject isValueType:propertyType]){
            id value=[self valueForKey:propertyName];
            if (value) {
                [columns addObject:propertyName];
                [values addObject:[self valueForKey:propertyName]];
            }
        }else if ([NSObject isArrayType:propertyType]){
            id value=[self valueForKey:propertyName];
            if (value) {
                NSDictionary *valueDic=@{
                                         PropertyType:propertyType,
                                         PropertyName:propertyName,
                                         SQLITE_TABLE_FOREIGNKEY_ID:primaryValue,
                                         SQLITE_VALUE_DICTIONARY_KEY:value
                                         };
                [subTableArray addObject:valueDic];
            }
        }else if ([NSObject isDictionaryType:propertyType]){
        }else{
            id value=[self valueForKey:propertyName];
            if (value) {
                NSDictionary *valueDic=@{
                                         PropertyType:propertyType,
                                         PropertyName:propertyName,
                                         SQLITE_TABLE_FOREIGNKEY_ID:primaryValue,
                                         SQLITE_VALUE_DICTIONARY_KEY:value
                                         };
                [subTableArray addObject:valueDic];
            }
        }
    }
    [sql.COLUMNS([columns componentsJoinedByString:@","],nil).VALUES([values componentsJoinedByString:@","],nil) SEMICOLON];
    [sqlArray addObject:sql];
    
    if (flag) {
        [subTableArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *propertyType=obj[PropertyType];
            NSString *propertyName=obj[PropertyName];
            NSString *foreignKeyValue=obj[SQLITE_TABLE_FOREIGNKEY_ID];
            id value=obj[SQLITE_VALUE_DICTIONARY_KEY];
            if ([NSString isArrayType:propertyType]) {
                [value enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [obj tableBuildInsertSqlArray:sqlArray andForeignKeyValue:foreignKeyValue andRecordingOwnValue:propertyName IsAssociation:flag];
                }];
            }else{
                [value tableBuildInsertSqlArray:sqlArray andForeignKeyValue:foreignKeyValue andRecordingOwnValue:propertyName IsAssociation:flag];
            }
        }];
    }

}
+(NSArray *)sqlite_tableSelectWithCondition:(SQLiteLanguage *)condition IsAssociation:(BOOL)flag{
    SQLiteLanguage *sqll=SQLlang.SELECT(@"*",nil).FROM([self sqlite_tableName]);
    sqll.APPEND(condition);
    
    
    [self sqlite_dbOpen];
    __block NSMutableArray *resultArr=[[NSMutableArray alloc] init];
    [SHARESQLITEObjectC execByTransactionWithSQLL:sqll result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
        [resultArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSObject *object =[[self alloc] init];
            [object setValuesForKeysWithDictionary:obj];
            object.sqliteTablePrimaryKeyID=obj[SQLITE_TABLE_PRIMARYKEY_ID];
            object.sqliteTableForeignKeyID=obj[SQLITE_TABLE_FOREIGNKEY_ID];
            object.sqliteTableRecordingOwnKey=obj[SQLITE_TABLE_RecordingOwn_KEY];
            [resultArr addObject:object];
            
            if (flag) {
                NSArray<NSDictionary *> *propertyArray =[self propertyInforArray];
                [propertyArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if(![NSObject isCFNumberType:obj[PropertyType]]&&
                       ![NSObject isCNumberType:obj[PropertyType]]&&
                       ![NSObject isDictionaryType:obj[PropertyType]]&&
                       ![NSObject isStringType:obj[PropertyType]]&&
                       ![NSObject isValueType:obj[PropertyType]]){
                        [object sqlite_tableSelectWithPropertyName:obj[PropertyName] andCondition:nil IsAssociation:flag];
                    }
                }];
            }
        }];
    }];
    [self sqlite_dbClose];
    return resultArr;
}
-(BOOL)sqlite_tableSelectWithPropertyName:(NSString *)propertyName andCondition:(SQLiteLanguage *)condition IsAssociation:(BOOL)flag{
    NSString *propertyType=[self getPropertyTypeWithPropertyName:propertyName];
    NSString *tableType=nil;
    if ([NSObject isArrayType:propertyType]) {
        tableType=self.class.sqlite_tablePropertyNameAndElementTypeDictionary[propertyName];
    }else{
        tableType=propertyType;
    }
    Class class=NSClassFromString(tableType);
    SQLiteLanguage *sqll=SQLlang.SELECT(@"*",nil).FROM([class sqlite_tableName]);
    
    NSString *tj0=[NSString stringWithFormat:@"%@='%@'",SQLITE_TABLE_FOREIGNKEY_ID,self.sqliteTablePrimaryKeyID];
    NSString *tj1=[NSString stringWithFormat:@"%@='%@'",SQLITE_TABLE_RecordingOwn_KEY,propertyName];

    if (condition) {
        condition.AND(tj0).AND(tj1);
        sqll.APPEND(condition);
    }else{
        sqll.WHERE(tj0).AND(tj1);
    }
    [self.class sqlite_dbOpen];
    __block NSMutableArray *resultArr=[[NSMutableArray alloc] init];
    BOOL result =[SHARESQLITEObjectC execByTransactionWithSQLL:sqll result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
        [resultArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSObject *object =[[class alloc] init];
            [object setValuesForKeysWithDictionary:obj];
            object.sqliteTablePrimaryKeyID=obj[SQLITE_TABLE_PRIMARYKEY_ID];
            object.sqliteTableForeignKeyID=obj[SQLITE_TABLE_FOREIGNKEY_ID];
            object.sqliteTableRecordingOwnKey=obj[SQLITE_TABLE_RecordingOwn_KEY];
            [resultArr addObject:object];
        }];
    }];
    
    if ([NSObject isArrayType:propertyType]) {
        [self setValue:resultArr forKey:propertyName];
    }else{
        [self setValue:[resultArr firstObject] forKey:propertyName];
    }
    if (flag) {
        [resultArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSObject *object=obj;
            NSArray<NSDictionary *> *propertyArray =[object.class propertyInforArray];
            [propertyArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if(![NSObject isCFNumberType:obj[PropertyType]]&&
                   ![NSObject isCNumberType:obj[PropertyType]]&&
                   ![NSObject isDictionaryType:obj[PropertyType]]&&
                   ![NSObject isStringType:obj[PropertyType]]&&
                   ![NSObject isValueType:obj[PropertyType]]){
                    [object sqlite_tableSelectWithPropertyName:obj[PropertyName] andCondition:nil IsAssociation:flag];
                }
            }];
        }];
    }
    
    [self.class sqlite_dbClose];
    return result;
}
-(NSString *)getPropertyTypeWithPropertyName:(NSString *)propertyName{
    NSArray<NSDictionary *> *propertyArray =[self propertyInforArray];
    __block NSString *propertyType=nil;
    [propertyArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[PropertyName] isEqualToString:propertyName]) {
            propertyType=obj[PropertyType];
            *stop=YES;
        }
    }];
    return propertyType;
}
#pragma mark - ============ Get ============
-(NSString *)sqliteTableForeignKeyID{
    return objc_getAssociatedObject(self, &SqliteTableForeignKeyID);
}
-(void)setSqliteTableForeignKeyID:(NSString *)sqliteTableForeignKeyID{
    objc_setAssociatedObject(self, &SqliteTableForeignKeyID, sqliteTableForeignKeyID, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString *)sqliteTableRecordingOwnKey{
   return objc_getAssociatedObject(self, &SqliteTableRecordingOwnKey);
}
-(void)setSqliteTableRecordingOwnKey:(NSString *)sqliteTableRecordingOwnKey{
    objc_setAssociatedObject(self, &SqliteTableRecordingOwnKey, sqliteTableRecordingOwnKey, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString *)sqliteTablePrimaryKeyID{
   return objc_getAssociatedObject(self, &SqliteTablePrimaryKeyID);
}
-(void)setSqliteTablePrimaryKeyID:(NSString *)sqliteTablePrimaryKeyID{
    objc_setAssociatedObject(self, &SqliteTablePrimaryKeyID, sqliteTablePrimaryKeyID, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


+(BOOL)isArrayType:(NSString *)type{
    if ([NSClassFromString(type) respondsToSelector:@selector(typeCheck_isKindNSArray)]) {
        return YES;
    }else{
        return NO;
    }
}
+(BOOL)isDictionaryType:(NSString *)type{
    if ([NSClassFromString(type) respondsToSelector:@selector(typeCheck_isKindNSDictionary)]) {
        return YES;
    }else{
        return NO;
    }
}
+(BOOL)isStringType:(NSString *)type{
    if ([NSClassFromString(type) respondsToSelector:@selector(typeCheck_isKindNSString)]) {
        return YES;
    }else{
        return NO;
    }
}
+(BOOL)isValueType:(NSString *)type{
    if ([NSClassFromString(type) respondsToSelector:@selector(typeCheck_isKindNSValue)]) {
        return YES;
    }else{
        return NO;
    }
}
-(NSSet*)YYMTD_UnconversionProperty{
    return nil;
}
-(NSSet*)YYMTD_ResetKeyDictionary{
    return nil;
}

@end
