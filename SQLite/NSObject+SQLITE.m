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
 数据所属的属性字段
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
+(NSString *)dbPath{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:[NSString stringWithFormat:@"/%@",SQLITE_DATABASEE]];
}
+(BOOL)tableIsExist{
    SQLiteLanguage *sql=SQLlang.SELECT(@"count(*)",nil).FROM(@"sqlite_master").WHERE(@"type='table'").AND([NSString stringWithFormat:@"tbl_name='%@'",[self tableName]]);
    __block BOOL result=NO;
    [self dbOpen];
    [SHARESQLITEObjectC execSQLL:sql result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
        if (errorInfor) {
            result=NO;
        }else{
            NSDictionary *dic =[resultArray firstObject];
            result=[dic[@"count(*)"] integerValue];
        }
    }];
    [self dbClose];
    return result;
}
+(NSArray *)analyticalBuildTableField{
    NSArray *fieldArray =[self propertyInforArray];
    fieldArray=[self filterProperty:[self table_UnconversionProperty]];
    fieldArray=[self checkSetKEY:fieldArray andKey:SQLITE_TABLE_PRIMARYKEY_ID];
    fieldArray=[self checkSetKEY:fieldArray andKey:SQLITE_TABLE_FOREIGNKEY_ID];
    return fieldArray;
}
+(BOOL)tableCreate{
    NSMutableArray<NSDictionary *> *tableSqlArray=[[NSMutableArray alloc] init];
    [self tableBuildTableSqlWithTableSqlArray:tableSqlArray];
    SQLiteLanguage *sqll=SQLlang;
    [sqll.BEGIN.TRANSACTION SEMICOLON];
    [tableSqlArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        sqll.APPEND(obj[SQLITE_SQLL_DICTIONARY_KEY]);
    }];
    [sqll.COMMIT SEMICOLON];
    NSLog(@"%@",sqll.sql);
    [self dbOpen];
    BOOL result=[SHARESQLITEObjectC execSQLL:sqll result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
    }];
    [self dbClose];
    return result;
}
+(void)tableBuildTableSqlWithTableSqlArray:(NSMutableArray<NSDictionary*>*)tableSqlArray{
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
            NSDictionary *dic=[self table_PropertyNameAndElementTypeDictionary];
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
    __block BOOL falg=NO;
    [tableSqlArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[SQLITE_TABLE_DICTIONARY_KEY] isEqualToString:[self tableName]]) {
            falg=YES;
            *stop=YES;
        }
    }];
    if (!falg) {
        SQLiteLanguage *SQLL=[SQLlang.CREATE.TABLE([self tableName]).COLUMNS(sql,nil) SEMICOLON];
        NSDictionary *tableSqlDic=@{
                                    SQLITE_TABLE_DICTIONARY_KEY:[self tableName],
                                    SQLITE_SQLL_DICTIONARY_KEY:SQLL
                                    };
        [tableSqlArray addObject:tableSqlDic];
    }
    
    [subTableSet enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        Class class=NSClassFromString(obj);
        [class tableBuildTableSqlWithTableSqlArray:tableSqlArray];
    }];
}
+(NSArray<NSString *>*)getTables{
    NSMutableArray *tables=[[NSMutableArray alloc] init];
    [tables addObject:[self tableName]];
    NSArray *propertys =[self propertyInforArray];
    [propertys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *propertyType=propertys[idx][PropertyType];
        NSString *propertyName=propertys[idx][PropertyName];
        if ([NSObject isStringType:propertyType]) {
        }else if ([NSObject isCNumberType:propertyType]){
        }else if ([NSObject isCFNumberType:propertyType]){
        }else if ([NSObject isValueType:propertyType]){
        }else if ([NSObject isArrayType:propertyType]){//table
            NSDictionary *dic=[self table_PropertyNameAndElementTypeDictionary];
            NSString *type =dic[propertyName];
            Class class=NSClassFromString(type);
            [self excludeRepeatAddObjects:@[[class tableName]] ToArray:tables];
            [self excludeRepeatAddObjects:[class getTables] ToArray:tables];
        }else if ([NSObject isDictionaryType:propertyType]){
        }else{//table
            Class class=NSClassFromString(propertyType);
            [self excludeRepeatAddObjects:@[[class tableName]] ToArray:tables];
            [self excludeRepeatAddObjects:[class getTables] ToArray:tables];
        }
    }];
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

+(NSArray *)db_seeTables{
    [self dbOpen];
    SQLiteLanguage* sql=SQLlang.SELECT(@"*",nil).FROM(@"sqlite_master");
    __block NSArray *resultArr=nil;
    [SHARESQLITEObjectC execSQLL:sql result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
        resultArr=resultArray;
    }];
    [self dbClose];
    return resultArr;
}

+(BOOL)tableDropAll{
    SQLiteLanguage *sqll=SQLlang;
    [sqll.BEGIN.TRANSACTION SEMICOLON];
    [[self getTables] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Class class=NSClassFromString(obj);
        [sqll.DROP.TABLE([class tableName]) SEMICOLON];
    }];
    [sqll.COMMIT SEMICOLON];
    NSLog(@"%@",sqll.sql);
    [self dbOpen];
    BOOL result=[SHARESQLITEObjectC execSQLL:sqll result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
    }];
    [self dbClose];
    return result;
}
+(BOOL)tableDrop{
    if ([self tableIsExist]) {
        __block BOOL result=NO;
        [self dbOpen];
        SQLiteLanguage *SQLL=SQLlang.DROP.TABLE([self tableName]);
        [SHARESQLITEObjectC execSQLL:SQLL result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
            if (errorInfor) {
                result=NO;
            }else{
                result=YES;
            }
        }];
        [self dbClose];
        return result;
    }else{
        return YES;
    }
}
+(BOOL)dbOpen{
    if (SHARESQLITEObjectC.isOpen) {
        if ([SHARESQLITEObjectC.dbPath isEqualToString:self.dbPath]) {
            return YES;
        }else{
            if ([SHARESQLITEObjectC close]) {
                return [SHARESQLITEObjectC openWithFilePath:self.dbPath];
            }else{
                return NO;
            }
        }
    }else{
        return [SHARESQLITEObjectC openWithFilePath:self.dbPath];
    }
}

+(BOOL)dbClose{
    if ([SHARESQLITEObjectC.dbPath isEqualToString:self.dbPath]) {
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
+(NSString *)tableName{
    return NSStringFromClass(self);
}
+(NSSet*)table_UnconversionProperty{
    return nil;
}
+(NSString *)table_PrimaryKeyValueSetProperty{
    return nil;
}
+(NSDictionary*)table_PropertyNameAndElementTypeDictionary{
    return nil;
}

+(BOOL)table_DeleteWithCondition:(SQLiteLanguage *)condition IsAssociation:(BOOL)falg{
    __block NSMutableArray<SQLiteLanguage*> *sqlArray=[[NSMutableArray alloc] init];
    if (falg) {
        NSArray *resultArray =[self table_SelectWithCondition:condition IsAssociation:YES];
        [resultArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableArray<SQLiteLanguage*> *subSqlArray=[[NSMutableArray alloc] init];
            [obj tableBuildDeleteSqlArray:subSqlArray IsAssociation:YES];
            [sqlArray addObjectsFromArray:subSqlArray];
        }];
    }else{
        SQLiteLanguage *sqll=SQLlang.DELETE.FROM([self tableName]);
        sqll.APPEND(condition);
        [sqll.COMMIT SEMICOLON];
        [sqlArray addObject:sqll];
    }
    
    SQLiteLanguage *sqll=SQLlang;
    [sqll.BEGIN.TRANSACTION SEMICOLON];
    [sqlArray enumerateObjectsUsingBlock:^(SQLiteLanguage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        sqll.APPEND(obj);
    }];
    [sqll.COMMIT SEMICOLON];
    
    [self.class dbOpen];
    BOOL result=[SHARESQLITEObjectC execSQLL:sqll result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
    }];
    [self.class dbClose];
    return result;

}
-(void)tableBuildDeleteSqlArray:(NSMutableArray<SQLiteLanguage *> *)sqlArray IsAssociation:(BOOL)falg{
    Class class=self.class;
    if (falg) {
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
                    [obj tableBuildDeleteSqlArray:sqlArray IsAssociation:falg];
                }];
            }else if ([NSObject isDictionaryType:propertyType]){
            }else{//table
                [[self valueForKey:propertyName] tableBuildDeleteSqlArray:sqlArray IsAssociation:falg];

            }

        }];
    }
    SQLiteLanguage *sqll=SQLlang.DELETE.FROM([class tableName]).WHERE([NSString stringWithFormat:@"%@='%@'",SQLITE_TABLE_PRIMARYKEY_ID,self.sqliteTablePrimaryKeyID]);
    [sqll SEMICOLON];
    [sqlArray addObject:sqll];
}
-(BOOL)table_DeleteWithCondition:(SQLiteLanguage *)condition IsAssociation:(BOOL)falg{
    NSMutableArray *sqlArray=[[NSMutableArray alloc] init];
    [self tableBuildDeleteSqlArray:sqlArray IsAssociation:falg];
    
    SQLiteLanguage *sqll=SQLlang;
    [sqll.BEGIN.TRANSACTION SEMICOLON];
    [sqlArray enumerateObjectsUsingBlock:^(SQLiteLanguage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        sqll.APPEND(obj);
    }];
    [sqll.COMMIT SEMICOLON];
    
    
    [self.class dbOpen];
    BOOL result=[SHARESQLITEObjectC execSQLL:sqll result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
    }];
    [self.class dbClose];
    return result;
}


-(BOOL)table_UpdateWithIsAssociation:(BOOL)flag{
    NSMutableArray<SQLiteLanguage *> *sqllArray=[[NSMutableArray alloc] init];
    [self tableBuildUpdateSqlArray:sqllArray IsAssociation:flag];
    
    SQLiteLanguage *sqll=SQLlang;
    [sqll.BEGIN.TRANSACTION SEMICOLON];
    [sqllArray enumerateObjectsUsingBlock:^(SQLiteLanguage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        sqll.APPEND(obj);
    }];
    [sqll.COMMIT SEMICOLON];
    
    [self.class dbOpen];
    BOOL result=[SHARESQLITEObjectC execSQLL:sqll result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
    }];
    [self.class dbClose];
    return result;
}
-(void)tableBuildUpdateSqlArray:(NSMutableArray<SQLiteLanguage *> *)sqlArray IsAssociation:(BOOL)flag{
    Class class=self.class;
    NSArray *propertys =[class propertyInforArray];
    SQLiteLanguage *sqll=SQLlang;
    sqll.UPDATE([class tableName]);
    
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
    sqll.SET([setValueArray componentsJoinedByString:@", "],nil).WHERE([NSString stringWithFormat:@"%@ ='%@'",SQLITE_TABLE_PRIMARYKEY_ID,self.sqliteTablePrimaryKeyID]);
    [sqll SEMICOLON];
    [sqlArray addObject:sqll];
}

-(BOOL)table_Insert{
    NSMutableArray<SQLiteLanguage *> *sqlArray=[[NSMutableArray alloc] init];
    [self tableBuildInsertSqlArray:sqlArray andForeignKeyValue:nil andRecordingOwnValue:nil];
    SQLiteLanguage *sql=SQLlang;
    [sql.BEGIN.TRANSACTION SEMICOLON];
    [sqlArray enumerateObjectsUsingBlock:^(SQLiteLanguage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        sql.APPEND(obj);
    }];
    [sql.COMMIT SEMICOLON];
    NSLog(@"%@",sql.sql);
    BOOL flag=NO;
    [self.class dbOpen];
    flag=[SHARESQLITEObjectC execSQLL:sql result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
        NSLog(@"%@",errorInfor);
    }];
    [self.class dbClose];
    return flag;
}
-(void)tableBuildInsertSqlArray:(NSMutableArray<SQLiteLanguage *> *)sqlArray
             andForeignKeyValue:(NSString *)foreignKeyValue
           andRecordingOwnValue:(NSString *)recordingOwnValue{
    Class class=self.class;
    NSArray *fieldArray =[self propertyInforArray];
    SQLiteLanguage *sql =SQLlang;
    sql.INSERT.INTO([class tableName]);
    NSMutableArray *columns=[[NSMutableArray  alloc] init];
    NSMutableArray *values=[[NSMutableArray  alloc] init];
    NSMutableArray<NSDictionary *> *subTableArray=[[NSMutableArray alloc] init];

    //主键值设置
    NSString *primaryValue=nil;
    NSString *key=[self.class table_PrimaryKeyValueSetProperty];
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
    [subTableArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *propertyType=obj[PropertyType];
        NSString *propertyName=obj[PropertyName];
        NSString *foreignKeyValue=obj[SQLITE_TABLE_FOREIGNKEY_ID];
        id value=obj[SQLITE_VALUE_DICTIONARY_KEY];
        if ([NSString isArrayType:propertyType]) {
            [value enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj tableBuildInsertSqlArray:sqlArray andForeignKeyValue:foreignKeyValue andRecordingOwnValue:propertyName];
            }];
        }else{
            [value tableBuildInsertSqlArray:sqlArray andForeignKeyValue:foreignKeyValue andRecordingOwnValue:propertyName];
        }
    }];
}
+(NSArray *)table_SelectWithCondition:(SQLiteLanguage *)condition IsAssociation:(BOOL)falg{
    SQLiteLanguage *sqll=SQLlang.SELECT(@"*",nil).FROM([self tableName]);
    
    sqll.APPEND(condition);
    [self dbOpen];
    __block NSMutableArray *resultArr=[[NSMutableArray alloc] init];
    [SHARESQLITEObjectC execSQLL:sqll result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
        [resultArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSObject *object =[[self alloc] init];
            [object setValuesForKeysWithDictionary:obj];
            object.sqliteTablePrimaryKeyID=obj[SQLITE_TABLE_PRIMARYKEY_ID];
            object.sqliteTableForeignKeyID=obj[SQLITE_TABLE_FOREIGNKEY_ID];
            object.sqliteTableRecordingOwnKey=obj[SQLITE_TABLE_RecordingOwn_KEY];
            [resultArr addObject:object];
            
            if (falg) {
                NSArray<NSDictionary *> *propertyArray =[self propertyInforArray];
                [propertyArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if(![NSObject isCFNumberType:obj[PropertyType]]&&
                       ![NSObject isCNumberType:obj[PropertyType]]&&
                       ![NSObject isDictionaryType:obj[PropertyType]]&&
                       ![NSObject isStringType:obj[PropertyType]]&&
                       ![NSObject isValueType:obj[PropertyType]]){
                        [object table_SelectWithPropertyName:obj[PropertyName] andCondition:nil IsAssociation:falg];
                    }
                }];
            }
        }];
    }];
    [self dbClose];
    return resultArr;
}
-(BOOL)table_SelectWithPropertyName:(NSString *)propertyName andCondition:(SQLiteLanguage *)condition IsAssociation:(BOOL)falg{
    NSString *propertyType=[self getPropertyTypeWithPropertyName:propertyName];
    NSString *tableType=nil;
    if ([NSObject isArrayType:propertyType]) {
        tableType=self.class.table_PropertyNameAndElementTypeDictionary[propertyName];
    }else{
        tableType=propertyType;
    }
    Class class=NSClassFromString(tableType);
    SQLiteLanguage *sqll=SQLlang.SELECT(@"*",nil).FROM([class tableName]);
    
    NSString *tj0=[NSString stringWithFormat:@"%@='%@'",SQLITE_TABLE_FOREIGNKEY_ID,self.sqliteTablePrimaryKeyID];
    NSString *tj1=[NSString stringWithFormat:@"%@='%@'",SQLITE_TABLE_RecordingOwn_KEY,propertyName];

    if (condition) {
        condition.AND(tj0).AND(tj1);
        sqll.APPEND(condition);
    }else{
        sqll.WHERE(tj0).AND(tj1);
    }
    [self.class dbOpen];
    __block NSMutableArray *resultArr=[[NSMutableArray alloc] init];
    NSLog(@"%@",sqll.sql);
    
    
    BOOL result =[SHARESQLITEObjectC execSQLL:sqll result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
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
    if (falg) {
        [resultArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSObject *object=obj;
            NSArray<NSDictionary *> *propertyArray =[object.class propertyInforArray];
            [propertyArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if(![NSObject isCFNumberType:obj[PropertyType]]&&
                   ![NSObject isCNumberType:obj[PropertyType]]&&
                   ![NSObject isDictionaryType:obj[PropertyType]]&&
                   ![NSObject isStringType:obj[PropertyType]]&&
                   ![NSObject isValueType:obj[PropertyType]]){
                    [object table_SelectWithPropertyName:obj[PropertyName] andCondition:nil IsAssociation:falg];
                }
            }];
        }];
    }
    
    [self.class dbClose];
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
@end
