//
//  NSObject+SQLITE.m
//  SQLiteObject_C
//
//  Created by POSUN-MAC on 2018/7/23.
//  Copyright © 2018年 POSUN-MAC. All rights reserved.
//

#import "NSObject+SQLITE.h"
#import "NSObject+Dictionary.h"

#define SQLITE_TABLE_PRIMARYKEY_ID @"SQLITE_TABLE_PRIMARYKEY_ID"
#define SQLITE_TABLE_FOREIGNKEY_ID @"SQLITE_TABLE_FOREIGNKEY_ID"
#define SQLITE_TABLE_DEFULTKEY_TYPE @"NSString"
#define SQLITE_DATABASEE @"SQLIT_DATABASEE.db"

#define SQLITE_TABLE_DICTIONARY_KEY @"SQLITE_TABLE_DICTIONARY_KEY"
#define SQLITE_SQLL_DICTIONARY_KEY @"SQLITE_SQLL_DICTIONARY_KEY"
#define SQLITE_VALUE_DICTIONARY_KEY @"SQLITE_VALUE_DICTIONARY_KEY"



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
    fieldArray=[self checkSetKEY:fieldArray andKey:[self table_PrimaryKey]];
    fieldArray=[self checkSetKEY:fieldArray andKey:[self table_ForeignKey]];
    return fieldArray;
}
+(BOOL)tableCreate{
    NSMutableArray<NSDictionary *> *tableSqlArray=[[NSMutableArray alloc] init];
    [self tableBuildSqlWithTableName:nil andTableSqlArray:tableSqlArray];
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
+(void)tableBuildSqlWithTableName:(NSString *)tableName andTableSqlArray:(NSMutableArray<NSDictionary*>*)tableSqlArray{
    NSArray *fieldArray =[self analyticalBuildTableField];
    SQLiteLanguage *sql =SQLlang;
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
            NSDictionary *dic=[self table_ArrayPropertyNameAndElementTypeDictionary];
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
        if ([propertyName isEqualToString:[self table_PrimaryKey]]) {
            sql.PRIMARY.KEY(nil);
//            if ([propertyName isEqualToString:SQLITE_TABLE_PRIMARYKEY_ID]) {
//                [sql AUTOINCREMENT];
//            }
        }
        /**设置设置外键**/
        if ([propertyName isEqualToString:[self table_ForeignKey]]&&tableName) {
            sql.COMMA.FOREIGN.KEY(propertyName,nil).REFERENCES([NSString stringWithFormat:@"%@(%@)",tableName,[self table_ForeignKeyFromKey]]);
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
        NSString *FOREIGNKEY_FROMTABLE=[class table_ForeignKeyFromTable];
        if (!FOREIGNKEY_FROMTABLE) {
            FOREIGNKEY_FROMTABLE=[self tableName];
        }
        [class tableBuildSqlWithTableName:FOREIGNKEY_FROMTABLE andTableSqlArray:tableSqlArray];
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
            NSDictionary *dic=[self table_ArrayPropertyNameAndElementTypeDictionary];
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
+(NSString *)table_PrimaryKey{
    return SQLITE_TABLE_PRIMARYKEY_ID;
}
+(NSString*)table_ForeignKey{
    return SQLITE_TABLE_FOREIGNKEY_ID;
}
+(NSDictionary*)table_ArrayPropertyNameAndElementTypeDictionary{
    return nil;
}
+(NSString*)table_ForeignKeyFromKey{
    return SQLITE_TABLE_PRIMARYKEY_ID;
}
+(NSString*)table_ForeignKeyFromTable{
    return nil;
}
-(BOOL)table_Insert{
    NSMutableArray<SQLiteLanguage *> *sqlArray=[[NSMutableArray alloc] init];
    [self tableBuildInsertSqlArray:sqlArray andForeignKeyValue:nil];
    SQLiteLanguage *sql=SQLlang;
    [sqlArray enumerateObjectsUsingBlock:^(SQLiteLanguage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        sql.APPEND(obj);
    }];
    return [SHARESQLITEObjectC execSQLL:sql result:^(NSString *errorInfor, NSArray<NSDictionary *> *resultArray) {
    }];
}
-(void)tableBuildInsertSqlArray:(NSMutableArray<SQLiteLanguage *> *)sqlArray andForeignKeyValue:(NSString *)foreignKeyValue{
    Class class=self.class;
    NSArray *fieldArray =[self propertyInforArray];
    SQLiteLanguage *sql =SQLlang;
    sql.INSERT.INTO([class tableName]);
    NSMutableArray *columns=[[NSMutableArray  alloc] init];
    NSMutableArray *values=[[NSMutableArray  alloc] init];
    NSMutableArray<NSDictionary *> *subTableArray=[[NSMutableArray alloc] init];
    
    //主键值设置
    NSString *primaryValue=[NSString sqlite_getUUIDString];
    NSString *primaryKey=[self.class table_PrimaryKey];
    if ([self table_PrimaryKeyIsDefault]) {
        [columns addObject:primaryKey];
        [values addObject:primaryValue];
    }
    //外键值设置
    if (foreignKeyValue) {
        NSString *foreignKey=[self.class table_ForeignKey];
        [columns addObject:foreignKey];
        [values addObject:foreignKeyValue];
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
        [obj[SQLITE_VALUE_DICTIONARY_KEY] tableBuildInsertSqlArray:sqlArray andForeignKeyValue:SQLITE_TABLE_FOREIGNKEY_ID];
    }];
}
-(BOOL)table_PrimaryKeyIsDefault{
    return [[self.class table_PrimaryKey] isEqualToString:SQLITE_TABLE_PRIMARYKEY_ID];
}
@end
