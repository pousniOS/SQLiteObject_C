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
#define SQLITE_TABLE_DEFULTKEY_TYPE @"unsigned long long"
#define SQLITE_DATABASEE @"SQLIT_DATABASEE.db"
@implementation NSObject (SQLITE)
+(NSString *)dbPath{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:[NSString stringWithFormat:@"/%@",SQLITE_DATABASEE]];
}
+(BOOL)tableIsExist{
    [self dbOpen];
    if ([SHARESQLITEObjectC execSQLL:SQLlang.SELECT(@"count(*)",nil).FROM(@"sqlite_master").WHERE(@"type='table'").AND([NSString stringWithFormat:@"tbl_name='%@'",[self tableName]])]){
        NSDictionary *countDic = [SHARESQLITEObjectC.execSQLResultArray firstObject];
        NSString *countStr=[countDic objectForKey:@"count(*)"];
        return [countStr integerValue];
    }else{
        return NO;
    }
}
+(NSArray *)analyticalBuildTableField{
    NSArray *fieldArray =[self propertyInforArray];
    fieldArray=[self filterProperty:[self table_UnconversionProperty]];
    fieldArray=[self checkSetKEY:fieldArray andKey:[self table_PrimaryKey]];
    fieldArray=[self checkSetKEY:fieldArray andKey:[self table_ForeignKey]];
    return fieldArray;
}
+(void)tableCreate{
    [self dbOpen];
    [self tableCreateWithFOREIGNKEYTable:nil];
    [self dbClose];
}
+(void)tableCreateWithFOREIGNKEYTable:(NSString *)tableName{
    NSArray *fieldArray =[self analyticalBuildTableField];
    SQLiteLanguage *sql =SQLlang;
    NSMutableSet *mutableSet=[[NSMutableSet alloc] init];
    for (NSInteger i=0; i<fieldArray.count; i++) {
        NSString *propertyType=fieldArray[i][PropertyType];
        NSString *propertyName=fieldArray[i][PropertyName];
        if ([NSObject isStringType:propertyType]) {
            sql.columnName(propertyName);
            [sql TEXT];
        }else if ([self isCNumberType:propertyType]){
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
            [mutableSet addObject:type];
            continue;
        }else if ([NSObject isDictionaryType:propertyType]){
            continue;
        }else{
            [mutableSet addObject:propertyType];
            continue;
        }
        /**设置主键**/
        if ([propertyName isEqualToString:[self table_PrimaryKey]]) {
            sql.PRIMARY.KEY(nil);
            if ([propertyName isEqualToString:SQLITE_TABLE_PRIMARYKEY_ID]) {
                [sql AUTOINCREMENT];
            }
        }
        /**设置设置外键**/
        if ([propertyName isEqualToString:[self table_ForeignKey]]&&tableName) {
            sql.COMMA.FOREIGN.KEY(propertyName,nil).REFERENCES([NSString stringWithFormat:@"%@(%@)",tableName,[self table_ForeignKeyFromKey]]);
        }
        if (fieldArray.count!=i+1) {
            [sql COMMA];
        }
    }
    if (![self tableIsExist]) {
        [SHARESQLITEObjectC execSQLL:SQLlang.CREATE.TABEL(NSStringFromClass(self)).COLUMNS(sql,nil)];
    }
    [mutableSet enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        Class class=NSClassFromString(obj);
        NSString *FOREIGNKEY_FROMTABLE=[class table_ForeignKeyFromTable];
        if (!FOREIGNKEY_FROMTABLE) {
            FOREIGNKEY_FROMTABLE=[self tableName];
        }
        [class tableCreateWithFOREIGNKEYTable:FOREIGNKEY_FROMTABLE];
    }];
}
+(BOOL)tableDrop{
    if ([self tableIsExist]) {
        return [SHARESQLITEObjectC execSQLL:SQLlang.DROP.TABEL([self tableName])];
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
@end
